[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Overview
Provides an adapter for using the package [database](https://pub.dev/packages/database) with
[SQLite](https://www.postgresql.org/). The implementation uses the package
[sqflite](https://pub.dev/packages/sqflite).

## Links
  * [Issue tracker in Github](https://github.com/dint-dev/database/issues)
  * [Source code in Github](https://github.com/dint-dev/database/tree/master/adapters/sqlite/lib)
  * [API reference](https://pub.dev/documentation/database_adapter_sqlite/latest/database_adapter_sqlite/SQLite-class.html)

# Getting started
## 1.Add dependency
```yaml
dependencies:
  database: any
  database_adapter_sqlite: any
```

## 2.Configure
```dart
import 'package:database/database.dart';
import 'package:database/sql.dart';
import 'package:database_adapter_sqlite/database_adapter_sqlite.dart';

Future main() async {
  final config = SQLite(
    path: 'path/to/database.db',
  );

  final sqlClient = config.database().sqlClient;

  final result = await database.querySql('SELECT name FROM employee').toRows();
  for (var row in result.rows) {
    print('Name: ${row[0]}');
  }
}
```