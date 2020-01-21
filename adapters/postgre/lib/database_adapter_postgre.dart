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
import 'package:postgres/postgres.dart' as impl;

class Postgre extends SqlDatabaseAdapter {
  final String host;
  final int port;
  final String user;
  final String password;
  final String databaseName;

  Future<impl.PostgreSQLConnection> _connectionFuture;

  Postgre({
    @required this.host,
    @required this.port,
    @required this.user,
    @required this.password,
    @required this.databaseName,
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
    final values = <String, Object>{};
    final sql = request.sqlStatement.replaceParameters((i, value) {
      values['arg$i'] = value;
      return '@arg$i';
    });

    impl.PostgreSQLExecutionContext context;
    final sqlTransaction = request.sqlTransaction;
    if (sqlTransaction == null) {
      context = await _open();
    } else {
      context = (sqlTransaction as _PostgreTransaction)._context;
    }

    // Execute
    impl.PostgreSQLResult result;
    try {
      result = await context.query(
        sql,
        substitutionValues: values,
      );
    } on SocketException {
      _connectionFuture = null;
      rethrow;
    } on impl.PostgreSQLException catch (e) {
      throw DatabaseException.internal(
        message: 'PostgreSQL exception ${e.code}: ${e.message}',
        error: e,
      );
    }

    //
    // Return
    //
    List<SqlColumnDescription> columnDescriptions;
    if (result.columnDescriptions != null) {
      columnDescriptions = result.columnDescriptions.map((v) {
        return SqlColumnDescription(
          tableName: v.tableName,
          columnName: v.columnName,
        );
      }).toList(growable: false);
    }
    return SqlIterator.fromLists(
      columnDescriptions: columnDescriptions,
      rows: result,
    );
  }

  @override
  Future<SqlStatementResult> performSqlStatement(
    SqlStatementRequest request,
  ) async {
    final values = <String, Object>{};
    final sql = request.sqlStatement.replaceParameters((i, value) {
      values['arg$i'] = value;
      return '@arg$i';
    });

    impl.PostgreSQLExecutionContext context;
    final sqlTransaction = request.sqlTransaction;
    if (sqlTransaction == null) {
      context = await _open();
    } else {
      context = (sqlTransaction as _PostgreTransaction)._context;
    }

    // Execute
    try {
      final affectedRows = await context.execute(
        sql,
        substitutionValues: values,
      );
      return SqlStatementResult(affectedRows: affectedRows);
    } on SocketException {
      _connectionFuture = null;
      rethrow;
    } on impl.PostgreSQLException catch (e) {
      throw DatabaseException.internal(
        message: 'PostgreSQL exception ${e.code}: ${e.message}',
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
        await request.callback(_PostgreTransaction(
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

  Future<impl.PostgreSQLConnection> _open() async {
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

  Future<impl.PostgreSQLConnection> _openNewConnection() async {
    final result = impl.PostgreSQLConnection(
      host,
      port,
      databaseName,
      username: user,
      password: password,
    );
    await result.open();
    return result;
  }
}

class _PostgreTransaction extends SqlTransaction {
  final impl.PostgreSQLExecutionContext _context;
  _PostgreTransaction(
      this._context, DatabaseAdapter adapter, Future<bool> isSuccess)
      : super(adapter, isSuccess);
}
