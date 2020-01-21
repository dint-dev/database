// Copyright 2019 Gohilla Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of database.sql;

/// SQL client for accessing a [Database].
///
/// ```
/// final results = client.query('SELECT * FROM person').readMapStream();
///
/// await client.table('person').insert({'name': 'Alan Turing'});
/// await client.table('person').deleteWhere{{'name': 'Alan Turing'});
/// ```
class SqlClient extends SqlClientBase {
  /// Database.
  final Database database;

  /// Has [close] been called?
  bool _isClosed = false;

  /// Constructs a new SQL client.
  ///
  /// You can optionally define the reach of the
  SqlClient(this.database);

  /// Is the client closed?
  bool get isClosed => _isClosed;

  /// Releases resources that may be associated with this client. After closing,
  /// any attempt to communicate with the database using this client should
  /// throw [StateError].
  ///
  /// This method can be called multiple times.
  @mustCallSuper
  Future close() {
    _isClosed = true;
    return Future.value();
  }

  @override
  Future<SqlStatementResult> rawExecute(SqlStatement sqlSource) {
    if (_isClosed) {
      throw StateError('close() has been called');
    }
    return SqlStatementRequest(sqlSource).delegateTo(database.adapter);
  }

  @override
  Future<SqlIterator> rawQuery(SqlStatement sqlSource) {
    if (_isClosed) {
      throw StateError('close() has been called');
    }
    return SqlQueryRequest(sqlSource).delegateTo(database.adapter);
  }

  /// Runs the function in a transaction.
  ///
  /// ```
  /// await sqlClient.runInTransaction((sqlClient) {
  ///   // ...
  /// }, timeout: Duration(seconds:2));
  /// ```
  Future<void> runInTransaction(
    Future<void> Function(SqlTransaction sqlTransaction) callback, {
    Duration timeout,
  }) {
    return SqlTransactionRequest(
      sqlClient: this,
      callback: callback,
      timeout: timeout,
    ).delegateTo(database.adapter);
  }
}

/// Superclass of both [SqlClient] and [SqlTransaction].
abstract class SqlClientBase {
  Future<void> createTable(String tableName) async {
    final b = SqlSourceBuilder();
    b.write('CREATE TABLE ');
    b.identifier(tableName);
    final sqlSource = b.build();
    await execute(sqlSource.value, sqlSource.arguments);
  }

  Future<void> dropTable(String tableName) async {
    final b = SqlSourceBuilder();
    b.write('DROP TABLE ');
    b.identifier(tableName);
    final sqlSource = b.build();
    await execute(sqlSource.value, sqlSource.arguments);
  }

  /// Performs a SQL statement. The SQL statement should be INSERT, UPDATE,
  /// DELETE, or a schema changing statement such as CREATE.
  ///
  /// String '?' is used for expressing locations of arguments.
  ///
  /// ```
  /// await sqlClient.execute(
  ///   'INSERT INTO product (name, price) VALUES (?, ?)',
  ///   ['shampoo', 8],
  /// );
  /// ```
  Future<SqlStatementResult> execute(String sql, [List arguments]) {
    return rawExecute(SqlStatement(sql, arguments));
  }

  /// Performs a SQL query. The SQL statement should be a SELECT statement.
  ///
  /// String '?' is used for expressing locations of arguments.
  ///
  /// ```
  /// await sqlClient.query(
  ///   'SELECT product (name, price) WHERE price < ? AND quantity >= ?',
  ///   [8, 1],
  /// );
  /// ```
  SqlClientTableQueryHelper query(String sql, [List arguments]) {
    return SqlClientTableQueryHelper._(this, SqlStatement(sql, arguments));
  }

  Future<SqlStatementResult> rawExecute(SqlStatement source);

  Future<SqlIterator> rawQuery(SqlStatement source);

  /// Returns a helper for building SQL statements.
  ///
  /// ```
  /// await client.table('person').insert({'name': 'Alan Turing'});
  /// await client.table('person').deleteWhere({'name': 'Alan Turing'});
  /// ```
  SqlClientTableHelper table(String name) {
    return SqlClientTableHelper._(this, name);
  }
}
