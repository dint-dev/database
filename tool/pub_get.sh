#!/bin/bash
set -e
cd `dirname $0`/..
ROOT=`pwd`

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
  cd $ROOT
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
  cd $ROOT
}

visit database
visit search
visit sql_database

visit adapters/elasticsearch

visit adapters_incubator/algolia
visit adapters_incubator/azure
visit adapters_incubator/firestore
visit_flutter adapters_incubator/firestore_flutter
visit adapters_incubator/gcloud
visit adapters_incubator/grpc
visit adapters_incubator/mysql
visit adapters_incubator/postgre
visit_flutter adapters_incubator/sqlite