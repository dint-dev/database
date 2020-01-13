This is the official adapter for connecting the package [database](https://pub.dev/packages/database)
with MySQL / MariaDB databases. Depends on the package [mysql1](https://pub.dev/packages/mysql1) for
the actual implementation.

# Getting started
## 1.Add dependency
```yaml
dependencies:
  database: any
  database_adapter_mysql: any
```

## 2.Configure
```dart

import 'package:database/database.dart';
import 'package:database_adapter_postgre/adapter.dart';

void main() {
  final database = MySql(
    host: 'localhost',
    port: 1234,
    user: 'your username',
    password: 'your password',
  );
}
```