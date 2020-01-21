import 'package:database_adapter_postgre/database_adapter_postgre.dart';

Future main() async {
  final database = Postgre(
    host: 'localhost',
    port: 5432,
    user: 'your username',
    password: 'your password',
    databaseName: 'example',
  ).database();

  final iterator = await database.sqlClient
      .query(
        'SELECT (name) FROM employee',
      )
      .getIterator();

  for (var row in await iterator.toRows()) {
    print('Name: ${row[0]}');
  }
}
