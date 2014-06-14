#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

MOD=${PWD##*/}
echo ${MOD}

S=$PWD/versionen
D0=$HOME/.minetest/mods
mkdir $D0 -p

find $D0 -maxdepth 1 -name "${MOD}*" -exec echo rm -f {} \;
find $D0 -maxdepth 1 -name "${MOD}*"  -exec rm -f {} \;
ls $D0

M=${MOD}_dev
D=$D0/$M
rm $D -f
ln -s $PWD/$M $D

M=${MOD}_devb
D=$D0/$M
rm $D -f
ln -s $PWD/$M $D

M=${MOD}
D=$D0/$M
rm $D -f
ln -s $PWD $D

mkdir -p $S
find $S -maxdepth 1 -name "${MOD}_???_*" -exec echo ln -s {} $D0 \;
find $S -maxdepth 1 -name "${MOD}_???_*" -exec ln -s {} $D0 \;

ls -l $D0


