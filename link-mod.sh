#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

S=$PWD/versionen
D0=$HOME/.minetest/mods
mkdir $D0 -p

M=wasserspiel_dev
D=$D0/$M
rm $D -f
ln -s $PWD/$M $D

find $D0 -name "wasserspiel_???_*" -maxdepth 1 -exec echo rm -f {} \;
find $D0 -name "wasserspiel_???_*" -maxdepth 1 -exec rm -f {} \;
ls $D0
find $S -name "wasserspiel_???_*" -maxdepth 1 -exec echo ln -s {} $D0 \;
find $S -name "wasserspiel_???_*" -maxdepth 1 -exec ln -s {} $D0 \;

ls -l $D0


