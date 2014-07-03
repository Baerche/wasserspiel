#!/bin/sh
set -eu
IFS='
'
cd $(dirname $0)/..

meld ws_dev ws_default
