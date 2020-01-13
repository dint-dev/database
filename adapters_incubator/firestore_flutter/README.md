# Introduction
This adapters enables the package [database](https://github.com/dint-dev/database) to use
the package [cloud_firestore](https://pub.dev/packages/cloud_firestore).

Licensed under the [Apache License 2.0](LICENSE).

__Warning:__ this adapter does not pass all tests yet.

# Getting started
## 1.Add dependency
In _pubspec.yaml_:
```yaml
dependencies:
  database: any
  database_adapter_firestore_flutter: any
```

## 2.Configure database
In _lib/main.dart_:
```dart
import 'package:database/database.dart';
import 'package:database_adapter_firestore_flutter/adapter.dart';

void main() {
  Database.freezeDefaultInstance(
    Firestore(
      appId: "APP ID",
      apiKey: "API KEY",
    ),
  );

  // ...
}
```
