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

M=wasserspiel_base
D=$D0/$M
rm $D -f
#ln -s $PWD/$M $D

M=wasserspiel
D=$D0/$M
rm $D -f
ln -s $PWD $D

find $D0 -maxdepth 1 -name "wasserspiel_???_*" -exec echo rm -f {} \;
find $D0 -maxdepth 1 -name "wasserspiel_???_*"  -exec rm -f {} \;
ls $D0
find $S -maxdepth 1 -name "wasserspiel_???_*" -exec echo ln -s {} $D0 \;
find $S -maxdepth 1 -name "wasserspiel_???_*" -exec ln -s {} $D0 \;

ls -l $D0


