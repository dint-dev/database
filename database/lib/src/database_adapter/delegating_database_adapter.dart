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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/schema.dart';
import 'package:database/sql.dart';
import 'package:database/src/database_adapter/requests/schema_read_request.dart';

/// Superclass for delegating database adapters.
class DelegatingDatabaseAdapter implements DatabaseAdapter {
  final DatabaseAdapter _adapter;

  const DelegatingDatabaseAdapter(this._adapter) : assert(_adapter != null);

  @override
  Future<void> close() async {
    await _adapter.close();
  }

  @override
  Database database() {
    return Database.withAdapter(this);
  }

  @override
  Future<void> performCheckConnection({Duration timeout}) {
    return _adapter.performCheckConnection(timeout: timeout);
  }

  @override
  Future<void> performDocumentBatch(DocumentBatchRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performDocumentDeleteBySearch(
      DocumentDeleteBySearchRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Stream<Snapshot> performDocumentReadWatch(DocumentReadWatchRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Stream<QueryResult> performDocumentSearch(DocumentSearchRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Stream<QueryResult> performDocumentSearchChunked(
      DocumentSearchChunkedRequest request) {
    return _adapter.performDocumentSearchChunked(request);
  }

  @override
  Stream<QueryResult> performDocumentSearchWatch(
      DocumentSearchWatchRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performDocumentTransaction(DocumentTransactionRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performDocumentUpdateBySearch(
      DocumentUpdateBySearchRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Stream<DatabaseExtensionResponse> performExtension(
      DatabaseExtensionRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Stream<DatabaseSchema> performSchemaRead(SchemaReadRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<SqlIterator> performSqlQuery(SqlQueryRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<SqlStatementResult> performSqlStatement(SqlStatementRequest request) {
    return request.delegateTo(_adapter);
  }

  @override
  Future<void> performSqlTransaction(SqlTransactionRequest request) {
    return _adapter.performSqlTransaction(request);
  }
}
