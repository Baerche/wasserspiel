#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/../..
pwd


cd downloads
P=$HOME/.minetest/mods/my_defaultpack
mkdir -p $P



M=mobs
U=https://github.com/PilzAdam/mobs/zipball/master
Z=$M.zip
D=PilzAdam-mobs-c49cc47
wget -c $U -O $Z
trash-put $D
unzip $Z
trash-put $P/$M
ln $PWD/$D $P/$M



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


