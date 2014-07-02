#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

W=wasserspiel

I=~/.minetest/worlds/$W.png
M=/tmp/mapping
pwd
mkdir -p maps
cd maps
mkdir -p $M
cp -a ~/.minetest/worlds/$W/* $M
python ~/minetestmapper/minetestmapper.py -i $M -o $I --draworigin --drawscale  --drawplayers
# --drawplayers 
echo done
#nautilus .
eog -f ~/.minetest/worlds/$W.png &
