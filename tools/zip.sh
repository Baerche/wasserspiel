#!/bin/sh
set -eux
IFS='
'
cd $(dirname $0)/..
. user/$(git config --get user.name)/config.sh

W=wasserspiel
Z=$PWD/$W.wiki/$W.zip

#git remote add origin $REPO
git remote -v | grep fetch

git remote -v | grep fetch >version.txt
git log -1 >>version.txt

# hackerei um den mod-namen als directory zu kriegen
mkdir -p t
trash-put t/wasserspiel
ln -s $PWD t/wasserspiel
cd t
#zip --help
trash-put $Z
zip -r $Z   $W/*.lua $W/ws_*    $W/*.md $W/version.txt  $W/LICENSE
cd -

cd wasserspiel.wiki
cp ../version.txt .
git gui

