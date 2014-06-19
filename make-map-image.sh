#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

W=wasserspiel

pwd
mkdir -p maps
cd maps
python ~/minetestmapper/minetestmapper.py -i ~/.minetest/worlds/$W -o $W.png --draworigin --drawscale
# --drawplayers 
echo done
nautilus .
