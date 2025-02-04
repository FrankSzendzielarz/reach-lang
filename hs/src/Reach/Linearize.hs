module Reach.Linearize (linearize, Error (..)) where

import Control.Monad.Reader
import Data.IORef
import Data.List.Extra
import qualified Data.Map.Strict as M
import Data.Maybe
import Data.Monoid
import qualified Data.Sequence as Seq
import qualified Data.Text as T
import GHC.Stack (HasCallStack)
import Generics.Deriving (Generic)
import Reach.AST.Base
import Reach.AST.DK
import Reach.AST.DL
import Reach.AST.DLBase
import Reach.AST.LL
import Reach.Counter
import Reach.Freshen
import Reach.Texty
import Reach.Util

data Error
  = Err_Unreachable String
  deriving (Eq, Generic, ErrorMessageForJson, ErrorSuggestions)

instance HasErrorCode Error where
  errPrefix = const "RL"

  -- These indices are part of an external interface; they
  -- are used in the documentation of Error Codes.
  -- If a constructor is obsolete, do NOT delete it nor re-allocate its number.
  -- Add new error codes at the end.
  errIndex = \case
    Err_Unreachable {} -> 0

instance Show Error where
  show = \case
    Err_Unreachable s -> "code must not be reachable: " <> s

allocVar :: (e -> Counter) -> ReaderT e IO Int
allocVar ef = asks ef >>= (liftIO . incCounter)

-- Remove returns, duplicate continuations, and transform into dk

type DKApp = ReaderT DKEnv IO

type LLRetRHS = (DLVar, Bool, DKTail)

type LLRet = (Int, LLRetRHS)

data Handler = Handler
  { hV :: DLVar
  , hK :: DKTail
  }

data DKEnv = DKEnv
  { eRet :: Maybe LLRet
  , eExnHandler :: Maybe Handler
  }

withReturn :: Int -> LLRetRHS -> DKApp a -> DKApp a
withReturn rv rvv = local (\e -> e {eRet = Just (rv, rvv)})

data DKBranchMode
  = DKBM_Con
  | DKBM_Do

getDKBM :: IsLocal a => a -> DKApp DKBranchMode
getDKBM x =
  case isLocal x of
    False -> return $ DKBM_Con
    True -> do
      asks eRet >>= \case
        Nothing -> return $ DKBM_Do
        Just (_, (_, True, _)) -> return $ DKBM_Con
        Just (_, (_, False, _)) -> return $ DKBM_Do

dk_block :: SrcLoc -> DLSBlock -> DKApp DKBlock
dk_block _ (DLSBlock at fs l a) =
  DKBlock at fs <$> dk_top at l <*> pure a

turnVarIntoLet :: Bool
turnVarIntoLet = True

