import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/sql.dart';

abstract class DocumentDatabaseAdapter extends DatabaseAdapter {
  @override
  Future<void> performDocumentDeleteBySearch(
    DocumentDeleteBySearchRequest request,
  ) async {
    final result = await performDocumentSearch(
      DocumentSearchRequest(
        collection: request.collection,
        query: request.query,
        reach: request.reach,
      ),
    ).last;
    for (var snapshot in result.snapshots) {
      await performDocumentDelete(DocumentDeleteRequest(
        document: snapshot.document,
        mustExist: false,
        reach: request.reach,
      ));
    }
  }

  /// Inserts by using read and upsert operations inside a transaction.
  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) {
    return performDocumentTransaction(DocumentTransactionRequest(
      callback: (transaction) async {
        final snapshot = await transaction.get(request.document);
        if (snapshot.exists) {
          throw DatabaseException.found(request.document);
        }
        await transaction.upsert(
          request.document,
          data: request.data,
        );
      },
      reach: request.reach,
      timeout: const Duration(seconds: 2),
    ));
  }

  @override
  Stream<Snapshot> performDocumentReadWatch(
    DocumentReadWatchRequest request,
  ) async* {
    final interval = request.pollingInterval ?? Duration(seconds: 5);
    while (true) {
      final result = await performDocumentRead(
        DocumentReadRequest(
          document: request.document,
          reach: request.reach,
        ),
      ).last;
      yield (result);
      await Future.delayed(interval);
    }
  }

  @override
  Stream<QueryResult> performDocumentSearchWatch(
    DocumentSearchWatchRequest request,
  ) async* {
    final interval = request.pollingInterval ?? Duration(seconds: 5);
    while (true) {
      final result = await performDocumentSearch(
        DocumentSearchRequest(
          collection: request.collection,
          query: request.query,
          reach: request.reach,
        ),
      ).last;
      yield (result);
      await Future.delayed(interval);
    }
  }

  @override
  Future<void> performDocumentTransaction(
      DocumentTransactionRequest request) async {
    throw DatabaseException.transactionUnsupported();
  }

  /// Updates by using read and upsert operations inside a transaction.
  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) {
    return performDocumentTransaction(DocumentTransactionRequest(
      callback: (transaction) async {
        // Get a snapshot of the existing document
        final snapshot = await transaction.get(request.document);
        if (!snapshot.exists) {
          throw DatabaseException.notFound(request.document);
        }

        // Is this a patch?
        var data = request.data;
        if (request.isPatch) {
          final patchedData = Map<String, Object>.from(snapshot.data);
          patchedData.addAll(data);
          data = patchedData;
        }

        // Upsert
        await transaction.upsert(
          request.document,
          data: data,
        );
      },
      reach: request.reach,
      timeout: const Duration(seconds: 2),
    ));
  }

  @override
  Future<void> performDocumentUpdateBySearch(
    DocumentUpdateBySearchRequest request,
  ) async {
    final result = await performDocumentSearch(
      DocumentSearchRequest(
        collection: request.collection,
        query: request.query,
        reach: request.reach,
      ),
    ).last;
    for (var snapshot in result.snapshots) {
      await performDocumentUpdate(DocumentUpdateRequest(
        document: snapshot.document,
        data: request.data,
        isPatch: request.isPatch,
        reach: request.reach,
      ));
    }
  }

  @override
  Future<SqlIterator> performSqlQuery(
    SqlQueryRequest request,
  ) async {
    throw UnsupportedError('Adapter does not support SQL: $runtimeType');
  }

  @override
  Future<SqlStatementResult> performSqlStatement(
    SqlStatementRequest request,
  ) async {
    throw UnsupportedError('Adapter does not support SQL: $runtimeType');
  }

  @override
  Future<void> performSqlTransaction(
    SqlTransactionRequest request,
  ) async {
    throw UnsupportedError('Adapter does not support SQL: $runtimeType');
  }
}
