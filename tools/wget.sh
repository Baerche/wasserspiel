#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/..

cd downloads
P=$HOME/.minetest/mods/my_defaultpack
mkdir -p $P

if true; then
Z=MinetestAmbience.zip
S=MinetestAmbience-master
M=ambience
#wget -c https://github.com/Neuromancer56/MinetestAmbience/archive/master.zip -O $Z
trash-put $S
unzip $Z
trash-put $P/$M
mv $S/$M $P/$M
fi

#wget -c http://realbadangel.pl/technic_ambience.zip #kaputt

if true; then
Z=minetest-craft_guide.zip
S=minetest-craft_guide-master
D=craft_guide
#wget -c https://github.com/cornernote/minetest-craft_guide/archive/master.zip -O minetest-craft_guide
trash-put $S
unzip $Z
trash-put $P/$D
mv $S/$D $P/$D
fi


