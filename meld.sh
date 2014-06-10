#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

meld /home/baerchen/minebaerchen/wasserspiel_dev /home/baerchen/minebaerchen/wasserspiel_base/wasserspiel

