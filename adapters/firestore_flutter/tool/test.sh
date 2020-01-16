#!/bin/bash
set -e
cd `dirname $0`/..

echo '-----------------------------------------------------------'
echo 'Running: flutter drive --target=test_driver/main.dart'
echo '-----------------------------------------------------------'

SERVICES_JSON=example/android/app/google-services.json
if [ ! -f $SERVICES_JSON ]; then
  echo "Configuration file '$SERVICES_JSON' is not found!"
  exit
fi

cd example
flutter pub get --offline
flutter drive --target=test_driver/app.dart