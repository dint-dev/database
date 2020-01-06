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

import 'package:datastore/adapters_framework.dart';
import 'package:datastore/datastore.dart';
import 'package:datastore/query_parsing.dart';

/// An immutable datastore query.
///
/// The query algorithm has the following phases:
///   * [filter] - "Find matching documents"
///   * [sorter] - "Sort documents"
///   * [schema] - "Use a specific subgraph"
///   * [skip] - "Skip N documents"
///   * [skip] - "Take N documents"
///
/// You can use [QueryBuilder] for building instances of this class.
class Query {
  /// Optional filter.
  ///
  /// The default is null, which means that all documents will be returned.
  final Filter filter;

  /// Optional sorter.
  ///
  /// The default value is null, which means that an arbitrary order is used.
  final Sorter sorter;

  /// Optional schema.
  ///
  /// The default value is null, which means that the whole document will be
  /// returned.
  final Schema schema;

  /// The number of items to skip.
  final int skip;

  /// The number of items to take.
  ///
  /// The default value is null, which means that all items will be the taken.
  final int take;

  const Query({
    this.filter,
    this.sorter,
    this.schema,
    this.skip = 0,
    this.take,
  }) : assert(skip != null);

  @override
  int get hashCode =>
      filter.hashCode ^
      schema.hashCode ^
      sorter.hashCode ^
      skip.hashCode ^
      take.hashCode;

  @override
  bool operator ==(other) =>
      other is Query &&
      filter == other.filter &&
      schema == other.schema &&
      sorter == other.sorter &&
      skip == other.skip &&
      take == other.take;

  /// Converts an iterable into an unmodifiable result list.
  ///
  /// Optional parameter [documentScoringAlgorithm] can be used to replace the
  /// default document scoring algorithm.
  List<Snapshot> documentListFromIterable(
    Iterable<Snapshot> iterable, {
    DocumentScoring documentScoring,
  }) {
    final filter = this.filter;
    final sorter = this.sorter;
    final skip = this.skip;
    final take = this.take;
    documentScoring ??= const DocumentScoring();
    final documentScoringState = documentScoring.newState(filter);
    if (filter != null) {
      iterable = iterable.where(
        (snapshot) => documentScoringState.evaluateSnapshot(snapshot) > 0.0,
      );
    }
    if (sorter != null) {
      final list = iterable.toList(growable: false);
      list.sort((a, b) {
        return sorter.compare(a.data, b.data);
      });
      iterable = list;
    }
    if (skip != 0) {
      iterable = iterable.skip(skip);
    }
    if (take != null) {
      iterable = iterable.take(take);
    }
    return List<Snapshot>.unmodifiable(iterable);
  }

  /// Converts chunks into an incrementally improving result stream.
  ///
  /// Optional parameter [documentScoringAlgorithm] can be used to replace the
  /// default document scoring algorithm.
  ///
  /// Optional parameter [existingSorter] can be used to tell the existing order
  /// of items. By avoiding sorting, the implementation can achieve much better
  /// performance.
  Stream<List<Snapshot>> documentListStreamFromChunks(
    Stream<List<Snapshot>> stream, {
    DocumentScoring documentScoring,
    Sorter existingSorter,
  }) {
    // Handle trivial case
    if (take == 0) {
      return Stream<List<Snapshot>>.value(const <Snapshot>[]);
    }

    //
    // Is any of the following true?
    //   * No order is specified
    //   * The order is the same as the existing order in the stream.
    //
    final sorter = this.sorter;
    if (sorter == null ||
        (existingSorter != null &&
            sorter.simplify() == existingSorter.simplify())) {
      //
      // Great! We don't need to load snapshots into the memory!
      //
      return _incrementalStreamFromSortedChunks(
        stream,
        documentScoring: documentScoring,
      );
    }
    documentScoring ??= const DocumentScoring();
    final documentScoringState = documentScoring.newState(filter);

    final list = <Snapshot>[];
    return stream.map((chunk) {
      //
      // Filter
      //
      if (filter == null) {
        list.addAll(chunk);
      } else {
        final matchingItems = chunk.where((snapshot) {
          final score = documentScoringState.evaluateSnapshot(snapshot);
          return score > 0.0;
        });
        list.addAll(matchingItems);
      }

      //
      // Sort
      //
      if (sorter != null) {
        list.sort((a, b) {
          final result = sorter.compare(a.data, b.data);
          return result;
        });
      }

      //
      // Skip
      //
      Iterable<Snapshot> iterable = list;
      if (skip != 0) {
        iterable = iterable.skip(skip);
      }

      //
      // Take
      //
      if (take != null) {
        iterable = iterable.take(take);
      }

      return List<Snapshot>.unmodifiable(iterable);
    });
  }

