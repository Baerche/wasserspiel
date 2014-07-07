#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/..

W=wasserspiel
WW=$HOME/.minetest/worlds

W=welt
WW=$HOME/minetest-4.10-git/worlds

W=pur
WW=$HOME/.freeminer/worlds


I=$WW/$W.png
M=/tmp/mapping
pwd
mkdir -p maps
cd maps
mkdir -p $M
cp -a $WW/$W/* $M
python ~/minetestmapper/minetestmapper.py -i $M -o $I --draworigin --drawscale  --drawplayers
# --drawplayers 
echo done
#nautilus .
eog -f $WW/$W.png &
