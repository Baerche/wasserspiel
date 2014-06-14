#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

meld wasserspiel_dev wasserspiel_devb
#meld ../minebaerchen/minebaerchen_dev/minebaerchen.lua wasserspiel_dev/wasserspiel.lua

