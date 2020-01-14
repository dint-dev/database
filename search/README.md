[![Pub Package](https://img.shields.io/pub/v/search.svg)](https://pub.dartlang.org/packages/search)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Overview
This is an information retrieval engine written in Dart.

Licensed under the [Apache License 2.0](LICENSE).

__Warning:__ expect many breaking changes before the project freezes the APIs.

## How it works

`SearchableDatabase` wraps any other `Database` and intercepts search requests that contain
one or more `KeywordFilter` instances.

The current implementation then simply visits every document in the collection and calculates score
for each document. This is very inefficient strategy for large collections / many concurrent
requests. However, for typical mobile and web applications, this is fine!

In the preprocessing step, we simplify both keyword and:
  * Replace whitespace characters with a single space.
    * "hello,\n  world" --> " hello world "
  * Lowercase characters and replace some extended Latin characters with ASCII characters.
    * "Élysée" --> " elysee "
  * Remove some suffices
    * "Joe's coffee" --> " joe coffee "

The document scoring algorithm is a quick hack at the moment. It attempts to raise score for:
  * Higher count of substring search matches.
  * Substring search matches near each other.
  * Presence of exact (non-processed) substring matches.

## Contributing
  * [github.com/dint-dev/database](https://github.com/dint-dev/database)

# Getting started
In _pubspec.yaml_:
```yaml
dependencies:
  database: any
  search: any
```

In _lib/main.dart_:
```dart
import 'package:database/database.dart';
import 'package:search/search.dart';

void main() {
  final database = SearchableDatabase(
    database: MemoryDatabase(),
  );
  final collection = database.collection('employee');
  final result = await collection.search(
    query: Query.parse(
      '(Hello OR Hi) world!',
      skip: 0,
      take: 10,
    ),
  );
}
```