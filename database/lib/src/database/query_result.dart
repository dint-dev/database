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

import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:meta/meta.dart';

/// The result of sending a [Query] to a [Collection].
class QueryResult {
  /// Collection.
  final Collection collection;

  /// Query.
  final Query query;

  List<Snapshot> _snapshots;

  List<QueryResultItem> _items;

  /// Suggested queries.
  final List<SuggestedQuery> suggestedQueries;

  /// Estimate of the total number of matches. Null if count was not requested.
  final int count;

  /// Optional vendor-specific data received from the database.
  /// For example, a database adapter for Elasticsearch could expose JSON
  /// response received from the REST API of Elasticsearch.
  final Object vendorData;

  QueryResult({
    @required this.collection,
    @required this.query,
    @required List<Snapshot> snapshots,
    this.count,
    this.vendorData,
  })  : assert(collection != null),
        assert(query != null),
        assert(snapshots != null),
        _snapshots = snapshots,
        _items = null,
        suggestedQueries = const <SuggestedQuery>[];

  QueryResult.withDetails({
    @required this.collection,
    @required this.query,
    @required List<QueryResultItem> items,
    this.count,
    this.suggestedQueries,
    this.vendorData,
  })  : assert(collection != null),
        assert(query != null),
        assert(items != null),
        _snapshots = null,
        _items = items;

  @override
  int get hashCode =>
      collection.hashCode ^
      query.hashCode ^
      count.hashCode ^
      const ListEquality<Snapshot>().hash(snapshots) ^
      const ListEquality().hash(suggestedQueries) ^
      const DeepCollectionEquality().hash(vendorData);

  /// Return items. Unlike [snapshots], this contains for additional data such
  /// as snippets.
  List<QueryResultItem> get items {
    _items ??= List<QueryResultItem>.unmodifiable(
      snapshots.map((snapshot) => QueryResultItem(snapshot: snapshot)),
    );
    return _items;
  }

  /// Returned document snapshots.
  List<Snapshot> get snapshots {
    _snapshots ??= List.unmodifiable(items.map((item) => item.snapshot));
    return _snapshots;
  }

  @override
  bool operator ==(other) =>
      other is QueryResult &&
      collection == other.collection &&
      query == other.query &&
      count == other.count &&
      const ListEquality<QueryResultItem>().equals(items, other.items) &&
      const ListEquality().equals(suggestedQueries, other.suggestedQueries) &&
      const DeepCollectionEquality().equals(vendorData, other.vendorData);
}