dk1 :: DKTail -> DLSStmt -> DKApp DKTail
dk1 k s =
  case s of
    DLS_Let at mdv de -> com $ DKC_Let at mdv de
    DLS_ArrayMap at ans xs as i f ->
      com' $ DKC_ArrayMap at ans xs as i <$> dk_block at f
    DLS_ArrayReduce at ans xs z b as i f ->
      com' $ DKC_ArrayReduce at ans xs z b as i <$> dk_block at f
    DLS_If at c _ t f -> do
      let con = DK_If at c
      let loc t' f' = DK_Com (DKC_LocalIf at c t' f') k
      let mt = DK_Stop at
      (mk, k') <-
        getDKBM s >>= \case
          DKBM_Con -> return $ (con, k)
          DKBM_Do -> return $ (loc, mt)
      mk <$> dk_ k' t <*> dk_ k' f
    DLS_Switch at v _ csm -> do
      let con = DK_Switch at v
      let loc csm' = DK_Com (DKC_LocalSwitch at v csm') k
      let mt = DK_Stop at
      (mk, k') <-
        getDKBM s >>= \case
          DKBM_Con -> return $ (con, k)
          DKBM_Do -> return $ (loc, mt)
      let cm1 (dv', b, l) = (,,) dv' b <$> dk_ k' l
      mk <$> mapM cm1 csm
    DLS_Return at ret da ->
      asks eRet >>= \case
        Nothing -> impossible $ "return not in prompt"
        Just (ret', (dv, isCon, rk)) ->
          case ret == ret' of
            False ->
              impossible $ "return not nested: " <> show (ret, ret')
            True ->
              case turnVarIntoLet && isCon of
                True ->
                  return $ DK_Com (DKC_Let at (DLV_Let DVC_Many dv) $ DLE_Arg at da) rk
                False ->
                  return $ DK_Com (DKC_Set at dv da) rk
    DLS_Prompt at dv@(DLVar _ _ _ ret) _ ss ->
      case isLocal s of
        True -> do
          ss' <- withReturn ret (dv, False, DK_Stop at) $ dk_top at ss
          return $ DK_Com (DKC_Var at dv) $ DK_Com (DKC_LocalDo at ss') k
        False ->
          withReturn ret (dv, True, k) $
            case turnVarIntoLet of
              True -> dk_ k ss
              False -> DK_Com (DKC_Var at dv) <$> dk_ k ss
    DLS_Stop at -> return $ DK_Stop at
    DLS_Unreachable at fs m -> return $ DK_Unreachable at fs m
    DLS_ToConsensus at send recv mtime -> do
      let cs0 = dr_k recv
      let cs =
            case cs0 of
              -- We are forcing an initial switch to be in CPS, assuming that
              -- this is a fork and that this is a good idea
              ((Seq.:<|) (DLS_Prompt pa pb pc ((Seq.:<|) (DLS_Switch sa swb sc sd) Seq.Empty)) r) ->
                ((Seq.<|) (DLS_Prompt pa pb (go pc) ((Seq.<|) (DLS_Switch sa swb (go sc) sd) Seq.empty)) r)
                where
                  go x = x {sa_local = False}
              _ -> cs0
      cs' <- dk_ k cs
      let recv' = recv {dr_k = cs'}
      let go (ta, time_ss) = (,) ta <$> dk_ k time_ss
      DK_ToConsensus at send recv' <$> mapM go mtime
    DLS_FromConsensus at fs ss -> DK_FromConsensus at at fs <$> dk_ k ss
    DLS_While at asn inv_b cond_b body -> do
      let body' = dk_top at body
      let block = dk_block at
      DK_While at asn <$> block inv_b <*> block cond_b <*> body' <*> pure k
    DLS_Continue at asn -> return $ DK_Continue at asn
    DLS_FluidSet at fv a -> com $ DKC_FluidSet at fv a
    DLS_FluidRef at v fv -> com $ DKC_FluidRef at v fv
    DLS_MapReduce at mri ans x z b a f ->
      com' $ DKC_MapReduce at mri ans x z b a <$> dk_block at f
    DLS_Only at who ss ->
      com' $ DKC_Only at who <$> dk_top at ss
    DLS_Throw at da _ -> do
      asks eExnHandler >>= \case
        Nothing ->
          impossible "dk: encountered `throw` without an exception handler"
        Just (Handler {..}) ->
          com'' (DKC_Let at (DLV_Let DVC_Many hV) $ DLE_Arg at da) hK
    DLS_Try _at e hV hs -> do
      hK <- dk_ k hs
      local (\env -> env {eExnHandler = Just (Handler {..})}) $
        dk_ k e
    DLS_ViewIs at vn vk mva -> do
      mva' <- maybe (return $ Nothing) (\eb -> Just <$> dk_eb eb) mva
      return $ DK_ViewIs at vn vk mva' k
    DLS_TokenMetaGet ty at dv a mp -> com $ DKC_TokenMetaGet ty at dv a mp
    DLS_TokenMetaSet ty at a v mp i -> com $ DKC_TokenMetaSet ty at a v mp i
  where
    com :: DKCommon -> DKApp DKTail
    com = flip com'' k
    com' :: DKApp DKCommon -> DKApp DKTail
    com' m = com =<< m
    com'' :: DKCommon -> DKTail -> DKApp DKTail
    com'' m k' = return $ DK_Com m k'

dk_ :: DKTail -> DLStmts -> DKApp DKTail
dk_ k = \case
  Seq.Empty -> return k
  s Seq.:<| ks -> flip dk1 s =<< dk_ k ks

dk_top :: SrcLoc -> DLStmts -> DKApp DKTail
dk_top = dk_ . DK_Stop

dk_eb :: DLSExportBlock -> DKApp DKExportBlock
dk_eb (DLinExportBlock at vs b) =
  resetDK $ DLinExportBlock at vs <$> dk_block at b

resetDK :: DKApp a -> DKApp a
resetDK = local (\e -> e {eRet = Nothing, eExnHandler = Nothing})

dekont :: DLProg -> IO DKProg
dekont (DLProg at opts sps dli dex dvs das devts ss) = do
  let eRet = Nothing
  let eExnHandler = Nothing
  flip runReaderT (DKEnv {..}) $ do
    dex' <- mapM dk_eb dex
    DKProg at opts sps dli dex' dvs das devts <$> dk_top at ss

-- Lift common things to the previous consensus
type LCApp = ReaderT LCEnv IO

type LCAppT a = a -> LCApp a

data LCEnv = LCEnv
  { eLifts :: Maybe (IORef (Seq.Seq DKCommon))
  }

-- FIXME: I think this always returns True
class CanLift a where
  canLift :: a -> Bool

instance CanLift DLExpr where
  canLift = isLocal

instance CanLift a => CanLift (SwitchCases a) where
  canLift = getAll . mconcatMap (All . go) . M.toList
    where
      go (_, (_, _, k)) = canLift k

instance CanLift DKTail where
  canLift = \case
    DK_Stop {} -> True
    DK_Com m k -> canLift m && canLift k
    _ -> impossible "canLift on DKLTail"

instance CanLift DKBlock where
  canLift = \case
    DKBlock _ _ t _ -> canLift t

instance CanLift DKCommon where
  canLift = \case
    DKC_Let _ _ e -> canLift e
    DKC_ArrayMap _ _ _ _ _ f -> canLift f
    DKC_ArrayReduce _ _ _ _ _ _ _ f -> canLift f
    DKC_Var {} -> True
    DKC_Set {} -> True
    DKC_LocalDo _ t -> canLift t
    DKC_LocalIf _ _ t f -> canLift t && canLift f
    DKC_LocalSwitch _ _ csm -> canLift csm
    DKC_MapReduce _ _ _ _ _ _ _ f -> canLift f
    DKC_FluidSet {} -> True
    DKC_FluidRef {} -> True
    DKC_Only {} -> False --- XXX maybe okay
    DKC_setApiDetails {} -> False
    DKC_TokenMetaGet {} -> True
    DKC_TokenMetaSet {} -> True

noLifts :: LCApp a -> LCApp a
noLifts = local (\e -> e {eLifts = Nothing})

doLift :: DKCommon -> LCApp DKTail -> LCApp DKTail
doLift m mk = do
  LCEnv {..} <- ask
  case (eLifts, canLift m) of
    (Just lr, True) -> do
      liftIO $ modifyIORef lr (Seq.|> m)
      mk
    _ -> DK_Com m <$> mk

captureLifts :: SrcLoc -> LCApp DKTail -> LCApp DKTail
captureLifts at mc = do
  lr <- liftIO $ newIORef mempty
  c <- local (\e -> e {eLifts = Just lr}) mc
  ls <- liftIO $ readIORef lr
  return $ DK_LiftBoundary at $ foldr DK_Com c ls

class LiftCon a where
  lc :: LCAppT a

instance LiftCon a => LiftCon (Maybe a) where
  lc = \case
    Nothing -> return $ Nothing
    Just x -> Just <$> lc x

instance LiftCon z => LiftCon (a, z) where
  lc (a, z) = (\z' -> (a, z')) <$> lc z

instance LiftCon z => LiftCon (DLRecv z) where
  lc r = (\z' -> r {dr_k = z'}) <$> lc (dr_k r)

instance LiftCon a => LiftCon (SwitchCases a) where
  lc = mapM (\(a, b, c) -> (,,) a b <$> lc c)

instance LiftCon DKBlock where
  lc (DKBlock at sf b a) =
    DKBlock at sf <$> lc b <*> pure a

instance LiftCon a => LiftCon (DLinExportBlock a) where
  lc (DLinExportBlock at vs b) =
    DLinExportBlock at vs <$> lc b

instance LiftCon DKExports where
  lc = mapM lc

instance LiftCon DKTail where
  lc = \case
    DK_Com m k -> doLift m (lc k)
    DK_Stop at -> return $ DK_Stop at
    DK_ToConsensus at send recv mtime -> do
      DK_ToConsensus at send <$> (noLifts $ lc recv) <*> lc mtime
    DK_If at c t f -> DK_If at c <$> lc t <*> lc f
    DK_Switch at v csm -> DK_Switch at v <$> lc csm
    DK_FromConsensus at1 at2 fs k ->
      captureLifts at1 $ DK_FromConsensus at1 at2 fs <$> lc k
    DK_While at asn inv cond body k ->
      DK_While at asn inv cond <$> lc body <*> lc k
    DK_Continue at asn -> return $ DK_Continue at asn
    DK_ViewIs at vn vk a k ->
      DK_ViewIs at vn vk a <$> lc k
    DK_Unreachable at fs m ->
      expect_throw (Just fs) at $ Err_Unreachable m
    DK_LiftBoundary {} ->
      impossible "lift boundary before liftcon"

liftcon :: DKProg -> IO DKProg
liftcon (DKProg at opts sps dli dex dvs das devts k) = do
  let eLifts = Nothing
  flip runReaderT (LCEnv {..}) $
    DKProg at opts sps dli <$> lc dex <*> pure dvs <*> pure das <*> pure devts <*> lc k

-- Remove fluid variables and convert to proper linear shape
type FluidEnv = M.Map FluidVar (SrcLoc, DLArg)

type FVMap = M.Map FluidVar DLVar

type DFApp = ReaderT DFEnv IO

data DFEnv = DFEnv
  { eCounter_df :: Counter
  , eFVMm :: Maybe FVMap
  , eFVE :: FluidEnv
  , eFVs :: [FluidVar]
  , eBals :: Integer
  }

df_allocVar :: DFApp Int
df_allocVar = allocVar eCounter_df

fluidRefm :: FluidVar -> DFApp (Maybe (SrcLoc, DLArg))
fluidRefm fv = do
  DFEnv {..} <- ask
  return $ M.lookup fv eFVE

fluidRef :: SrcLoc -> FluidVar -> DFApp (SrcLoc, DLArg)
fluidRef at fv = do
  r <- fluidRefm fv
  case r of
    Nothing -> impossible $ "fluid ref unbound: " <> show fv <> " at: " <> show at
    Just x -> return x

fluidSet :: FluidVar -> (SrcLoc, DLArg) -> DFApp a -> DFApp a
fluidSet fv fvv = local (\e@DFEnv {..} -> e {eFVE = M.insert fv fvv eFVE})

withWhileFVMap :: FVMap -> DFApp a -> DFApp a
withWhileFVMap fvm' = local (\e -> e {eFVMm = Just fvm'})

