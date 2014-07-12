#!/bin/sh
set -eu -x
IFS='
'
cd $(dirname $0)/../..
pwd


cd downloads
MT=$HOME/.minetest/mods
FM=$HOME/.freeminer/mods
NUR_MT=$MT/wasserspiel_mtpack
NUR_FM=$FM/wasserspiel_frpack
BEIDE=$MT/wasserspiel_mixpack
NUR_MT_TEST=$MT/wasserspiel_testpack

trash-put $NUR_MT $NUR_FM $BEIDE $NUR_MT_TEST
mkdir -p $NUR_MT $NUR_FM $BEIDE $NUR_MT_TEST
trash-put $FM/wasserspiel_mixpack
ln -s $BEIDE $FM/wasserspiel_mixpack
echo >$NUR_MT/modpack.txt
echo >$NUR_FM/modpack.txt
echo >$BEIDE/modpack.txt
echo >$NUR_MT_TEST/modpack.txt




M=builtin_item
U=https://github.com/PilzAdam/${M}/archive/master.zip
P=$NUR_MT
Z=$M.zip
D=${M}-master
DM=$D #singlemod
#wget -c $U -O $Z
#unzip -l $Z; exit
trash-put $D
unzip $Z
trash-put $P/$M
ln -s $PWD/$DM $P/$M


U=https://github.com/PilzAdam/item_drop/archive/master.zip
M=item_drop
P=$NUR_MT
Z=$M.zip
D=item_drop-master
DM=$D #singlemod
#wget -c $U -O $Z
#unzip -l $Z; exit
trash-put $D
unzip $Z
trash-put $P/$M
ln -s $PWD/$DM $P/$M

M=mobs
U=https://github.com/PilzAdam/mobs/zipball/master
P=$NUR_MT_TEST
Z=$M.zip
D=PilzAdam-mobs-c49cc47
DM=$D #singlemod
#wget -c $U -O $Z
trash-put $D
unzip $Z
trash-put $P/$M
ln -s $PWD/$DM $P/$M

M=ambience
P=$BEIDE
U=https://github.com/Neuromancer56/MinetestAmbience/archive/master.zip
Z=MinetestAmbience.zip
D=MinetestAmbience-master
DM=$D/$M #aus modpack
#wget -c $U -O $Z
trash-put $D
unzip $Z
trash-put $P/$M
ln -s $PWD/$DM $P/$M


exit ### sachen drunter werden irgnoriert weil fertig



#geht nicht
#wget -c https://github.com/HybridDog/riesenpilz/archive/master.zip -O riesenpilz.zip

Z=MinetestAmbience.zip
S=MinetestAmbience-master
M=ambience
#wget -c https://github.com/Neuromancer56/MinetestAmbience/archive/master.zip -O $Z
trash-put $S
unzip $Z
trash-put $P/$M
mv $S/$M $P/$M

#wget -c http://realbadangel.pl/technic_ambience.zip #kaputt

Z=minetest-craft_guide.zip
S=minetest-craft_guide-master
D=craft_guide
#wget -c https://github.com/cornernote/minetest-craft_guide/archive/master.zip -O $Z
trash-put $S
unzip $Z
trash-put $P/$D
mv $S/$D $P/$D


