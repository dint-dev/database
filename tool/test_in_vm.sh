#!/bin/bash
set -e
cd `dirname $0`/..

# You can pass arguments.
#
# Example:
#   ./tool/test.sh --platform=vm
#
ARGS="--platform=vm ${@:1}"

if [ -f SECRETS.env ]; then
  echo "-------------------------------------------------"
  echo "Loading environmental variables from 'SECRETS.env'"
  echo "(An optional file for local testing)"
  echo "-------------------------------------------------"
  export $(cat SECRETS.env | xargs)
fi

visit() {
  NAME=$1
  echo "-------------------------------------------------"
  echo "Testing '$NAME'"
  echo "-------------------------------------------------"
  OLD_PATH=`pwd`
  cd $NAME
  if hash pub; then
    echo "Running: pub run test $ARGS"
    pub run test $ARGS
  else
    echo "Running: flutter test $ARGS"
    flutter test $ARGS
  fi
  cd $OLD_PATH
}

visit database
visit search

visit adapters/algolia
visit adapters/elasticsearch
visit adapters/postgre