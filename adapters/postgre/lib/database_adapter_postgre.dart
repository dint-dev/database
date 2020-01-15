// Copyright 2019 terrier989@gmail.com.
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

import 'dart:io' show SocketException;

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
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
  Future<SqlResponse> performSql(SqlRequest request) async {
    //
    // Convert argument syntax
    //
    var sql = request.sql;
    final argumentsList = request.arguments;
    final argumentsMap = <String, Object>{};
    for (var i = 0; i < argumentsList.length; i++) {
      sql = sql.replaceAll('{$i}', '@arg$i');
      argumentsMap['arg$i'] = argumentsList[i];
    }

    //
    // Execute
    //
    final connection = await _open();

    impl.PostgreSQLResult result;
    try {
      if (request.isNotQuery) {
        final affectedRows = await connection.execute(
          sql,
          substitutionValues: argumentsMap,
        );
        return SqlResponse.fromAffectedRows(affectedRows);
      }
      result = await connection.query(
        sql,
        substitutionValues: argumentsMap,
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
    List<ColumnDescription> columnDescriptions;
    if (result.columnDescriptions != null) {
      columnDescriptions = result.columnDescriptions.map((v) {
        return ColumnDescription(
          collectionId: v.tableName,
          columnName: v.columnName,
        );
      }).toList(growable: false);
    }
    return SqlResponse.fromLists(
      columnDescriptions: columnDescriptions,
      rows: result,
    );
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
