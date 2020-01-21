[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

Connects the package [database](https://pub.dev/packages/database) to [Algolia](https://www.algolia.io).

## Links
  * [Issue tracker in Github](https://github.com/dint-dev/database/issues)
  * [Source code in Github](https://github.com/dint-dev/database/tree/master/adapters/algolia/lib/)
  * [API reference](https://pub.dev/documentation/database_adapter_algolia/latest/database_adapter_algolia/Algolia-class.html)

# Getting started
## 1.Add dependency
```yaml
dependencies:
  database: any
  database_adapter_algolia: any
```

## 2.Use it!
```dart
import 'package:database/database.dart';
import 'package:database_adapter_algolia/database_adapter_algolia.dart';

Database getSearchEngine() {
 return Algolia(
   appId: 'Your application ID',
   apiKey: 'Your API key',
 );
}
```