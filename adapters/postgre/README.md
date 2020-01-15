# Overview
This is enables use API of the package [database](https://pub.dev/packages/database) with
[PostgreSQL](https://www.postgresql.org/).

The adapter uses the package [postgres](https://pub.dev/packages/postgres).

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
import 'package:database_adapter_postgre/adapter.dart';

void main() {
  final database = Postgre(
    host: 'localhost',
    port: 1234,
    user: 'your username',
    password: 'your password',
  );
}
```