#!/bin/bash
ARGS=$@
set -e
cd `dirname $0`/..
cd packages

visit() {
  NAME=$1
  echo "-------------------------------------------------"
  echo "Testing '$NAME'"
  echo "-------------------------------------------------"
  echo "Running: pub run test $ARGS"
  cd $NAME
  pub run test $ARGS
  cd ..
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
  cd ..
}

visit datastore
visit_flutter datastore_adapter_cloud_firestore
visit search