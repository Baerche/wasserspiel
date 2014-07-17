ME=$(git config --get user.name)
REPO=https://github.com/Baerche/wasserspiel.git

WELT=17jul1710
WELT=syntaxtest

NAME=inspektor
NAME=debugger

CLEANUP="xrandr --size 1280x1024"

BIN=~/freeminer-4.9.3-git/bin/freeminer; MAP_WORLDS=$HOME/.freeminer/worlds; CLEANUP="xrandr --size 1280x1024"

BIN=~/minetest-4.10-git/bin/minetest; MAP_WORLDS=$HOME/.minetest/worlds; CLEANUP=""

BIN=minetest; MAP_WORLDS=$HOME/.minetest/worlds; CLEANUP=""


CMD="$BIN"

CMD="$BIN --config ../user/$ME/minetest.conf"

CMD="$BIN --config ../user/$ME/minetest.conf --name $NAME --password pass --worldname $WELT --go"


