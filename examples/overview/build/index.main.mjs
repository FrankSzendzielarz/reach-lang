// Automatically generated with Reach 0.1.2
/* eslint-disable */
export const _version = '0.1.2';


export const getExports = (s) => {
  const stdlib = s.reachStdlib;

 return ({})
 
};

export async function Alice(ctc, interact) {
  const stdlib = ctc.stdlib;
  const ctc0 = stdlib.T_Bytes(stdlib.checkedBigNumberify('<builtin>', stdlib.UInt_max, 128));
  const ctc1 = stdlib.T_UInt;
  const ctc2 = stdlib.T_Tuple([]);
  const ctc3 = stdlib.T_Address;
  const ctc4 = stdlib.T_Tuple([ctc1, ctc3, ctc1, ctc1]);
  const ctc5 = stdlib.T_Tuple([ctc1, ctc3, ctc1]);
  const ctc6 = stdlib.T_Tuple([ctc1, ctc1]);
  const ctc7 = stdlib.T_Tuple([ctc1]);
  
  
  const v20 = await ctc.creationTime();
  const v18 = stdlib.protect(ctc0, interact.info, null);
  const v19 = stdlib.protect(ctc1, interact.request, null);
  const txn1 = await (ctc.sendrecv(1, 1, stdlib.checkedBigNumberify('./index.rsh:14:9:dot', stdlib.UInt_max, 0), [ctc1, ctc1], [v20, v19], [stdlib.checkedBigNumberify('./index.rsh:decimal', stdlib.UInt_max, 0), []], [ctc1], true, true, false, (async (txn1) => {
    const sim_r = { txns: [] };
    sim_r.prevSt = stdlib.digest(ctc6, [stdlib.checkedBigNumberify('./index.rsh:14:9:dot', stdlib.UInt_max, 0), v20]);
    sim_r.prevSt_noPrevTime = stdlib.digest(ctc7, [stdlib.checkedBigNumberify('./index.rsh:14:9:dot', stdlib.UInt_max, 0)]);
    const [v24] = txn1.data;
    const v27 = txn1.time;
    const v23 = txn1.from;
    
    stdlib.assert(true, {
      at: './index.rsh:14:9:dot',
      fs: [],
      msg: null,
      who: 'Alice'
       });
    ;
    stdlib.assert(true, {
      at: './index.rsh:14:9:dot',
      fs: [],
      msg: 'sender correct',
      who: 'Alice'
       });
    sim_r.nextSt = stdlib.digest(ctc4, [stdlib.checkedBigNumberify('./index.rsh:15:15:after expr stmt semicolon', stdlib.UInt_max, 1), v23, v24, v27]);
    sim_r.nextSt_noTime = stdlib.digest(ctc5, [stdlib.checkedBigNumberify('./index.rsh:15:15:after expr stmt semicolon', stdlib.UInt_max, 1), v23, v24]);
    sim_r.isHalt = false;
    
    return sim_r;
     })));
  const [v24] = txn1.data;
  const v27 = txn1.time;
  const v23 = txn1.from;
  stdlib.assert(true, {
    at: './index.rsh:14:9:dot',
    fs: [],
    msg: null,
    who: 'Alice'
     });
  ;
  stdlib.assert(true, {
    at: './index.rsh:14:9:dot',
    fs: [],
    msg: 'sender correct',
    who: 'Alice'
     });
  const txn2 = await (ctc.recv(2, 0, [], false, false));
  const [] = txn2.data;
  const v33 = txn2.time;
  const v30 = txn2.from;
  stdlib.assert(true, {
    at: './index.rsh:19:9:dot',
    fs: [],
    msg: null,
    who: 'Alice'
     });
  ;
  stdlib.assert(true, {
    at: './index.rsh:19:9:dot',
    fs: [],
    msg: 'sender correct',
    who: 'Alice'
     });
  const txn3 = await (ctc.sendrecv(3, 1, stdlib.checkedBigNumberify('./index.rsh:24:9:dot', stdlib.UInt_max, 2), [ctc3, ctc1, ctc1, ctc0], [v23, v24, v33, v18], [stdlib.checkedBigNumberify('./index.rsh:decimal', stdlib.UInt_max, 0), []], [ctc0], true, true, false, (async (txn3) => {
    const sim_r = { txns: [] };
    sim_r.prevSt = stdlib.digest(ctc4, [stdlib.checkedBigNumberify('./index.rsh:24:9:dot', stdlib.UInt_max, 2), v23, v24, v33]);
    sim_r.prevSt_noPrevTime = stdlib.digest(ctc5, [stdlib.checkedBigNumberify('./index.rsh:24:9:dot', stdlib.UInt_max, 2), v23, v24]);
    const [v37] = txn3.data;
    const v41 = txn3.time;
    const v36 = txn3.from;
    
    stdlib.assert(true, {
      at: './index.rsh:24:9:dot',
      fs: [],
      msg: null,
      who: 'Alice'
       });
    ;
    const v40 = stdlib.addressEq(v23, v36);
    stdlib.assert(v40, {
      at: './index.rsh:24:9:dot',
      fs: [],
      msg: 'sender correct',
      who: 'Alice'
       });
    sim_r.txns.push({
      amt: v24,
      to: v23,
      tok: undefined
       });
    sim_r.nextSt = stdlib.digest(ctc2, []);
    sim_r.nextSt_noTime = stdlib.digest(ctc2, []);
    sim_r.isHalt = true;
    
    return sim_r;
     })));
  const [v37] = txn3.data;
  const v41 = txn3.time;
  const v36 = txn3.from;
  stdlib.assert(true, {
    at: './index.rsh:24:9:dot',
    fs: [],
    msg: null,
    who: 'Alice'
     });
  ;
  const v40 = stdlib.addressEq(v23, v36);
  stdlib.assert(v40, {
    at: './index.rsh:24:9:dot',
    fs: [],
    msg: 'sender correct',
    who: 'Alice'
     });
  ;
  return;
  
  
  
   }
