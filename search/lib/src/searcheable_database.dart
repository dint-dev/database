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
import 'package:database/filter.dart';
import 'package:meta/meta.dart';
import 'package:search/search.dart';

/// A small in-memory text search engine for developers for use package
/// [database](https://pub.dev/packages/database).
///
/// Intercepts only queries that have keyword filters. The implementation then
/// simply reads every document in the collection and calculates a score for it.
///
/// The default document scoring algorithm is [CanineDocumentScoring].
///
/// Example:
/// ```
/// import 'package:database/database.dart';
/// import 'package:search/search.dart';
///
/// void main() {
///   final database = SearchableDatabase(MemoryDatabaseAdapter());
///
///   await database.collection('example').insert({
///     'greeting': 'Hello world',
///   });
///
///   final results = await database.search(
///     query: Query(
///       filter: KeywordFilter('hello'),
///     ),
///   );
/// }
/// ```
///
class SearcheableDatabase extends DelegatingDatabaseAdapter {
  /// The scoring algorithm for documents.
  ///
  /// By default, [CanineDocumentScoring] is used.
  final DocumentScoring scoring;

  /// If true, state mutating operations throw [UnsupportedError].
  final bool isReadOnly;

  SearcheableDatabase({
    @required DatabaseAdapter database,
    this.isReadOnly = false,
    this.scoring = const CanineDocumentScoring(),
  })  : assert(database != null),
        assert(isReadOnly != null),
        assert(scoring != null),
        super(database);

  @override
  Stream<QueryResult> performDocumentSearch(
      DocumentSearchRequest request) async* {
    final query = request.query;
    final filter = query?.filter;

    // If no keyword filters
    if (filter == null || !filter.descendants.any((f) => f is KeywordFilter)) {
      // Delegate this request
      yield* (super.performDocumentSearch(request));
      return;
    }

    final collection = request.collection;
    final sortedItems = <QueryResultItem>[];
    final intermediateResultInterval = const Duration(milliseconds: 500);
    var intermediateResultAt = DateTime.now().add(intermediateResultInterval);
    final scoringState = scoring.newState(query.filter);

    //
    // For each document
    //
    await for (var chunk in collection.searchChunked()) {
      for (final dsSnapshot in chunk.snapshots) {
        // Score
        var score = 1.0;
        if (filter != null) {
          score = scoringState.evaluateSnapshot(
            dsSnapshot,
          );
          if (score <= 0.0) {
            continue;
          }
        }

        final queryResultItem = QueryResultItem(
          snapshot: Snapshot(
            document: collection.document(dsSnapshot.document.documentId),
            data: dsSnapshot.data,
          ),
          score: score,
        );
        sortedItems.add(queryResultItem);

        // Should have an intermediate result?
        if (DateTime.now().isAfter(intermediateResultAt)) {
          if (filter != null) {
            sortedItems.sort(
              (a, b) {
                return a.score.compareTo(b.score);
              },
            );
          }
          Iterable<QueryResultItem> items = sortedItems;
          final query = request.query;
          {
            final skip = query.skip ?? 0;
            if (skip != 0) {
              items = items.skip(skip);
            }
          }
          {
            final take = query.take;
            if (take != null) {
              items = items.take(take);
            }
          }
          yield (QueryResult.withDetails(
            collection: collection,
            query: query,
            items: List<QueryResultItem>.unmodifiable(items),
          ));
          intermediateResultAt = DateTime.now().add(intermediateResultInterval);
        }
      }
    }

    //
    // Sort snapshots
    //
    if (filter != null) {
      sortedItems.sort(
        (a, b) {
          final as = a.score;
          final bs = b.score;
          return as.compareTo(bs);
        },
      );
    }
    Iterable<QueryResultItem> items = sortedItems;
    {
      final skip = query.skip ?? 0;
      if (skip != 0) {
        items = items.skip(skip);
      }
    }
    {
      final take = query.take;
      if (take != null) {
        items = items.take(take);
      }
    }

    //
    // Yield
    //
    yield (QueryResult.withDetails(
      collection: collection,
      query: query,
      items: List<QueryResultItem>.unmodifiable(items),
    ));
  }
}
