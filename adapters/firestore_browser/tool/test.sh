#!/bin/bash
set -e
cd `dirname $0`/..

# You can pass arguments.
#
# Example:
#   ./tool/test.sh --platform=vm
#
ARGS=${@:1}

if [ -f ../../SECRETS.env ]; then
  echo "-------------------------------------------------"
  echo "Loading environmental variables from 'SECRETS.env'"
  echo "(An optional file for local testing)"
  echo "-------------------------------------------------"
  source ../../SECRETS.env
fi

pub run test $ARGS