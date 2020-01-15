import 'package:database_adapter_postgre/database_adapter_postgre.dart';

Future main() async {
  final database = Postgre(
    host: 'localhost',
    port: 5432,
    user: 'your username',
    password: 'your password',
    databaseName: 'example',
  );

  final result = await database.querySql('SELECT (name) FROM employee');
  for (var row in result.rows) {
    print('Name: ${row[0]}');
  }
}
