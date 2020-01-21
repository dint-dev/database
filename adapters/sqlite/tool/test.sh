#!/bin/bash
set -e
cd `dirname $0`/..

echo '-----------------------------------------------------------'
echo 'Running: flutter drive --target=test_driver/main.dart'
echo ''
echo 'If the build fails, try whether deleting 'example/build' helps.'
echo '-----------------------------------------------------------'

cd example
flutter pub get --offline
flutter drive --target=test_driver/app.dart