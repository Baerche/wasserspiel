#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/.

S=$PWD
D0=$HOME/.minetest/mods
mkdir $D0 -p

M=tutorial
D=$D0/$M
rm $D -f
ln -s $S/$M $D

M=wasserspiel
D=$D0/$M
rm $D -f
ln -s $S/$M $D

ls -l $D0


