#!/bin/sh -e

make build || exit 1

R="$(echo "$REACH_CONNECTOR_MODE" | cut -f 1 -d '-')"
R="${R:-ETH}"
D="devnet-$(echo "$R" | tr '[:upper:]' '[:lower:]')"

alias reach_bg='REACH_CONNECTOR_MODE=$R ../../reach'

rm -f Alice.in Alice.out Bob.in Bob.out
mkfifo Alice.in Alice.out Bob.in Bob.out || exit 1

reach_bg devnet >/dev/null 2>&1 &

printf 'Bringing up %s...' "$D"
while true; do
  if [ "$(docker ps -qf "label=sh.reach.devnet-for=$D" | wc -l)" -gt 0 ]; then break; fi
  printf '.'
  sleep 1
done
printf ' Done.\n'

reach_bg run index alice < Alice.in > Alice.out &
reach_bg run index bob   < Bob.in   > Bob.out   &

exec 3> Alice.in
exec 4< Alice.out
exec 5> Bob.in
exec 6< Bob.out
unlink Alice.in
unlink Alice.out
unlink Bob.in
unlink Bob.out

get_Alice() {
    echo Waiting for Alice...
    read -r REPLY <&4
    echo Alice:-: "$REPLY"
}
to_Alice() {
    echo Alice:+: "$@"
    echo "$@" >&3
}
get_Bob() {
    echo Waiting for Bob...
    read -r REPLY <&6
    echo "  Bob:-:" "$REPLY"
}
to_Bob() {
    echo "  Bob:+:" "$@"
    echo "$@" >&5
}

while [ "x$REPLY" != "xAre you Alice?" ] ; do
  get_Alice
done
to_Alice y
get_Alice
get_Alice
to_Alice y
get_Alice
to_Alice y
get_Alice
INFO=$(echo "$REPLY" | awk -F= '{print $2}')
get_Alice
get_Alice
to_Alice 10

while [ "x$REPLY" != "xAre you Alice?" ] ; do
  get_Bob
done
to_Bob n
get_Bob
get_Bob
to_Bob y
get_Bob
to_Bob n
get_Bob
to_Bob "$INFO"
get_Bob
get_Bob
to_Bob y

get_Alice
to_Alice r
get_Alice
get_Bob
to_Bob r
get_Bob

get_Alice
to_Alice s
get_Alice
get_Bob
to_Bob s
get_Bob

get_Alice
to_Alice r
get_Alice
get_Bob
to_Bob s
get_Bob

get_Alice
get_Bob
get_Alice
get_Bob
