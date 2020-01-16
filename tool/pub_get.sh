#!/bin/bash
set -e
cd `dirname $0`/..

# You can pass arguments.
#
# Example:
#   ./tool/pub_get.sh --offline
#
ARGS=${@:1}

visit() {
  NAME=$1
  echo "-------------------------------------------------"
  echo "Getting dependencies for '$NAME'"
  echo "-------------------------------------------------"
  echo "Running: pub get $ARGS"
  cd $NAME
  if hash pub; then
    pub get $ARGS
  else
    flutter pub get $ARGS
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
  echo "Getting dependencies for '$NAME'"
  echo "-------------------------------------------------"
  echo "Running: flutter pub get $ARGS"
  cd $NAME
  flutter pub get $ARGS
  if [[ $NAME == *"/"* ]]; then
    cd ../..
  else
    cd ..
  fi
}

visit database
visit search

visit         adapters/algolia
visit         adapters/elasticsearch
visit         adapters/firestore_browser
visit_flutter adapters/firestore_flutter
visit_flutter adapters/firestore_flutter/example
visit         adapters/postgre

visit         adapters_incubator/azure
visit         adapters_incubator/grpc