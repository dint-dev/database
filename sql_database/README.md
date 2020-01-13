# Overview
This is the official adapter for connecting the package [database](https://pub.dev/packages/database)
with Postgre databases. Depends on the package [postgre](https://pub.dev/packages/postgre) for the
actual implementation.

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