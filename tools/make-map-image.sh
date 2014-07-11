#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/..
. user/$(git config --get user.name)/config.sh

W=$WELT
WW=$MAP_WORLDS

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