export async function Bob(ctc, interact) {
  const stdlib = ctc.stdlib;
  const ctc0 = stdlib.T_UInt;
  const ctc1 = stdlib.T_Null;
  const ctc2 = stdlib.T_Bytes(stdlib.checkedBigNumberify('<builtin>', stdlib.UInt_max, 128));
  const ctc3 = stdlib.T_Address;
  const ctc4 = stdlib.T_Tuple([ctc0, ctc3, ctc0, ctc0]);
  const ctc5 = stdlib.T_Tuple([ctc0, ctc3, ctc0]);
  
  
  const v20 = await ctc.creationTime();
  const txn1 = await (ctc.recv(1, 1, [ctc0], false, false));
  const [v24] = txn1.data;
  const v27 = txn1.time;
  const v23 = txn1.from;
  stdlib.assert(true, {
    at: './index.rsh:14:9:dot',
    fs: [],
    msg: null,
    who: 'Bob'
     });
  ;
  stdlib.assert(true, {
    at: './index.rsh:14:9:dot',
    fs: [],
    msg: 'sender correct',
    who: 'Bob'
     });
  stdlib.protect(ctc1, await interact.want(v24), {
    at: './index.rsh:18:22:application',
    fs: ['at ./index.rsh:17:13:application call to [unknown function] (defined at: ./index.rsh:17:17:function exp)'],
    msg: 'want',
    who: 'Bob'
     });
  const txn2 = await (ctc.sendrecv(2, 0, stdlib.checkedBigNumberify('./index.rsh:19:9:dot', stdlib.UInt_max, 2), [ctc3, ctc0, ctc0], [v23, v24, v27], [v24, []], [], true, true, false, (async (txn2) => {
    const sim_r = { txns: [] };
    sim_r.prevSt = stdlib.digest(ctc4, [stdlib.checkedBigNumberify('./index.rsh:19:9:dot', stdlib.UInt_max, 1), v23, v24, v27]);
    sim_r.prevSt_noPrevTime = stdlib.digest(ctc5, [stdlib.checkedBigNumberify('./index.rsh:19:9:dot', stdlib.UInt_max, 1), v23, v24]);
    const [] = txn2.data;
    const v33 = txn2.time;
    const v30 = txn2.from;
    
    stdlib.assert(true, {
      at: './index.rsh:19:9:dot',
      fs: [],
      msg: null,
      who: 'Bob'
       });
    ;
    stdlib.assert(true, {
      at: './index.rsh:19:9:dot',
      fs: [],
      msg: 'sender correct',
      who: 'Bob'
       });
    sim_r.nextSt = stdlib.digest(ctc4, [stdlib.checkedBigNumberify('./index.rsh:20:15:after expr stmt semicolon', stdlib.UInt_max, 2), v23, v24, v33]);
    sim_r.nextSt_noTime = stdlib.digest(ctc5, [stdlib.checkedBigNumberify('./index.rsh:20:15:after expr stmt semicolon', stdlib.UInt_max, 2), v23, v24]);
    sim_r.isHalt = false;
    
    return sim_r;
     })));
  const [] = txn2.data;
  const v33 = txn2.time;
  const v30 = txn2.from;
  stdlib.assert(true, {
    at: './index.rsh:19:9:dot',
    fs: [],
    msg: null,
    who: 'Bob'
     });
  ;
  stdlib.assert(true, {
    at: './index.rsh:19:9:dot',
    fs: [],
    msg: 'sender correct',
    who: 'Bob'
     });
  const txn3 = await (ctc.recv(3, 1, [ctc2], false, false));
  const [v37] = txn3.data;
  const v41 = txn3.time;
  const v36 = txn3.from;
  stdlib.assert(true, {
    at: './index.rsh:24:9:dot',
    fs: [],
    msg: null,
    who: 'Bob'
     });
  ;
  const v40 = stdlib.addressEq(v23, v36);
  stdlib.assert(v40, {
    at: './index.rsh:24:9:dot',
    fs: [],
    msg: 'sender correct',
    who: 'Bob'
     });
  ;
  stdlib.protect(ctc1, await interact.got(v37), {
    at: './index.rsh:29:21:application',
    fs: ['at ./index.rsh:28:13:application call to [unknown function] (defined at: ./index.rsh:28:17:function exp)'],
    msg: 'got',
    who: 'Bob'
     });
  return;
  
  
  
   }

