# Overview
Provides an adapter for using the package [database](https://pub.dev/packages/database) with
[SQLite](https://www.postgresql.org/). The implementation uses the package
[sqflite](https://pub.dev/packages/sqflite).

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