readWhileFVMap :: DFApp FVMap
readWhileFVMap = do
  DFEnv {..} <- ask
  case eFVMm of
    Nothing -> impossible "attempt to read fvm with no fvm"
    -- Do not treat the `tokens` array as mutable in loops.
    Just x -> return $ M.delete FV_tokens x

unpackFVMap :: SrcLoc -> DKTail -> DFApp DKTail
unpackFVMap at k = do
  fvm <- readWhileFVMap
  let go k' (fv, dv) = DK_Com (DKC_FluidSet at fv (DLA_Var dv)) k'
  let k' = foldl' go k (M.toList fvm)
  return $ k'

block_unpackFVMap :: SrcLoc -> DKBlock -> DFApp DKBlock
block_unpackFVMap uat (DKBlock at fs t a) =
  (\x -> DKBlock at fs x a) <$> unpackFVMap uat t

expandFromFVMap :: SrcLoc -> DLAssignment -> DFApp DLAssignment
expandFromFVMap at (DLAssignment updatem) = do
  fvm <- readWhileFVMap
  let go (fv, dv) = do
        (_, da) <- fluidRef at fv
        return $ (dv, da)
  fvm'l <- mapM go $ M.toList fvm
  let updatem' = M.union (M.fromList $ fvm'l) updatem
  return $ DLAssignment updatem'

