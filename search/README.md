[![Pub Package](https://img.shields.io/pub/v/search.svg)](https://pub.dartlang.org/packages/search)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Overview
This is a simple information retrieval engine for the package
[database](https://pub.dev/packages/search).

Licensed under the [Apache License 2.0](LICENSE).

## How it works
### Iteration
`SearchableDatabase` wraps any other `Database` and intercepts search requests that contain
one or more `KeywordFilter` instances.

The current implementation then simply visits every document in the collection and calculates score
for each document. This is very inefficient strategy for large collections / many concurrent
requests. However, for typical mobile and web applications, this is fine!

### Preprocessing
In the preprocessing step, we simplify both the keyword and the inputs.

The following transformations are done:
  * String is converted to lowercase.
    * "John" --> " john "
  * Some extended Latin characters are replaced with simpler characters.
    * "Élysée" --> " elysee "
  * Some suffixes are removed.
    * "Joe's coffee" --> " joe coffee "
  * Multiple whitespace characters are replaced with a single space.
    * "hello,\n  world" --> " hello world "

### Scoring
The document scoring algorithm is very basic.

The high-level idea is to raise score for:
  * __More matches__
  * __Sequential matches__
  * __Matches of non-preprocessed strings__

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
    master: MemoryDatabaseAdapter(),
  ).database();
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