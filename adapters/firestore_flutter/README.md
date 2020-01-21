[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Introduction
This package enables you to connect [database](https://pub.dev/packages/database) (a vendor-agnostic
database API with many adapters) to [Google Cloud Firestore](https://cloud.google.com/firestore/).

__This package requires Flutter__ (iOS / Android) because the package relies on
[cloud_firestore](https://pub.dev/packages/cloud_firestore). The package
[database_adapter_firestore_browser](https://pub.dev/packages/database_adapter_firestore_browser)
can be used in any browser application.

## Links
  * [Issue tracker in Github](https://github.com/dint-dev/database/issues)
  * [Source code in Github](https://github.com/dint-dev/database/tree/master/adapters/firestore_flutter/lib)
  * [API reference](https://pub.dev/documentation/database_adapter_firestore_flutter/latest/database_adapter_firestore_flutter/FirestoreFlutter-class.html)

# Getting started
## 1.Add dependency
```yaml
dependencies:
  database: any
  database_adapter_firestore_flutter: any
```

## 2.Configure the plugin
Follow instructions for [cloud_firestore](https://pub.dev/packages/cloud_firestore):
  * [Instructions for Android](https://firebase.google.com/docs/android/setup#add_the_sdk)
  * [Instructions for iOS](https://firebase.google.com/docs/ios/setup)


## 3.Configure database
```dart
import 'package:database/database.dart';
import 'package:database_adapter_firestore_flutter/database_adapter_firestore_flutter.dart';

Database getDatabase() {
  return FirestoreFlutter().database();
}

Future main() async {
  final database = getDatabase();
  final document = await database.collection('greetings').insert({
    'greeting': 'Hello world!',
  });
}
```

Read more about [database.dart API](https://pub.dev/packages/database).
