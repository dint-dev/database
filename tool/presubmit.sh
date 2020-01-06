#!/bin/bash
ARGS=$@
set -e
cd `dirname $0`/..
cd packages

echo "-------------------------------------------------"
echo "Running dartfmt --fix -w ."
echo "-------------------------------------------------"
dartfmt --fix -w .

#
# Test
#
./tool/test.sh