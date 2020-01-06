[![Github Actions CI](https://github.com/terrier989/datastore/workflows/Dart%20CI/badge.svg)](https://github.com/terrier989/datastore/actions?query=workflow%3A%22Dart+CI%22)

# Overview
This package helps information retrieval in Dart applications.

_SearchableDatastore_ wraps any other _Datastore_ ([package:datastore](https://pub.dev/packages/datastore)).
Current implementation simply calculates score for every document in the document collection, which
is usually an acceptable strategy in mobile and web applications. This package is not meant to be
used when collections are too large to fit the memory, which is often the case in the server-side.

Licensed under the [Apache License 2.0](LICENSE).

## Contributing
  * [github.com/terrier989/datastore](https://github.com/terrier989/datastore)

# Getting started
In _pubspec.yaml_:
```yaml
dependencies:
  datastore: any
  search: any
```

In _lib/main.dart_:
```dart
import 'package:datastore/datastore.dart';
import 'package:search/search.dart';

void main() {
  Datastore.freezeDefaultInstance(
    SearchableDatastore(
      datastore: MemoryDatastore(), // The underlying datastore can be anything.
    ),
  );

  // ...

  final datastore = Datastore.defaultInstance;
  final collection = datastore.collection('employee');
  final collectionSnapshot = await collection.search(
    query: Query.parse(
      '"software developer" (dart OR javascript)',
      skip: 0,
      take: 10,
    ),
  );
}
```