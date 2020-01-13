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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

/// Chunked stream settings for [SearchRequest].
class ChunkedStreamSettings {
  /// Chunk length. If null, the implementation can choose any length.
  final int length;

  const ChunkedStreamSettings({this.length});

  @override
  int get hashCode => length.hashCode;

  @override
  bool operator ==(other) =>
      other is ChunkedStreamSettings && length == other.length;
}

/// A request for a stream of [QueryResult] items.
@sealed
class SearchRequest {
  /// Collection where the search is done.
  Collection collection;

  /// Optional query.
  Query query;

  /// Whether the response stream should be an incrementally improving list of
  /// all snapshots.
  ///
  /// It's an invalid state if both [chunkedStreamSettings] and [watchSettings] are non-null.
  ChunkedStreamSettings chunkedStreamSettings;

  /// If non-null, the stream is infinite. New items are generated are updated
  /// using polling or some more efficient method.
  ///
  /// For performance reasons, an item should not be added to the stream if it's
  /// the equal to the previous added item.
  WatchSettings watchSettings;

  Schema schema;

  SearchRequest({
    @required this.collection,
    Query query,
    this.chunkedStreamSettings,
    this.watchSettings,
  })  : assert(collection != null),
        query = query ?? const Query();

  bool get isChunked => chunkedStreamSettings != null;

  bool get isIncremental => chunkedStreamSettings == null;

  bool get isWatching => watchSettings != null;

  Stream<QueryResult> delegateTo(Database database) {
    // ignore: invalid_use_of_protected_member
    return (database as DatabaseAdapter).performSearch(this);
  }
}
