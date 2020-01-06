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

import 'dart:math';

import 'package:datastore/adapters_framework.dart';
import 'package:datastore/datastore.dart';
import 'package:datastore/query_parsing.dart';

/// A reference to a collection of documents.
class Collection {
  /// Returns datastore where the document is.
  final Datastore datastore;
  final Document parentDocument;

  /// A non-blank identifier.
  ///
  /// Certain characters ("/", "?", etc.) should be avoided in the collection ID
  /// because many implementations use REST URIs such as
  /// "/index/{COLLECTION}/{DOCUMENT}".
  ///
  /// It's also a good idea to use lowercase identifiers.
  final String collectionId;

  /// Constructs a collection.
  ///
  /// Usually it's better to call the method `datastore.collection("id")`
  /// instead of this constructor.
  ///
  /// This constructor enables specifying [parentDocument], which is a concept
  /// supported by some document database vendor. It typically affects
  /// documents in the collection behave in transactions.
  Collection(this.datastore, this.collectionId, {this.parentDocument})
      : assert(datastore != null),
        assert(collectionId != null) {
    ArgumentError.checkNotNull(datastore, 'datastore');
    if (collectionId == null || collectionId.isEmpty) {
      throw ArgumentError.value(collectionId, 'collectionId');
    }
  }

  @override
  int get hashCode => datastore.hashCode ^ collectionId.hashCode;

  @override
  bool operator ==(other) =>
      other is Collection &&
      collectionId == other.collectionId &&
      datastore == other.datastore;

  /// Returns a document.
  ///
  /// Example:
  /// ```dart
  /// ds.collection('exampleCollection').document('exampleDocument').get();
  /// ```
  Document document(String documentId) {
    return Document(this, documentId);
  }

  /// Returns a new document with a random 128-bit lowercase hexadecimal ID.
  ///
  /// Example:
  /// ```dart
  /// datastore.collection('example').newDocument().insert({'key':'value'});
  /// ```
  Document newDocument() {
    final random = Random.secure();
    final sb = StringBuffer();
    for (var i = 0; i < 32; i++) {
      sb.write(random.nextInt(16).toRadixString(16));
    }
    return document(sb.toString());
  }

  /// Searches documents.
  ///
  /// This is a shorthand for taking the last item in a stream returned by
  /// [searchIncrementally].
  Future<QueryResult> search({
    Query query,
  }) {
    return searchIncrementally(
      query: query,
    ).last;
  }

  /// Deletes all documents that match the filter.
  ///
  /// Optional argument [queryString] defines a query string. The syntax is
  /// based on Lucene query syntax. For a description of the syntax, see
  /// [FilterParser].
  ///
  /// Optional argument [filter] defines a filter.
  ///
  /// If both [queryString] and [filter] are non-null, the datastore will
  /// receive an [AndFilter] that contains both the parsed filter and the other
  /// filter.
  Future<void> searchAndDelete({
    Query query,
  }) async {
    // TODO: An implementation that datastores can easily override
    final responses = searchChunked(
      query: query,
    );
    await for (var chunk in responses) {
      for (var snapshot in chunk.snapshots) {
        await snapshot.document.deleteIfExists();
      }
    }
  }

  /// Searches documents and returns the snapshots in chunks, which means that
  /// the snapshots don't have to be kept to the memory at the same time.
  ///
  /// Optional argument [queryString] defines a query string. The syntax is
  /// based on Lucene query syntax. For a description of the syntax, see
  /// [FilterParser].
  ///
  /// Optional argument [filter] defines a filter.
  ///
  /// If both [queryString] and [filter] are non-null, the datastore will
  /// receive an [AndFilter] that contains both the parsed filter and the other
  /// filter.
  ///
  /// Optional argument [skip] defines how many snapshots to skip in the
  /// beginning. The default value is 0.
  ///
  /// You should usually give optional argument [take], which defines the
  /// maximum number of snapshots in the results.
  ///
  /// An example:
  /// ```dart
  /// final stream = datastore.searchIncrementally(
  ///   query: Query.parse(
  ///     'cat OR dog',
  ///     skip: 0,
  ///     take: 1,
  ///   ),
  /// );
  /// ```
  Stream<QueryResult> searchChunked({
    Query query,
  }) {
    return SearchRequest(
      collection: this,
      query: query,
      chunkedStreamSettings: const ChunkedStreamSettings(),
    ).delegateTo(datastore);
  }

  /// Searches documents and returns the result as a stream where the snapshot
  /// list incrementally grows larger.
  ///
  /// Optional argument [queryString] defines a query string. The syntax is
  /// based on Lucene query syntax. For a description of the syntax, see
  /// [FilterParser].
  ///
  /// Optional argument [filter] defines a filter.
  ///
  /// If both [queryString] and [filter] are non-null, the datastore will
  /// receive an [AndFilter] that contains both the parsed filter and the other
  /// filter.
  ///
  /// Optional argument [skip] defines how many snapshots to skip in the
  /// beginning. The default value is 0.
  ///
  /// You should usually give optional argument [take], which defines the
  /// maximum number of snapshots in the results.
  ///
  /// An example:
  /// ```dart
  /// final stream = datastore.searchIncrementally(
  ///   query: Query.parse(
  ///     'cat OR dog',
  ///     skip: 0,
  ///     take: 1,
  ///   ),
  /// );
  /// ```
  Stream<QueryResult> searchIncrementally({
    Query query,
  }) {
    return SearchRequest(
      collection: this,
      query: query,
    ).delegateTo(datastore);
  }

  @override
  String toString() => '$datastore.collection("$collectionId")';
}
