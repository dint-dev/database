# Introduction
__Warning:__ This package is not ready for production systems.

This package enables you to connect [database](https://pub.dev/packages/database) (a vendor-agnostic
database API with many adapters) to [Google Cloud Firestore](https://cloud.google.com/firestore/).

__This package requires Flutter__ (iOS / Android) because the package relies on
[cloud_firestore](https://pub.dev/packages/cloud_firestore). The package
[database_adapter_firestore_browser](https://pub.dev/packages/database_adapter_firestore_browser)
can be used in any browser application.

## Links
  * [Source code in Github](https://github.com/dint-dev/database/tree/master/adapters/firestore_flutter/lib)

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
