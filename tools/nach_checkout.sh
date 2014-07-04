#!/bin/sh
#
# linke mod hierhin, auf linux.

set -eu
IFS='
'
cd $(dirname $0)/..

MOD=${PWD##*/}
echo ${MOD}


D0=$HOME/.minetest/mods
mkdir $D0 -p
D=$D0/$MOD
trash-put $D
ln -s $PWD $D

D0=$HOME/minetest-4.10-git/mods
mkdir $D0 -p
D=$D0/$MOD
trash-put $D
ln -s $PWD $D


