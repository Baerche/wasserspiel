ME=$(git config --get user.name)

WELT=mapgenv7
WELT=410welt
WELT=mobs

NAME=inspektor
NAME=debugger

#xrandr --size 1280x1024

BIN=minetest; MAP_WORLDS=$HOME/.minetest/worlds
BIN=~/freeminer-4.9.3-git/bin/freeminer; MAP_WORLDS=$HOME/.freeminer/worlds

BIN=~/minetest-4.10-git/bin/minetest; MAP_WORLDS=$HOME/.minetest/worlds


CMD="$BIN"

CMD="$BIN --config ../user/$ME/minetest.conf"

CMD="$BIN --config ../user/$ME/minetest.conf --name $NAME --password pass --worldname $WELT --go"

