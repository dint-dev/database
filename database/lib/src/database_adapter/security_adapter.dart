import 'dart:async';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';

/// Base class for security adapters. Contains various helpful methods that
/// you can override.
class SecurityAdapter extends DelegatingDatabaseAdapter {
  SecurityAdapter(DatabaseAdapter adapter) : super(adapter);

  FutureOr<void> beforeRead(
    Request request,
  ) {}

  FutureOr<void> beforeWrite(
    Request request,
  ) {}

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) async* {
    await beforeRead(request);
    yield* (super.performDocumentRead(request).asyncMap((snapshot) {
      return transformSnapshot(request, snapshot);
    }));
  }

  @override
  Stream<Snapshot> performDocumentReadWatch(
      DocumentReadWatchRequest request) async* {
    await beforeRead(request);
    yield* (super.performDocumentReadWatch(request).asyncMap((snapshot) {
      return transformSnapshot(request, snapshot);
    }));
  }

  @override
  Stream<QueryResult> performDocumentSearch(
      DocumentSearchRequest request) async* {
    await beforeRead(request);
    yield* (super.performDocumentSearch(request).asyncMap((result) async {
      return transformQueryResult(request, result);
    }));
  }

  @override
  Stream<QueryResult> performDocumentSearchChunked(
      DocumentSearchChunkedRequest request) async* {
    await beforeRead(request);
    yield* (super
        .performDocumentSearchChunked(request)
        .asyncMap((result) async {
      return transformQueryResult(request, result);
    }));
  }

  @override
  Stream<QueryResult> performDocumentSearchWatch(
      DocumentSearchWatchRequest request) async* {
    await beforeRead(request);
    yield* (super.performDocumentSearchWatch(request).asyncMap((result) async {
      return transformQueryResult(request, result);
    }));
  }

  /// Transforms query result before returning to the caller.
  ///
  /// Each snapshot is transformed with [transformSnapshot].
  FutureOr<QueryResult> transformQueryResult(
      Request request, QueryResult result) async {
    final oldItems = result.items;
    final newItems = List<QueryResultItem>(oldItems.length);
    for (var i = 0; i < newItems.length; i++) {
      final oldItem = oldItems[i];
      newItems[i] = QueryResultItem(
        snapshot: await transformSnapshot(
          request,
          oldItem.snapshot,
        ),
        score: oldItem.score,
        snippets: oldItem.snippets,
      );
    }
    return QueryResult.withDetails(
      collection: result.collection,
      query: result.query,
      items: List<QueryResultItem>.from(newItems),
    );
  }

  /// Transforms snapshot before returning to the caller.
  ///
  /// This can be used for security purposes.
  FutureOr<Snapshot> transformSnapshot(
    Request request,
    Snapshot snapshot,
  ) {
    return snapshot;
  }
}
