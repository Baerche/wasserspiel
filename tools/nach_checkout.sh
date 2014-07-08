#!/bin/sh
#
# linke mod hierhin, auf linux.

set -eu
IFS='
'
cd $(dirname $0)/..

MOD=${PWD##*/}

D0=$HOME/.minetest/mods
mkdir $D0 -p
D=$D0/$MOD
trash-put $D
ln -s $PWD $D

D0=$HOME/.freeminer/mods
mkdir $D0 -p
D=$D0/$MOD
trash-put $D
ln -s $PWD $D

D0=$HOME/minetest-4.10-git/mods
mkdir $D0 -p
D=$D0/$MOD
trash-put $D
#ln -s $PWD $D # benutzt .minetest/mods

D0=$HOME/freeminer-4.9.3-git/mods
mkdir $D0 -p
D=$D0/$MOD
trash-put $D
#ln -s $PWD $D benutzt .freeminer/mods


