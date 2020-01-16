import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

/// Forwards search requests to a specific database adapter.
///
/// By default, only search requests that don't need latest data are forwarded.
/// You
class SearchEnginePromotingDatabase extends DelegatingDatabaseAdapter {
  final DatabaseAdapter master;
  final DatabaseAdapter searchEngine;
  final bool searchEngineHasBestData;

  SearchEnginePromotingDatabase({
    @required this.master,
    @required this.searchEngine,
    this.searchEngineHasBestData = false,
  })  : assert(master != null),
        assert(searchEngine != null),
        super(master);

  @override
  Stream<QueryResult> performSearch(
    SearchRequest request,
  ) {
    // Is the best data needed?
    if (request.best && !searchEngineHasBestData) {
      // Search engine can't be used
      return super.performSearch(request);
    }

    // Delegate to search engine.
    try {
      return request.delegateTo(searchEngine);
    } on DatabaseException catch (e) {
      if (e.code == DatabaseExceptionCodes.unavailable) {
        // Search engine is unavailable.
        // Delegate to master.
        return master.performSearch(request);
      }
      rethrow;
    }
  }
}
