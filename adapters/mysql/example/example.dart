import 'package:database_adapter_mysql/database_adapter_mysql.dart';

Future main() async {
  final database = MysqlAdapter(
    user: 'root',
    password: '1234',
    databaseName: 'testdb',
  ).database();

  await database.sqlClient.createTable('TableName');
  await database.sqlClient.dropTable('TableName');

  // final iterator = await database.sqlClient.query(
  //   'SELECT (email) FROM users where id = ?',
  //   [1],
  // ).getIterator();

  // for (var row in await iterator.toRows()) {
  //   print('email: ${row[0]}');
  // }

  // final users = await database.sqlClient
  //     .table('Users')
  //     .whereColumn('email', equals: 'odunboye@gmail.com')
  //     // .descending('price')
  //     .select(columnNames: ['name', 'email']).toMaps();

  // print(users);
}
