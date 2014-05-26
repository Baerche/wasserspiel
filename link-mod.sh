#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/.

S=$PWD
D0=$HOME/.minetest/mods
D=$D0/minebaerchen
mkdir $D0 -p
rm $D -f
ln -s $S $D
ls -l $D0


