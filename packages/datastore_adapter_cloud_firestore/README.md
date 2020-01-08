# Introduction
This adapters enables the package [datastore](https://github.com/terrier989/datastore) to use
the package [cloud_firestore](https://pub.dev/packages/cloud_firestore).

Licensed under the [Apache License 2.0](LICENSE).

__Warning:__ this adapter does not pass all tests yet.

# Getting started
## 1.Add dependency
In _pubspec.yaml_:
```yaml
dependencies:
  datastore: any
  datastore_adapter_cloud_firestore: any
```

## 2.Configure datastore
In _lib/main.dart_:
```dart
import 'package:datastore/datastore.dart';
import 'package:datastore_adapter_cloud_firestore/adapter.dart';

void main() {
  Datastore.freezeDefaultInstance(
    Firestore(
      appId: "APP ID",
      apiKey: "API KEY",
    ),
  );

  // ...
}
```
