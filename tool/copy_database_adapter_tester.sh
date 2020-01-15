#!/bin/bash
set -e
cd `dirname $0`/..
ROOT=`pwd`

COPIED="database/test/database_adapter_tester.dart"
echo "-------------------------------------------------"
echo "Copying '$COPIED'"
echo "-------------------------------------------------"

visit() {
  DEST=$1
  echo "  --> $DEST"
  cp $COPIED $DEST/test/copy_of_database_adapter_tester.dart
}

visit adapters/elasticsearch

visit adapters_incubator/algolia
visit adapters_incubator/azure
visit adapters_incubator/gcloud
visit adapters_incubator/grpc
visit adapters_incubator/firestore
visit adapters_incubator/firestore_flutter
visit adapters_incubator/mysql
visit adapters_incubator/postgre
visit adapters_incubator/sqlite