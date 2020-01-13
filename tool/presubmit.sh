#!/bin/bash
ARGS=$@
set -e
cd `dirname $0`/..

# Format
echo "-------------------------------------------------"
echo "Running dartfmt --fix -w ."
echo "-------------------------------------------------"
dartfmt --fix -w .

#
# Test
#
./tool/test.sh