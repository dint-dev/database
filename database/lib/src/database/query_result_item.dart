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

/// Item in a [QueryResult].
class QueryResultItem<T> {
  /// Snapshot of the document.
  final Snapshot snapshot;

  /// Optional score given by the underlying search engine. Developers may find
  /// it useful for debugging.
  final double score;

  /// Snippets of the document.
  final List<Snippet> snippets;

  /// Optional vendor-specific data received from the database.
  /// For example, a database adapter for Elasticsearch could expose JSON
  /// response received from the REST API of Elasticsearch.
  final Object vendorData;

  const QueryResultItem({
    @required this.snapshot,
    this.score,
    this.snippets = const <Snippet>[],
    this.vendorData,
  });

  /// Data of the document.
  ///
  /// Depending on the query options, this:
  ///   * May be null
  ///   * May contain incomplete data
  Map<String, Object> get data => snapshot.data;

  /// Document that matched.
  Document get document => snapshot.document;

  @override
  int get hashCode =>
      score.hashCode ^
      const ListEquality<Snippet>().hash(snippets) ^
      const DeepCollectionEquality().hash(vendorData);

  @override
  bool operator ==(other) =>
      other is QueryResultItem &&
      score == other.score &&
      const ListEquality<Snippet>().equals(snippets, other.snippets) &&
      const DeepCollectionEquality().equals(vendorData, other.vendorData);
}
