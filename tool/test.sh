#!/bin/bash
set -e
cd `dirname $0`/..
ARGS=${@:1}

if [ -f SECRETS.env ]; then
  echo "-------------------------------------------------"
  echo "Loading environmental variables from 'SECRETS.env'"
  echo "-------------------------------------------------"
  source SECRETS.env
fi

visit() {
  NAME=$1
  echo "-------------------------------------------------"
  echo "Testing '$NAME'"
  echo "-------------------------------------------------"
  echo "Running: pub run test $ARGS"
  cd packages/$NAME
  pub run test $ARGS
  cd ../..
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
  cd packages/$NAME
  flutter test $ARGS
  cd ../..
}

visit datastore
visit_flutter datastore_adapter_cloud_firestore
visit search