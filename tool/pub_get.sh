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
  OLD_PATH=`pwd`
  cd $NAME
  if hash pub; then
    pub get $ARGS
  else
    flutter pub get $ARGS
  fi
  cd $OLD_PATH
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
  OLD_PATH=`pwd`
  cd $NAME
  flutter pub get $ARGS
  cd $OLD_PATH
}

visit         database
visit         search

visit         adapters/algolia
visit         adapters/elasticsearch
visit         adapters/firestore_browser
visit_flutter adapters/firestore_flutter
visit_flutter adapters/firestore_flutter/example
visit         adapters/postgre
visit_flutter adapters/sqlite
visit_flutter adapters/sqlite/example
visit         adapters_incubator/azure
visit         adapters_incubator/grpc

visit         samples/example
visit_flutter samples/example_flutter