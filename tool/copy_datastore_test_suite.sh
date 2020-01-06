#!/bin/bash
set -e
cd `dirname $0`/..

COPIED="packages/datastore/test/datastore_test_suite.dart"
echo "-------------------------------------------------"
echo "Copying '$COPIED'"
echo "-------------------------------------------------"

visit() {
  NAME=$1
  echo "  --> $NAME"
  cp $COPIED packages/$NAME/test/copy_of_datastore_test_suite.dart
}

visit datastore_adapter_cloud_firestore