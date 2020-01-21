[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Overview
Provides an adapter for using the package [database](https://pub.dev/packages/database) with
[PostgreSQL](https://www.postgresql.org/). The implementation relies on the package
[postgres](https://pub.dev/packages/postgres).

## Links
  * [Issue tracker in Github](https://github.com/dint-dev/database/issues)
  * [Source code in Github](https://github.com/dint-dev/database/tree/master/adapters/postgre/lib)
  * [API reference](https://pub.dev/documentation/database_adapter_postgre/latest/database_adapter_postgre/Postgre-class.html)

# Getting started
## 1.Add dependency
```yaml
dependencies:
  database: any
  database_adapter_postgre: any
```

## 2.Configure
```dart
import 'package:database/database.dart';
import 'package:database/sql.dart';
import 'package:database_adapter_postgre/database_adapter_postgre.dart';

Future main() async {
  final config = Postgre(
    host: 'localhost',
    port: 5432,
    user: 'your username',
    password: 'your password',
    databaseName: 'example',
  );

  final sqlClient = config.database().sqlClient;

  final result = await sqlClient.query('SELECT name FROM employee').toRows();
  for (var row in result.rows) {
    print('Name: ${row[0]}');
  }
}
```