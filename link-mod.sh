#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/.

S=$PWD
D0=$HOME/.minetest/mods
mkdir $D0 -p

M=mb_001_pitschnass
D=$D0/$M
rm $D -f
ln -s $S/versionen/$M $D

M=mb_002_saeulen
D=$D0/$M
rm $D -f
ln -s $S/versionen/$M $D

M=wasserspiel_003_locals
D=$D0/$M
rm $D -f
ln -s $S/versionen/$M $D

M=wasserspiel_004_aufraeumen
D=$D0/$M
rm $D -f
ln -s $S/versionen/$M $D

M=wasserspiel_005_pings
D=$D0/$M
rm $D -f
ln -s $S/versionen/$M $D

M=wasserspiel_dev
D=$D0/$M
rm $D -f
ln -s $S/$M $D

#M=mb_???_*
#D=$D0/$M
#rm $D -f
#ln -s $S/versionen/$M $D0

ls -l $D0


