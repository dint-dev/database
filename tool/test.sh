#!/bin/bash
set -e
cd `dirname $0`/..

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
  export $(cat SECRETS.env | xargs)
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
  if [[ $NAME == *"/"* ]]; then
    cd ../..
  else
    cd ..
  fi
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
  if [[ $NAME == *"/"* ]]; then
    cd ../..
  else
    cd ..
  fi
}

visit database
visit search

visit         adapters/algolia
visit         adapters/firestore_browser

visit         samples/example
visit_flutter samples/example_flutter