  QueryBuilder toBuilder() {
    return QueryBuilder()
      ..filter = filter
      ..sorter = sorter
      ..skip = skip
      ..take = take;
  }

  @override
  String toString() =>
      'Query(filter:$filter, sorter:$sorter, schema:$schema, skip:$skip, take:$take)';

  /// This is an optimized case when no sorting is needed.
  Stream<List<Snapshot>> _incrementalStreamFromSortedChunks(
      Stream<List<Snapshot>> stream,
      {DocumentScoring documentScoring}) async* {
    documentScoring ??= const DocumentScoring();
    final documentScoringState = documentScoring.newState(filter);
    var remainingSkip = skip;
    var remainingTake = take;
    final result = <Snapshot>[];

    await for (var chunk in stream) {
      // Handle trivial case
      if (chunk.isEmpty) {
        continue;
      }

      //
      // Filter
      //
      var isResultUpdated = false;
      for (var item in chunk) {
        // Exclude this item?
        if (filter != null) {
          final score = documentScoringState.evaluateSnapshot(item);
          if (score == 0) {
            continue;
          }
        }

        // Skip this item?
        if (remainingSkip > 0) {
          remainingSkip--;
          continue;
        }

        // Add the item
        result.add(item);
        isResultUpdated = true;

        // Decrement take
        if (remainingTake == null) {
          continue;
        }
        remainingTake--;

        // Was this the last item?
        if (remainingTake == 0) {
          break;
        }
      }

      // If we added items, yield
      if (isResultUpdated) {
        yield (result);
      }

      // Was this the last chunk?
      if (remainingTake == 0) {
        break;
      }
    }

    // Ensure we yield at least once
    if (result.isEmpty) {
      yield (result);
    }
  }

  static Query parse(String source, {Sorter sorter, int skip = 0, int take}) {
    final filter = FilterParser().parseFilterFromString(source);
    return Query(
      filter: filter,
      sorter: sorter,
      skip: skip,
      take: take,
    );
  }
}

/// Builds instances of [Query].
///
/// The query algorithm has the following phases:
///   * [filter] - "Find matching documents"
///   * [sorter] - "Sort documents"
///   * [schema] - "Use a specific subgraph"
///   * [skip] - "Skip N documents"
///   * [skip] - "Take N documents"
class QueryBuilder {
  /// Describes which graphs should be selected.
  ///
  /// The default is null, which means that all documents will be returned.
  Filter filter;

  /// Describes how graphs should be sorted.
  ///
  /// The default value is null, which means that an arbitrary order is used.
  Sorter sorter;

  /// Describes the subgraph to select.
  ///
  /// The default value is null, which means that the whole document will be
  /// returned.
  Schema schema;

  /// The number of skipped graphs after filtering and sorting.
  ///
  /// The default value is 0.
  int skip = 0;

  /// The number of taken graphs after filtering, sorting, and skipping.
  ///
  /// The default value is null, which means that all items will be the taken.
  int take;

  QueryBuilder();

  @override
  int get hashCode => build().hashCode;

  @override
  bool operator ==(other) => other is QueryBuilder && build() == other.build();

  /// Adds a filter the query. It's merged to the current query with
  /// [AndFilter] (logical AND).
  void addFilter(Filter filter) {
    this.filter = AndFilter([this.filter, filter]).simplify();
  }

  /// Adds a sorter in the query. It will have a lower priority than existing
  /// sorters.
  void addSorter(Sorter sorter) {
    final oldSorter = this.sorter;
    if (oldSorter == null) {
      this.sorter = sorter;
    } else if (oldSorter is MultiSorter) {
      this.sorter = MultiSorter([...oldSorter.sorters, sorter]);
    } else {
      this.sorter = MultiSorter([oldSorter, sorter]);
    }
  }

  /// Builds an immutable instance of [Query].
  Query build() {
    return Query(
      filter: filter,
      sorter: sorter,
      schema: schema,
      skip: skip,
      take: take,
    );
  }
}