const _ALGO = {
  appApproval: `#pragma version 3
// Check that we're an App
txn TypeEnum
int appl
==
assert
txn RekeyTo
global ZeroAddress
==
assert
// Check that everyone's here
global GroupSize
int 3
>=
assert
// Check txnAppl (us)
txn GroupIndex
int 0
==
assert
// Check txnFromHandler
int 0
gtxn 2 Sender
byte "{{m1}}"
==
||
gtxn 2 Sender
byte "{{m2}}"
==
||
gtxn 2 Sender
byte "{{m3}}"
==
||
assert
byte base64(cw==)
app_global_get
gtxna 0 ApplicationArgs 0
==
assert
byte base64(bA==)
app_global_get
gtxna 0 ApplicationArgs 4
btoi
==
assert
// Don't check anyone else, because Handler does
// Update state
byte base64(cw==)
gtxna 0 ApplicationArgs 1
app_global_put
byte base64(bA==)
global Round
app_global_put
byte base64(aA==)
gtxna 0 ApplicationArgs 2
btoi
app_global_put
byte base64(aA==)
app_global_get
bnz halted
txn OnCompletion
int NoOp
==
assert
b done
halted:
txn OnCompletion
int DeleteApplication
==
assert
done:
int 1
return
`,
  appApproval0: `#pragma version 3
// Check that we're an App
txn TypeEnum
int appl
==
assert
txn RekeyTo
global ZeroAddress
==
assert
txn Sender
byte "{{Deployer}}"
==
assert
txn ApplicationID
bz init
global GroupSize
int 2
==
assert
txn OnCompletion
int UpdateApplication
==
assert
byte base64(cw==)
// compute state in HM_Set 0
int 0
itob
keccak256
app_global_put
byte base64(bA==)
global Round
app_global_put
byte base64(aA==)
int 0
app_global_put
b done
init:
global GroupSize
int 1
==
assert
txn OnCompletion
int NoOp
==
assert
done:
int 1
return
`,
  appClear: `#pragma version 3
// We're alone
global GroupSize
int 1
==
assert
// We're halted
byte base64(aA==)
app_global_get
int 1
==
assert
done:
int 1
return
`,
  ctc: `#pragma version 3
// Check size
global GroupSize
int 3
>=
assert
// Check txnAppl
gtxn 0 TypeEnum
int appl
==
assert
gtxn 0 ApplicationID
byte "{{ApplicationID}}"
btoi
==
assert
// Don't check anything else, because app does
// Check us
txn TypeEnum
int pay
==
assert
txn RekeyTo
global ZeroAddress
==
assert
global ZeroAddress
byte "{{Deployer}}"
global GroupSize
int 1
-
txn GroupIndex
==
gtxna 0 ApplicationArgs 2
btoi
&&
select
txn CloseRemainderTo
==
assert
txn GroupIndex
int 3
>=
assert
done:
int 1
return
`,
  stepargs: [0, 89, 121, 249],
  steps: [null, `#pragma version 3
// Handler 1
// Check txnAppl
gtxn 0 TypeEnum
int appl
==
assert
gtxn 0 ApplicationID
byte "{{ApplicationID}}"
btoi
==
assert
gtxn 0 NumAppArgs
int 6
==
assert
// Check txnToHandler
gtxn 1 TypeEnum
int pay
==
assert
gtxn 1 Receiver
txn Sender
==
assert
gtxn 1 Amount
gtxn 2 Fee
int 100000
+
==
assert
// Check txnFromHandler (us)
txn GroupIndex
int 2
==
assert
txn TypeEnum
int pay
==
assert
txn Amount
int 0
==
assert
txn Receiver
gtxn 1 Sender
==
assert
// compute state in HM_Check 0
int 0
itob
keccak256
gtxna 0 ApplicationArgs 0
==
assert
txn CloseRemainderTo
gtxn 1 Sender
==
assert
// Run body
// Nothing
// "./index.rsh:14:9:dot"
// "[]"
int 1
assert
// CheckPay
// "./index.rsh:14:9:dot"
// "[]"
gtxn 3 TypeEnum
int pay
==
assert
gtxn 3 Receiver
byte "{{ContractAddr}}"
==
assert
gtxn 3 Amount
gtxna 0 ApplicationArgs 3
btoi
-
int 0
==
assert
// Just "sender correct"
// "./index.rsh:14:9:dot"
// "[]"
int 1
assert
// compute state in HM_Set 1
int 1
itob
gtxn 0 Sender
concat
gtxna 0 ApplicationArgs 5
concat
keccak256
gtxna 0 ApplicationArgs 1
==
assert
gtxna 0 ApplicationArgs 2
btoi
int 0
==
assert
b done
// Check GroupSize
global GroupSize
int 4
==
assert
gtxna 0 ApplicationArgs 3
btoi
gtxn 3 Fee
==
assert
// Check time limits
done:
int 1
return
`, `#pragma version 3
// Handler 2
// Check txnAppl
gtxn 0 TypeEnum
int appl
==
assert
gtxn 0 ApplicationID
byte "{{ApplicationID}}"
btoi
==
assert
gtxn 0 NumAppArgs
int 7
==
assert
// Check txnToHandler
gtxn 1 TypeEnum
int pay
==
assert
gtxn 1 Receiver
txn Sender
==
assert
gtxn 1 Amount
gtxn 2 Fee
int 100000
+
==
assert
// Check txnFromHandler (us)
txn GroupIndex
int 2
==
assert
txn TypeEnum
int pay
==
assert
txn Amount
int 0
==
assert
txn Receiver
gtxn 1 Sender
==
assert
// compute state in HM_Check 1
int 1
itob
gtxna 0 ApplicationArgs 5
concat
gtxna 0 ApplicationArgs 6
concat
keccak256
gtxna 0 ApplicationArgs 0
==
assert
txn CloseRemainderTo
gtxn 1 Sender
==
assert
// Run body
// Nothing
// "./index.rsh:19:9:dot"
// "[]"
int 1
assert
// CheckPay
// "./index.rsh:19:9:dot"
// "[]"
gtxn 3 TypeEnum
int pay
==
assert
gtxn 3 Receiver
byte "{{ContractAddr}}"
==
assert
gtxn 3 Amount
gtxna 0 ApplicationArgs 3
btoi
-
gtxna 0 ApplicationArgs 6
btoi
==
assert
// Just "sender correct"
// "./index.rsh:19:9:dot"
// "[]"
int 1
assert
// compute state in HM_Set 2
int 2
itob
gtxna 0 ApplicationArgs 5
concat
gtxna 0 ApplicationArgs 6
concat
keccak256
gtxna 0 ApplicationArgs 1
==
assert
gtxna 0 ApplicationArgs 2
btoi
int 0
==
assert
b done
// Check GroupSize
global GroupSize
int 4
==
assert
gtxna 0 ApplicationArgs 3
btoi
gtxn 3 Fee
==
assert
// Check time limits
done:
int 1
return
`, `#pragma version 3
// Handler 3
// Check txnAppl
gtxn 0 TypeEnum
int appl
==
assert
gtxn 0 ApplicationID
byte "{{ApplicationID}}"
btoi
==
assert
gtxn 0 NumAppArgs
int 8
==
assert
// Check txnToHandler
gtxn 1 TypeEnum
int pay
==
assert
gtxn 1 Receiver
txn Sender
==
assert
gtxn 1 Amount
gtxn 2 Fee
int 100000
+
==
assert
// Check txnFromHandler (us)
txn GroupIndex
int 2
==
assert
txn TypeEnum
int pay
==
assert
txn Amount
int 0
==
assert
txn Receiver
gtxn 1 Sender
==
assert
// compute state in HM_Check 2
int 2
itob
gtxna 0 ApplicationArgs 5
concat
gtxna 0 ApplicationArgs 6
concat
keccak256
gtxna 0 ApplicationArgs 0
==
assert
txn CloseRemainderTo
gtxn 1 Sender
==
assert
// Run body
// Nothing
// "./index.rsh:24:9:dot"
// "[]"
int 1
assert
// CheckPay
// "./index.rsh:24:9:dot"
// "[]"
gtxn 3 TypeEnum
int pay
==
assert
gtxn 3 Receiver
byte "{{ContractAddr}}"
==
assert
gtxn 3 Amount
gtxna 0 ApplicationArgs 3
btoi
-
int 0
==
assert
// Just "sender correct"
// "./index.rsh:24:9:dot"
// "[]"
gtxna 0 ApplicationArgs 5
gtxn 0 Sender
==
assert
gtxn 4 TypeEnum
int pay
==
assert
gtxn 4 Receiver
gtxna 0 ApplicationArgs 5
==
assert
gtxn 4 Amount
gtxna 0 ApplicationArgs 6
btoi
==
assert
gtxn 4 Sender
byte "{{ContractAddr}}"
==
assert
gtxn 5 TypeEnum
int pay
==
assert
// We don't check the receiver
gtxn 5 Amount
int 0
==
assert
gtxn 5 Sender
byte "{{ContractAddr}}"
==
assert
gtxna 0 ApplicationArgs 2
btoi
int 1
==
assert
b done
// Check GroupSize
global GroupSize
int 6
==
assert
gtxna 0 ApplicationArgs 3
btoi
gtxn 5 Fee
gtxn 4 Fee
+
gtxn 3 Fee
+
==
assert
// Check time limits
done:
int 1
return
`],
  unsupported: false
   };
