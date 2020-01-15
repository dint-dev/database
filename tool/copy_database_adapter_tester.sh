#!/bin/bash
set -e
cd `dirname $0`/..

COPIED="database/test/database_adapter_tester.dart"
echo "-------------------------------------------------"
echo "Copying '$COPIED'"
echo "-------------------------------------------------"

visit() {
  DEST=$1
  echo "  --> $DEST"
  cp $COPIED $DEST/test/copy_of_database_adapter_tester.dart
}

visit adapters/algolia
visit adapters/elasticsearch
visit adapters/firestore_browser
visit adapters/firestore_flutter
visit adapters/postgre

visit adapters_incubator/azure
visit adapters_incubator/grpc