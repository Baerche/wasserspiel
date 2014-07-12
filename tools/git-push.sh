#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/..

S=$PWD
D="$HOME/Zoho Docs/minebaerchen"

git status
cd $D
git pull $S