const _ETH = {
  ABI: `[
  {
    "inputs": [],
    "stateMutability": "payable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [],
    "name": "e0",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "uint256",
                "name": "v20",
                "type": "uint256"
              }
            ],
            "internalType": "struct T0",
            "name": "svs",
            "type": "tuple"
          },
          {
            "components": [
              {
                "internalType": "uint256",
                "name": "v24",
                "type": "uint256"
              }
            ],
            "internalType": "struct T2",
            "name": "msg",
            "type": "tuple"
          }
        ],
        "indexed": false,
        "internalType": "struct T3",
        "name": "_a",
        "type": "tuple"
      }
    ],
    "name": "e1",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "address payable",
                "name": "v23",
                "type": "address"
              },
              {
                "internalType": "uint256",
                "name": "v24",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "v27",
                "type": "uint256"
              }
            ],
            "internalType": "struct T1",
            "name": "svs",
            "type": "tuple"
          },
          {
            "internalType": "bool",
            "name": "msg",
            "type": "bool"
          }
        ],
        "indexed": false,
        "internalType": "struct T6",
        "name": "_a",
        "type": "tuple"
      }
    ],
    "name": "e2",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "address payable",
                "name": "v23",
                "type": "address"
              },
              {
                "internalType": "uint256",
                "name": "v24",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "v33",
                "type": "uint256"
              }
            ],
            "internalType": "struct T4",
            "name": "svs",
            "type": "tuple"
          },
          {
            "components": [
              {
                "internalType": "uint8[128]",
                "name": "v37",
                "type": "uint8[128]"
              }
            ],
            "internalType": "struct T7",
            "name": "msg",
            "type": "tuple"
          }
        ],
        "indexed": false,
        "internalType": "struct T8",
        "name": "_a",
        "type": "tuple"
      }
    ],
    "name": "e3",
    "type": "event"
  },
  {
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "uint256",
                "name": "v20",
                "type": "uint256"
              }
            ],
            "internalType": "struct T0",
            "name": "svs",
            "type": "tuple"
          },
          {
            "components": [
              {
                "internalType": "uint256",
                "name": "v24",
                "type": "uint256"
              }
            ],
            "internalType": "struct T2",
            "name": "msg",
            "type": "tuple"
          }
        ],
        "internalType": "struct T3",
        "name": "_a",
        "type": "tuple"
      }
    ],
    "name": "m1",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "address payable",
                "name": "v23",
                "type": "address"
              },
              {
                "internalType": "uint256",
                "name": "v24",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "v27",
                "type": "uint256"
              }
            ],
            "internalType": "struct T1",
            "name": "svs",
            "type": "tuple"
          },
          {
            "internalType": "bool",
            "name": "msg",
            "type": "bool"
          }
        ],
        "internalType": "struct T6",
        "name": "_a",
        "type": "tuple"
      }
    ],
    "name": "m2",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {
            "components": [
              {
                "internalType": "address payable",
                "name": "v23",
                "type": "address"
              },
              {
                "internalType": "uint256",
                "name": "v24",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "v33",
                "type": "uint256"
              }
            ],
            "internalType": "struct T4",
            "name": "svs",
            "type": "tuple"
          },
          {
            "components": [
              {
                "internalType": "uint8[128]",
                "name": "v37",
                "type": "uint8[128]"
              }
            ],
            "internalType": "struct T7",
            "name": "msg",
            "type": "tuple"
          }
        ],
        "internalType": "struct T8",
        "name": "_a",
        "type": "tuple"
      }
    ],
    "name": "m3",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "stateMutability": "payable",
    "type": "receive"
  }
]`,
  Bytecode: `0x608060408190527f49ff028a829527a47ec6839c7147b484eccf5a2a94853eddac09cef44d9d4e9e90600090a160408051602080820183524382528251808201845260008082529251815283518083018490529051818501528351808203850181526060909101909352825192019190912090556104fa806100826000396000f3fe6080604052600436106100385760003560e01c80632438df70146100445780639532ef0114610059578063f512f77e1461006c5761003f565b3661003f57005b600080fd5b6100576100523660046103ae565b61007f565b005b610057610067366004610397565b61018c565b61005761007a3660046103bf565b610269565b60405161009390600190839060200161047f565b6040516020818303038152906040528051906020012060001c600054146100b957600080fd5b60008055346020820135146100cd57600080fd5b7f1ca594b20641191c893d80895212a20239e99e17b7304a35c096140ec34f22dd816040516100fc91906103fa565b60405180910390a1610131604051806060016040528060006001600160a01b0316815260200160008152602001600081525090565b61013e6020830183610376565b6001600160a01b0316815260208083013581830152436040808401919091525161016d91600291849101610493565b60408051601f1981840301815291905280516020909101206000555050565b60408051600060208201528235918101919091526060016040516020818303038152906040528051906020012060001c600054146101c957600080fd5b6000805534156101d857600080fd5b6040805182358152602080840135908201527ff2c62eba998811305a23599b2e6d212befbd7ded3a73f4c08bfb9aefe08dc166910160405180910390a1610242604051806060016040528060006001600160a01b0316815260200160008152602001600081525090565b33815260208083013581830152436040808401919091525161016d91600191849101610493565b60405161027d90600290839060200161047f565b6040516020818303038152906040528051906020012060001c600054146102a357600080fd5b6000805534156102b257600080fd5b336102c06020830183610376565b6001600160a01b0316146102d357600080fd5b6102e06020820182610376565b6040516001600160a01b039190911690602083013580156108fc02916000818181858888f1935050505015801561031b573d6000803e3d6000fd5b507f6ca511835aec60423a26d24cdbe1d3b53c20c6d05a3c891aed1744e1f97974bf8160405161034b919061042a565b60405180910390a16000805533ff5b80356001600160a01b038116811461037157600080fd5b919050565b600060208284031215610387578081fd5b6103908261035a565b9392505050565b6000604082840312156103a8578081fd5b50919050565b6000608082840312156103a8578081fd5b600061106082840312156103a8578081fd5b6001600160a01b036103e28261035a565b16825260208181013590830152604090810135910152565b6080810161040882846103d1565b606083013580151580821461041c57600080fd5b806060850152505092915050565b611060810161043982846103d1565b60608201606084016000805b608081101561047557823560ff811680821461045f578384fd5b8552506020938401939290920191600101610445565b5050505092915050565b8281526080810161039060208301846103d1565b82815260808101610390602083018480516001600160a01b031682526020808201519083015260409081015191015256fea264697066735822122094d54e3722e55428721afd9cc3e5711dd6690d6d6542894a4f585fd20820be5664736f6c63430008030033`,
  deployMode: `DM_constructor`
   };

export const _Connectors = {
  ALGO: _ALGO,
  ETH: _ETH
   };

