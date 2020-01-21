# Overview
Provides an adapter for using the package [database](https://pub.dev/packages/database) with
[PostgreSQL](https://www.postgresql.org/). The implementation relies on the package
[postgres](https://pub.dev/packages/postgres).

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