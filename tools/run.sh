#!/bin/bash
set -eu -x
OIFS=$IFS
IFS='
'
cd $(dirname $0)/..
. user/$(git config --get user.name)/config.sh

pkill minetest || true
pkill freeminer || true
mkdir -p screenshots
cd screenshots

pwd
echo $CMD
IFS=$OIFS #hmm
($CMD; $CLEANUP)&
