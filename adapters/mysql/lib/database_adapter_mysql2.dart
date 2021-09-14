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

import 'dart:async';
import 'dart:io' show SocketException;

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/sql.dart';
import 'package:meta/meta.dart';
import 'package:mysql1/mysql1.dart' as impl;

class MysqlAdapter extends SqlDatabaseAdapter {
  String host;
  int port;
  String user;
  String password;
  String databaseName;
  int characterSet;
  int maxPacketSize;
  Duration timeout;
  bool useCompression;
  bool useSSL;

  Future<impl.MySqlConnection> _connectionFuture;

  MysqlAdapter({
    @required this.user,
    @required this.password,
    @required this.databaseName,
    this.host = 'localhost',
    this.port = 3306,
    this.useCompression = false,
    this.useSSL = false,
    this.maxPacketSize = 16 * 1024 * 1024,
    this.timeout = const Duration(seconds: 30),
    this.characterSet = impl.CharacterSet.UTF8,
  }) {
    ArgumentError.checkNotNull(host, 'host');
    ArgumentError.checkNotNull(port, 'port');
    ArgumentError.checkNotNull(user, 'user');
    ArgumentError.checkNotNull(password, 'password');
    ArgumentError.checkNotNull(databaseName, 'databaseName');
  }

  @override
  Future<void> close() async {
    if (_connectionFuture != null) {
      try {
        final connection = await _connectionFuture;
        await connection.close();
      } catch (e) {
        // Ignore
      }
    }
    return super.close();
  }

  @override
  Future<SqlIterator> performSqlQuery(SqlQueryRequest request) async {
    final sql = request.sqlStatement.value;

    impl.MySqlConnection context;
    final sqlTransaction = request.sqlTransaction;
    if (sqlTransaction == null) {
      context = await _open();
    } else {
      context = (sqlTransaction as _MysqlTransaction)._context;
    }

    // Execute
    impl.Results results;
    try {
      results = await context.query(
        sql,
        request.sqlStatement.arguments,
      );
    } on SocketException {
      _connectionFuture = null;
      rethrow;
    } on impl.MySqlException catch (e) {
      throw DatabaseException.internal(
        message: 'MySQL exception ${e.errorNumber}: ${e.message}',
        error: e,
      );
    }

    //
    // Return
    //
    List<SqlColumnDescription> columnDescriptions;
    if (results.isNotEmpty) {
      columnDescriptions = results.fields.map((v) {
        return SqlColumnDescription(
          tableName: v.table,
          columnName: v.name,
        );
      }).toList(growable: false);
    }
    List<List<dynamic>> rows = [];
    for (var row in results) {
      rows.add(row);
    }

    return SqlIterator.fromLists(
      columnDescriptions: columnDescriptions,
      rows: rows,
    );
  }

  @override
  Future<SqlStatementResult> performSqlStatement(
    SqlStatementRequest request,
  ) async {
    final sql = request.sqlStatement.value;

    impl.MySqlConnection context;
    final sqlTransaction = request.sqlTransaction;
    if (sqlTransaction == null) {
      context = await _open();
    } else {
      context = (sqlTransaction as _MysqlTransaction)._context;
    }

    // Execute
    try {
      final affectedRows = await context.query(
        sql,
        request.sqlStatement.arguments,
      );

      return SqlStatementResult(affectedRows: affectedRows.affectedRows);
    } on SocketException {
      _connectionFuture = null;
      rethrow;
    } on impl.MySqlException catch (e) {
      throw DatabaseException.internal(
        message: 'MySQL exception ${e.errorNumber}: ${e.message}',
        error: e,
      );
    }
  }

  @override
  Future<void> performSqlTransaction(SqlTransactionRequest request) async {
    final connection = await _open();
    final completer = Completer<bool>();
    try {
      await connection.transaction((implTransaction) async {
        await request.callback(_MysqlTransaction(
          implTransaction,
          request.sqlClient.database.adapter,
          completer.future,
        ));
      });
      completer.complete(true);
    } catch (error) {
      completer.complete(false);
      rethrow;
    }
  }

  Future<impl.MySqlConnection> _open() async {
    if (_connectionFuture == null) {
      _connectionFuture = _openNewConnection();

      // If connection fails, remove the future so we can try again.
      // ignore: unawaited_futures
      _connectionFuture.catchError((e) {
        _connectionFuture = null;
        return null;
      });
    }
    return _connectionFuture;
  }

  Future<impl.MySqlConnection> _openNewConnection() async {
    impl.ConnectionSettings settings = impl.ConnectionSettings(
      characterSet: characterSet,
      db: databaseName,
      host: host,
      maxPacketSize: maxPacketSize,
      password: password,
      port: port,
      timeout: timeout,
      useCompression: useCompression,
      useSSL: useSSL,
      user: user,
    );

    final result = await impl.MySqlConnection.connect(settings);
    return result;
  }
}

class _MysqlTransaction extends SqlTransaction {
  final impl.MySqlConnection _context;
  _MysqlTransaction(
      this._context, DatabaseAdapter adapter, Future<bool> isSuccess)
      : super(adapter, isSuccess);
}
