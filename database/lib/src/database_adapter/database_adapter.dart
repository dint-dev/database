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
import 'package:meta/meta.dart';

/// Superclass for database adapters.
///
/// If your adapter delegates calls to another adopter, you should extend
/// [DelegatingDatabaseAdapter].
///
/// If your adapter is read-only, you should use mixin
/// [ReadOnlyDatabaseAdapterMixin].
abstract class DatabaseAdapter {
  const DatabaseAdapter();

  /// Closes the database adapter.
  @mustCallSuper
  Future<void> close() async {}

  /// Returns the database.
  Database database() {
    return Database.withAdapter(this);
  }

  Future<void> performCheckConnection({Duration timeout}) {
    return Future<void>.value();
  }

  Future<void> performDocumentBatch(
    DocumentBatchRequest request,
  ) {
    final documentDeleteResponses = List<Future<void>>.unmodifiable(
      request.documentDeleteRequests.map((request) {
        return performDocumentDelete(request);
      }),
    );
    final documentInsertResponses = List<Future<void>>.unmodifiable(
      request.documentInsertRequests.map((request) {
        return performDocumentInsert(request);
      }),
    );
    final documentSearchResponses =
        request.documentSearchRequests.map((request) {
      return performDocumentSearch(request);
    });
    final documentReadResponses = request.documentReadRequests.map((request) {
      return performDocumentRead(request);
    });
    final documentUpdateResponses = List<Future<void>>.unmodifiable(
      request.documentUpdateRequests.map((request) {
        return performDocumentUpdate(request);
      }),
    );
    final documentUpsertResponses = List<Future<void>>.unmodifiable(
      request.documentUpsertRequests.map((request) {
        return performDocumentUpsert(request);
      }),
    );
    return Future<DocumentBatchResponse>.value(DocumentBatchResponse(
      documentDeleteResponses: documentDeleteResponses,
      documentInsertResponses: documentInsertResponses,
      documentSearchResponses: documentSearchResponses,
      documentReadResponses: documentReadResponses,
      documentUpdateResponses: documentUpdateResponses,
      documentUpsertResponses: documentUpsertResponses,
    ));
  }

  Future<void> performDocumentDelete(
    DocumentDeleteRequest request,
  );

  Future<void> performDocumentDeleteBySearch(
    DocumentDeleteBySearchRequest request,
  );

  Future<void> performDocumentInsert(
    DocumentInsertRequest request,
  );

  Stream<Snapshot> performDocumentRead(
    DocumentReadRequest request,
  );

  Stream<Snapshot> performDocumentReadWatch(
    DocumentReadWatchRequest request,
  );

  Stream<QueryResult> performDocumentSearch(
    DocumentSearchRequest request,
  );

  Stream<QueryResult> performDocumentSearchChunked(
    DocumentSearchChunkedRequest request,
  ) async* {
    // Read all documents into memory
    final last = await performDocumentSearch(DocumentSearchRequest(
      collection: request.collection,
      query: request.query,
      reach: request.reach,
    )).last;

    // Yield them
    yield (last);
  }

  Stream<QueryResult> performDocumentSearchWatch(
    DocumentSearchWatchRequest request,
  );

  Future<void> performDocumentTransaction(
    DocumentTransactionRequest request,
  );

  Future<void> performDocumentUpdate(
    DocumentUpdateRequest request,
  );

  Future<void> performDocumentUpdateBySearch(
    DocumentUpdateBySearchRequest request,
  );

  Future<void> performDocumentUpsert(
    DocumentUpsertRequest request,
  );

  Stream<DatabaseExtensionResponse> performExtension(
    DatabaseExtensionRequest request,
  ) {
    return request.unsupported(this);
  }

  Stream<DatabaseSchema> performSchemaRead(SchemaReadRequest request) async* {}

  Future<SqlIterator> performSqlQuery(
    SqlQueryRequest request,
  );

  Future<SqlStatementResult> performSqlStatement(
    SqlStatementRequest request,
  );

  Future<void> performSqlTransaction(
    SqlTransactionRequest request,
  );
}
