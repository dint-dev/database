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
import 'dart:collection';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/schema.dart';
import 'package:database/sql.dart';
import 'package:meta/meta.dart';

abstract class SqlDatabaseAdapter extends DatabaseAdapter {
  bool _isLocked = false;
  final _lockWaiters = Queue<Completer<void>>();

  @override
  Future<void> performDocumentBatch(DocumentBatchRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) async {
    final document = request.document;

    final result = await document.parentDatabase.sqlClient
        .table(document.parent.collectionId)
        .whereColumn('id', equals: document.documentId)
        .deleteAll();

    if (request.mustExist && result.affectedRows == 0) {
      throw DatabaseException.notFound(document);
    }
  }

  @override
  Future<void> performDocumentDeleteBySearch(
      DocumentDeleteBySearchRequest request) async {
    final collection = request.collection;
    await collection.database.sqlClient
        .table(collection.collectionId)
        .deleteAll();
  }

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) {
    throw UnimplementedError();
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) async* {
    final document = request.document;

    final maps = await document.parentDatabase.sqlClient
        .table(document.parent.collectionId)
        .whereColumn('id', equals: document.documentId)
        .select()
        .toMaps();

    yield (Snapshot(
      document: document,
      data: maps.single,
    ));
  }

  @override
  Stream<Snapshot> performDocumentReadWatch(DocumentReadWatchRequest request) {
    throw UnimplementedError();
  }

  @override
  Stream<QueryResult> performDocumentSearch(DocumentSearchRequest request) {
    throw UnimplementedError();
  }

  @override
  Stream<QueryResult> performDocumentSearchWatch(
      DocumentSearchWatchRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> performDocumentTransaction(DocumentTransactionRequest request) {
    throw DatabaseException.transactionUnsupported();
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> performDocumentUpdateBySearch(
      DocumentUpdateBySearchRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) {
    throw UnimplementedError();
  }

  @override
  Stream<DatabaseExtensionResponse> performExtension(
      DatabaseExtensionRequest<DatabaseExtensionResponse> request) {
    return super.performExtension(request);
  }

  @override
  Stream<DatabaseSchema> performSchemaRead(SchemaReadRequest request) async* {
    final sqlClient = request.database.sqlClient;
    final columnRows = await sqlClient
        .query(
          'SELECT table_name, column_name, is_nullable, data_type, character_maximum_length FROM information_schema.column',
        )
        .toRows();

    final tableSchemas = <String, MapSchema>{};
    for (var row in columnRows) {
      final tableSchemaName = row[0] as String;
      final columnName = row[1] as String;
      final isNullable = _isNullableFrom(row[2] as String);
      final dataType = row[3] as String;
      final int characterMaximumLength = row[3];

      assert(tableSchemaName != null);
      assert(columnName != null);
      assert(dataType != null);

      final columnSchema = _columnSchemaFrom(
        isNullable: isNullable,
        dataType: dataType,
        characterMaximumLength: characterMaximumLength,
      );
      assert(columnSchema != null);

      var tableSchema = tableSchemas[tableSchemaName];
      if (tableSchema == null) {
        tableSchema = MapSchema({});
        tableSchemas[tableSchemaName] = tableSchema;
      }
      tableSchema.properties[columnName] = columnSchema;
    }

    yield (DatabaseSchema(
      schemasByCollection: tableSchemas,
    ));
  }

  @override
  Future<SqlIterator> performSqlQuery(SqlQueryRequest request);

  @override
  Future<SqlStatementResult> performSqlStatement(SqlStatementRequest request);

  @override
  Future<void> performSqlTransaction(SqlTransactionRequest request) async {
    await scheduleExclusiveAccess(
      request.sqlClient,
      (sqlClient) async {
        await sqlClient.execute('BEGIN TRANSACTION');
        final completer = Completer<bool>();
        final transaction = _SqlTransaction(
          sqlClient.database.adapter,
          completer.future,
        );
        try {
          await request.callback(transaction);
          await sqlClient.execute('COMMIT TRANSACTION');
          completer.complete(true);
        } catch (error) {
          await sqlClient.execute('ROLLBACK TRANSACTION');
          completer.complete(false);
          rethrow;
        }
      },
      timeout: request.timeout,
    );
  }

  /// Schedules a callback that will be the only one using the client.
  Future<R> scheduleExclusiveAccess<R>(
    SqlClient sqlClient,
    Future<R> Function(SqlClient sqlClient) callback, {
    Duration timeout,
  }) async {
    while (_isLocked) {
      final completer = Completer<void>();
      _lockWaiters.add(completer);
      await completer.future;
    }
    try {
      _isLocked = true;
      return await callback(sqlClient).timeout(
        timeout ?? const Duration(seconds: 2),
      );
    } finally {
      _isLocked = false;
      while (_lockWaiters.isNotEmpty) {
        final waiter = _lockWaiters.removeFirst();
        waiter.complete();
      }
    }
  }

  static Schema _columnSchemaFrom({
    @required String dataType,
    @required bool isNullable,
    @required int characterMaximumLength,
  }) {
    switch (dataType.toLowerCase()) {
      case 'bool':
        return BoolSchema();
      case 'tinyint': // 8-bit
        return IntSchema();
      case 'smallint': // 16-bit
        return IntSchema();
      case 'int': // 32-bit
        return IntSchema();
      case 'bigint': // 64-bit
        return Int64Schema();
      case 'varchar':
        return StringSchema(
          maxLengthInUtf8: characterMaximumLength,
        );
      case 'date':
        return DateSchema();
      case 'timestamp':
        return DateTimeSchema();
      default:
        throw DatabaseException.sqlColumnValue(
          database: 'information_schema',
          table: 'column',
          column: 'data_type',
          value: dataType,
        );
    }
  }

  static bool _isNullableFrom(String value) {
    switch (value) {
      case 'YES':
        return true;
      case 'NO':
        return false;
      default:
        throw DatabaseException.sqlColumnValue(
          database: 'information_schema',
          table: 'column',
          column: 'is_nullable',
          value: value,
        );
    }
  }
}

class _SqlTransaction extends SqlTransaction {
  _SqlTransaction(
    DatabaseAdapter adapter,
    Future<bool> isSuccess,
  ) : super(adapter, isSuccess);
}
