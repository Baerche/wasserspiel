#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

pwd
mkdir -p maps
cd maps
python ~/minetestmapper/minetestmapper.py -i ~/.minetest/worlds/wasserspiel
echo done
nautilus .