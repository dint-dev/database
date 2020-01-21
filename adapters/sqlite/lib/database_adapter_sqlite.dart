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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/sql.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart' as impl;

class SQLite extends SqlDatabaseAdapter {
  final String path;
  impl.Database _implDatabase;

  SQLite({@required this.path});

  @override
  Future<SqlIterator> performSqlQuery(SqlQueryRequest request) async {
    impl.DatabaseExecutor implDatabase = await _getImpl();
    final transaction = request.sqlTransaction;
    if (transaction != null) {
      implDatabase = (transaction as _SQLiteTransaction)._impl;
    }
    try {
      final implResults = await implDatabase.rawQuery(
        request.sqlStatement.value,
        request.sqlStatement.arguments,
      );
      return SqlIterator.fromMaps(implResults);
    } on impl.DatabaseException catch (error) {
      throw DatabaseException.internal(error: error);
    }
  }

  @override
  Future<SqlStatementResult> performSqlStatement(
      SqlStatementRequest request) async {
    impl.DatabaseExecutor implDatabase = await _getImpl();
    final transaction = request.sqlTransaction;
    if (transaction != null) {
      implDatabase = (transaction as _SQLiteTransaction)._impl;
    }
    final sqlSource = request.sqlStatement;
    final value = sqlSource.value;
    final arguments = sqlSource.arguments;
    final valueLowerCase = value.toLowerCase();
    try {
      if (valueLowerCase.startsWith('insert')) {
        await implDatabase.rawInsert(value, arguments);
        return SqlStatementResult();
      }
      if (valueLowerCase.startsWith('update')) {
        final affectedCount = await implDatabase.rawUpdate(value, arguments);
        return SqlStatementResult(
          affectedRows: affectedCount,
        );
      }
      if (valueLowerCase.startsWith('delete')) {
        final affectedCount = await implDatabase.rawDelete(value, arguments);
        return SqlStatementResult(
          affectedRows: affectedCount,
        );
      }
      await implDatabase.execute(
        value,
        arguments,
      );
      return SqlStatementResult();
    } on impl.DatabaseException catch (error) {
      throw DatabaseException.internal(error: error);
    }
  }

  @override
  Future<void> performSqlTransaction(SqlTransactionRequest request) async {
    final impl = await _getImpl();
    final completer = Completer<bool>();
    try {
      await impl.transaction((implTransaction) async {
        final transaction = _SQLiteTransaction(
          implTransaction,
          request.sqlClient.database.adapter,
          completer.future,
        );
        await request.callback(transaction);
      });
      completer.complete(true);
      return;
    } catch (error) {
      completer.complete(false);
      rethrow;
    }
  }

  Future<impl.Database> _getImpl() async {
    if (_implDatabase != null) {
      return _implDatabase;
    }
    final implDatabase = await impl.openDatabase(path);
    if (implDatabase != null) {
      _implDatabase = implDatabase;
    }
    return implDatabase;
  }
}

class _SQLiteTransaction extends SqlTransaction {
  impl.Transaction _impl;

  _SQLiteTransaction(
      this._impl, DatabaseAdapter adapter, Future<bool> isSuccess)
      : super(adapter, isSuccess);
}
