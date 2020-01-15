#!/bin/bash
set -e
cd `dirname $0`/..
ROOT=`pwd`

# You can pass arguments.
#
# Example:
#   ./tool/test.sh --platform=vm
#
ARGS=${@:1}

if [ -f SECRETS.env ]; then
  echo "-------------------------------------------------"
  echo "Loading environmental variables from 'SECRETS.env'"
  echo "(An optional file for local testing)"
  echo "-------------------------------------------------"
  source SECRETS.env
fi

visit() {
  NAME=$1
  echo "-------------------------------------------------"
  echo "Testing '$NAME'"
  echo "-------------------------------------------------"
  echo "Running: pub run test $ARGS"
  cd $NAME
  if hash pub; then
    pub run test $ARGS
  else
    flutter pub run test $ARGS
  fi
  cd $ROOT
}

visit_flutter() {
  if ! hash flutter; then
    return
  fi
  NAME=$1
  echo "-------------------------------------------------"
  echo "Testing '$NAME'"
  echo "-------------------------------------------------"
  echo "Running: pub run test $ARGS"
  cd $NAME
  flutter test $ARGS
  cd $ROOT
}

visit database
visit search
visit sql_database

visit adapters/elasticsearch