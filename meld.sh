#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)

meld wasserspiel_dev wasserspiel_devb

