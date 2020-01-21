import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

/// Forwards eligible search requests to a search engine.
class SearchEnginePromotingDatabaseAdapter extends DelegatingDatabaseAdapter {
  final DatabaseAdapter master;
  final DatabaseAdapter searchEngine;

  /// Custom handler for errors returned by the search engine.
  /// If the handler is null, the request will be sent to the master database.
  final Stream<QueryResult> Function(
    SearchEnginePromotingDatabaseAdapter database,
    DocumentSearchRequest request,
    Object error,
    StackTrace stackTrace,
  ) onSearchError;

  SearchEnginePromotingDatabaseAdapter({
    @required this.master,
    @required this.searchEngine,
    this.onSearchError,
  })  : assert(master != null),
        assert(searchEngine != null),
        super(master);

  @override
  Stream<QueryResult> performDocumentSearch(
    DocumentSearchRequest request,
  ) {
    // Do we need to delegate to the master?
    switch (request.reach) {
      case Reach.server:
        // No need
        break;
      default:
        // Yes we need
        return super.performDocumentSearch(request);
    }

    // Delegate to a search engine.
    try {
      return request.delegateTo(searchEngine);
    } on DatabaseException catch (error, stackTrace) {
      // Invoke callback
      final callback = onSearchError;
      if (callback != null) {
        return callback(this, request, error, stackTrace);
      }

      // By default, delegate to master.
      return master.performDocumentSearch(request);
    }
  }

  @override
  Stream<QueryResult> performDocumentSearchWatch(
      DocumentSearchWatchRequest request) async* {
    // Do we need to delegate to the master?
    switch (request.reach) {
      case Reach.server:
        // No need
        break;
      default:
        // Yes we need
        yield* (super.performDocumentSearchWatch(request));
        return;
    }

    const minInterval = Duration(seconds: 5);
    var interval = request.pollingInterval ?? minInterval;
    if (interval < minInterval) {
      interval = minInterval;
    }

    // Delegate to a search engine.
    while (true) {
      // Search
      final result = await performDocumentSearch(DocumentSearchRequest(
        collection: request.collection,
        query: request.query,
        reach: request.reach,
      )).last;

      // Yield
      yield (result);

      // Wait
      await Future.delayed(interval);
    }
  }
}