tokenInfoType :: DFApp DLType
tokenInfoType = do
  eBals <- asks eBals
  return $ T_Array tokenInfoElemTy eBals

tokenArrType :: DFApp DLType
tokenArrType = do
  eBals <- asks eBals
  return $ T_Array T_Token eBals

assign :: SrcLoc -> DLVar -> DLExpr -> DLStmt
assign at dv de = DL_Let at (DLV_Let DVC_Many dv) de

mkVar :: SrcLoc -> String -> DLType -> DFApp DLVar
mkVar at lab ty = DLVar at (Just (at, lab)) ty <$> df_allocVar

lookupTokenIdx :: SrcLoc -> DLArg -> DLArg -> DFApp ([DLStmt], DLArg)
lookupTokenIdx at tok toks = do
  let asn = assign at
  let accTy = T_Tuple [T_Bool, T_UInt]
  init_acc_dv <- mkVar at "initAcc" $ accTy
  acc_dv <- mkVar at "acc" $ accTy
  reduce_res <- mkVar at "res" $ accTy
  succ_acc <- mkVar at "succAcc" $ accTy
  bl_res <- mkVar at "bl" $ accTy
  fail_acc <- mkVar at "failAcc" $ accTy
  elem_dv <- mkVar at "elem" T_Token
  tok_idx <- mkVar at "tokIdx" T_UInt
  idx' <- mkVar at "searchIdx'" T_UInt
  idx <- mkVar at "searchIdx" T_UInt
  toks_eq <- mkVar at "toksEq" T_Bool
  cnd <- mkVar at "cnd" T_Bool
  found <- mkVar at "isFound" T_Bool
  found' <- mkVar at "isFound'" T_Bool
  i_dv <- mkVar at "arrIdx" T_UInt
  -- ([is_found, idx], tok') =>
  --    let acc' = (is_found || tok == tok') ? [ true, idx ] : [ false, idx + 1 ];
  --    return acc';
  let block_tl =
        DT_Com (asn found $ DLE_TupleRef at (DLA_Var acc_dv) 0) $
        DT_Com (asn idx $ DLE_TupleRef at (DLA_Var acc_dv) 1) $
        DT_Com (asn toks_eq $ DLE_PrimOp at TOKEN_EQ [DLA_Var elem_dv, tok]) $
        DT_Com (asn cnd $ DLE_PrimOp at IF_THEN_ELSE [DLA_Var found, DLA_Literal $ DLL_Bool True, DLA_Var toks_eq]) $
        DT_Com (asn idx' $ DLE_PrimOp at ADD [DLA_Var idx, DLA_Literal $ DLL_Int at 1]) $
        DT_Com (asn fail_acc $ DLE_LArg at $ DLLA_Tuple [DLA_Literal $ DLL_Bool False, DLA_Var idx']) $
        DT_Com (asn succ_acc $ DLE_LArg at $ DLLA_Tuple [DLA_Literal $ DLL_Bool True, DLA_Var idx]) $
        DT_Com (asn bl_res $ DLE_PrimOp at IF_THEN_ELSE [DLA_Var cnd, DLA_Var succ_acc, DLA_Var fail_acc]) $
        DT_Return at
  let bl = DLBlock at [] block_tl $ DLA_Var bl_res
  let ss =
        [ asn init_acc_dv $ DLE_LArg at $ DLLA_Tuple [DLA_Literal $ DLL_Bool False, DLA_Literal $ DLL_Int at 0]
        , DL_ArrayReduce at reduce_res [toks] (DLA_Var init_acc_dv) acc_dv [elem_dv] i_dv bl
        , asn tok_idx $ DLE_TupleRef at (DLA_Var reduce_res) 1
        , asn found' $ DLE_TupleRef at (DLA_Var reduce_res) 0
        , DL_Let at DLV_Eff $ DLE_Claim at [] CT_Assert (DLA_Var found') $ Just "Token is tracked" ]
  return (ss, DLA_Var tok_idx)

df_com :: HasCallStack => (DLStmt -> a -> a) -> (DKTail -> DFApp a) -> DKTail -> DFApp a
df_com mkk back = \case
  DK_Com (DKC_FluidSet at fv da) k -> do
    fluidSet fv (at, da) (back k)
  DK_Com (DKC_FluidRef at dv fv) k -> do
    (at', da) <- fluidRef at fv
    mkk <$> (pure $ DL_Let at (DLV_Let DVC_Many dv) (DLE_Arg at' da)) <*> back k
  DK_Com (DKC_TokenMetaGet meta at res tok mpos) k -> do
    let asn = assign at
    (_, tokA)  <- fluidRef at FV_tokens
    (_, infos) <- fluidRef at FV_tokenInfos
    (lookup_ss, idx) <- case mpos of
              Just i  -> return ([], DLA_Literal $ DLL_Int at $ fromIntegral i)
              Nothing -> lookupTokenIdx at tok tokA
    let meta_idx = fromIntegral $ fromEnum meta
    tokInfo <- mkVar at "tokInfo" tokenInfoElemTy
    let ss =
          [ asn tokInfo $ DLE_ArrayRef at infos idx
          , asn res $ DLE_TupleRef at (DLA_Var tokInfo) meta_idx ]
    rst <- flip (foldr mkk) ss <$> back k
    return $ foldr mkk rst lookup_ss
  DK_Com (DKC_TokenMetaSet meta at tok newVal mpos init_tok) k -> do
    let asn = assign at
    (_, tokA) <- fluidRef at FV_tokens
    (_, infos) <- fluidRef at FV_tokenInfos
    (lookup_ss, idx) <- case mpos of
      Just i -> return ([], DLA_Literal $ DLL_Int at $ fromIntegral i)
      Nothing -> lookupTokenIdx at tok tokA
    infoTy <- tokenInfoType
    info <- mkVar at "tokInfo" tokenInfoElemTy
    infos' <- mkVar at "tokInfos'" infoTy
    info' <- mkVar at "tokInfo'" tokenInfoElemTy
    bal <- mkVar at "tokBal" $ T_UInt
    supply <- mkVar at "tokSupply" $ T_UInt
    destroyed <- mkVar at "destroyed" $ T_Bool
    let infoAt = DLE_TupleRef at (DLA_Var info)
    let bs =
          [ asn info $ DLE_ArrayRef at infos idx
          , asn bal $ infoAt 0
          , asn supply $ infoAt 1
          , asn destroyed $ infoAt 2
          , asn info' $ DLE_LArg at $ DLLA_Tuple
            [ if meta == TM_Balance   then newVal else DLA_Var bal
            , if meta == TM_Supply    then newVal else DLA_Var supply
            , if meta == TM_Destroyed then newVal else DLA_Var destroyed
            ]
          , asn infos' $ DLE_ArraySet at infos idx (DLA_Var info')
          ]
    let fs = DKC_FluidSet at FV_tokenInfos $ DLA_Var infos'
    -- If we're initializing a token's balance, set the appropriate
    -- index in the `tokens` array to `tok`
    as <-
      case init_tok of
        False -> return [fs]
        True -> do
          tokA' <- mkVar at "tokens'" =<< tokenArrType
          return [ fs
                 , DKC_Let at (DLV_Let DVC_Many tokA') $ DLE_ArraySet at tokA idx tok
                 , DKC_FluidSet at FV_tokens $ DLA_Var tokA' ]
    rst <- flip (foldr mkk) bs <$> rec (foldl' (flip DK_Com) k as)
    return $ foldr mkk rst lookup_ss
  DK_Com m k -> do
    m' <-
      case m of
        DKC_Let a b c -> do
          return $ DL_Let a b c
        DKC_ArrayMap a b c d e x -> DL_ArrayMap a b c d e <$> df_bl x
        DKC_ArrayReduce a b c d e f g x -> DL_ArrayReduce a b c d e f g <$> df_bl x
        DKC_Var a b -> return $ DL_Var a b
        DKC_Set a b c -> return $ DL_Set a b c
        DKC_LocalDo a x -> DL_LocalDo a <$> df_t x
        DKC_LocalIf a b x y -> DL_LocalIf a b <$> df_t x <*> df_t y
        DKC_LocalSwitch a b x -> DL_LocalSwitch a b <$> mapM go x
          where
            go (c, vu, y) = (,,) c vu <$> df_t y
        DKC_MapReduce a mri b c d e f x -> DL_MapReduce a mri b c d e f <$> df_bl x
        DKC_Only a b c -> DL_Only a (Left b) <$> df_t c
        _ -> impossible "df_com"
    mkk m' <$> back k
  DK_ViewIs _ _ _ _ k ->
    -- This can only occur inside of the while cond & invariant and it is safe
    -- to throw out
    back k
  t -> impossible $ show $ "df_com " <> pretty t
  where
    rec = df_com mkk back

df_bl :: DKBlock -> DFApp DLBlock
df_bl (DKBlock at fs t a) =
  DLBlock at fs <$> df_t t <*> pure a

df_t :: DKTail -> DFApp DLTail
df_t = \case
  DK_Stop at -> return $ DT_Return at
  x -> df_com (mkCom DT_Com) df_t x

df_con :: DKTail -> DFApp LLConsensus
df_con = \case
  DK_If a c t f ->
    LLC_If a c <$> df_con t <*> df_con f
  DK_Switch a v csm ->
    LLC_Switch a v <$> mapM cm1 csm
    where
      cm1 (dv', b, c) = (\x -> (dv', b, x)) <$> df_con c
  DK_While at asn inv cond body k -> do
    fvs <- eFVs <$> ask
    let go fv = do
          r <- fluidRefm fv
          case r of
            Nothing -> return $ Nothing
            Just _ -> do
              ty <- case fv of
                      FV_tokenInfos -> tokenInfoType
                      FV_tokens -> tokenArrType
                      _ -> return $ fluidVarType fv
              dv <- DLVar at (Just (sb, show $ pretty fv)) ty <$> df_allocVar
              return $ Just (fv, dv)
    fvm <- M.fromList <$> catMaybes <$> mapM go fvs
    let body_fvs' = df_con =<< unpackFVMap at body
    --- Note: The invariant and condition can't return
    let block b = df_bl =<< block_unpackFVMap at b
    (makeWhile, k') <-
      withWhileFVMap fvm $
        (,) <$> (LLC_While at <$> expandFromFVMap at asn <*> block inv <*> block cond <*> body_fvs') <*> (unpackFVMap at k)
    makeWhile <$> df_con k'
  DK_Continue at asn ->
    LLC_Continue at <$> expandFromFVMap at asn
  DK_LiftBoundary at t -> do
    -- This was formerly done inside of Eval.hs, but that meant that these refs
    -- and sets would dominate the lifted ones in the step body, which defeats
    -- the purpose of lifting fluid variable interactions, so we instead build
    -- it into this pass
    tct <- fluidRef at FV_thisConsensusTime
    tcs <- fluidRef at FV_thisConsensusSecs
    fluidSet FV_lastConsensusTime tct $
      fluidSet FV_lastConsensusSecs tcs $
        fluidSet FV_baseWaitTime tct $
          fluidSet FV_baseWaitSecs tcs $
            df_con t
  DK_FromConsensus at1 at2 fs t -> do
    LLC_FromConsensus at1 at2 fs <$> df_step t
  DK_ViewIs at vn vk mva k -> do
    mva' <- maybe (return $ Nothing) (\eb -> Just <$> df_eb eb) mva
    k' <- df_con k
    return $ LLC_ViewIs at vn vk mva' k'
  x -> df_com (mkCom LLC_Com) df_con x

df_step :: DKTail -> DFApp LLStep
df_step = \case
  DK_Stop at -> return $ LLS_Stop at
  DK_ToConsensus at send recv mtime -> do
    lt <- fmap snd <$> fluidRefm FV_thisConsensusTime
    let tt = dr_time recv
    ls <- fmap snd <$> fluidRefm FV_thisConsensusSecs
    let ts = dr_secs recv
    k' <-
      df_con $
        DK_Com (DKC_Let at DLV_Eff (DLE_TimeOrder at [(lt, tt), (ls, ts)])) $
          dr_k recv
    let recv' = recv {dr_k = k'}
    mtime' <-
      case mtime of
        Nothing -> return $ Nothing
        Just (ta, tk) -> do
          tk' <- df_step tk
          return $ Just (ta, tk')
    let lt' = fromMaybe (DLA_Literal $ DLL_Int at 0) lt
    return $ LLS_ToConsensus at lt' send recv' mtime'
  x -> df_com (mkCom LLS_Com) df_step x

df_eb :: DKExportBlock -> DFApp DLExportBlock
df_eb (DLinExportBlock at vs b) =
  DLinExportBlock at vs <$> df_bl b

-- Initialize the fluid arrays
df_init :: DKTail -> DFApp DKTail
df_init k = do
  eBals <- asks eBals
  infoTy <- tokenInfoType
  infoA <- mkVar sb "tokInfos" infoTy
  tokA  <- mkVar sb "tokens" $ T_Array T_Token eBals
  info  <- mkVar sb "initialInfo" tokenInfoElemTy
  let false = DLA_Literal $ DLL_Bool False
  let zero  = DLA_Literal $ DLL_Int sb 0
  let tokz  = DLA_Constant DLC_Token_zero
  let infos = map DLA_Var $ take (fromIntegral eBals) $ repeat info
  let asn v e = DKC_Let sb (DLV_Let DVC_Many v) e
  let cs =
        [ asn info $ DLE_LArg sb $ DLLA_Tuple [zero, zero, false]
        , asn infoA $ DLE_LArg sb $ DLLA_Array tokenInfoElemTy infos
        , DKC_FluidSet sb FV_tokenInfos $ DLA_Var infoA
        -- We keep a separate array for the token references so we can treat the token positions
        -- as if they are static once initialized.
        , asn tokA $ DLE_LArg sb $ DLLA_Array T_Token $ take (fromIntegral eBals) $ repeat tokz
        , DKC_FluidSet sb FV_tokens $ DLA_Var tokA
        ]
  return $ foldr DK_Com k cs

defluid :: DKProg -> IO LLProg
defluid (DKProg at (DLOpts {..}) sps dli dex dvs das devts k) = do
  let llo_verifyArithmetic = dlo_verifyArithmetic
  let llo_untrustworthyMaps = dlo_untrustworthyMaps
  let llo_counter = dlo_counter
  let llo_droppedAsserts = dlo_droppedAsserts
  let opts' = LLOpts {..}
  let eCounter_df = getCounter opts'
  let eFVMm = mempty
  let eFVE = mempty
  let eFVs = allFluidVars
  let eBals = fromIntegral dlo_bals - 1
  flip runReaderT (DFEnv {..}) $ do
    dex' <- mapM df_eb dex
    k' <- df_step =<< df_init k
    return $ LLProg at opts' sps dli dex' dvs das devts k'

-- Stich it all together
linearize :: (forall a. Pretty a => T.Text -> a -> IO ()) -> DLProg -> IO LLProg
linearize outm p =
  return p >>= out "dk" dekont >>= out "lc" liftcon >>= out "df" defluid >>= out "fu" freshen_top
  where
    out lab f p' = do
      p'' <- f p'
      outm lab p''
      return p''
