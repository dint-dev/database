# Overview
This is an adapter for the package [database](https://pub.dev/packages/database) that connects it to
[Google Cloud Firestore](https://cloud.google.com/firestore/).

This package works only in browsers. The package [database_adapter_firestore_flutter](https://pub.dev/packages/database_adapter_firestore_flutter)
can be used in Flutter.

## Links
  * [Source code in Github](https://github.com/dint-dev/database/tree/master/adapters/firestore_browser/lib)

# Getting started
## 1.Add dependency
```yaml
dependencies:
  database: any
  database_adapter_firestore_browser: any
```

## 2.Use it!
```dart
import 'package:database/database.dart';
import 'package:database_adapter_firestore_browser/database_adapter_firestore_browser.dart';

Database getDatabase() {
  return FirestoreBrowser().database();
}
```