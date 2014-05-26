#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/.

S=$PWD
D="$HOME/Zoho Docs/minebaerchen"

cd $D
git pull $S
git log

