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

import 'dart:math';

import 'package:built_value/serializer.dart';
import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/schema.dart';
import 'package:database/search_query_parsing.dart';

/// A reference to a collection of documents.
class Collection {
  /// Returns database where the document is.
  final Database database;
  final Document parentDocument;
  final Serializers serializers;
  final FullType fullType;

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
  /// Usually it's better to call the method `database.collection("id")`
  /// instead of this constructor.
  ///
  /// This constructor enables specifying [parentDocument], which is a concept
  /// supported by some document database vendor. It typically affects
  /// documents in the collection behave in transactions.
  Collection(
    this.database,
    this.collectionId, {
    this.parentDocument,
    this.serializers,
    this.fullType,
  })  : assert(database != null),
        assert(collectionId != null) {
    ArgumentError.checkNotNull(database, 'database');
    if (collectionId == null || collectionId.isEmpty) {
      throw ArgumentError.value(collectionId, 'collectionId');
    }
  }

  @override
  int get hashCode => database.hashCode ^ collectionId.hashCode;

  @override
  bool operator ==(other) =>
      other is Collection &&
      collectionId == other.collectionId &&
      database == other.database;

  /// Returns a column.
  Column<T> column<T>(String name) => Column<T>.fromCollection(this, name);

  /// Returns a document.
  ///
  /// Example:
  /// ```dart
  /// ds.collection('exampleCollection').document('exampleDocument').get();
  /// ```
  Document document(String documentId) {
    return Document(this, documentId);
  }

  Future<Document> insert({
    Map<String, Object> data,
    Reach reach,
  }) async {
    Document result;
    await DocumentInsertRequest(
      collection: this,
      document: null,
      data: data,
      reach: reach,
      onDocument: (v) {
        result = v;
      },
    ).delegateTo(database.adapter);
    return result;
  }

  /// Returns a new document with a random 128-bit lowercase hexadecimal ID.
  ///
  /// Example:
  /// ```dart
  /// database.collection('example').newDocument().insert({'key':'value'});
  /// ```
  // TODO: Use a more descriptive method name like documentWithRandomId()?
  Document newDocument() {
    final random = Random.secure();
    final sb = StringBuffer();
    for (var i = 0; i < 32; i++) {
      sb.write(random.nextInt(16).toRadixString(16));
    }
    return document(sb.toString());
  }

  Future<Schema> schema() async {
    final schemaResponse = await SchemaReadRequest.forCollection(this)
        .delegateTo(database.adapter)
        .last;
    return schemaResponse.schemasByCollection[collectionId];
  }

  /// Searches documents.
  ///
  /// This is a shorthand for taking the last item in a stream returned by
  /// [searchIncrementally].
  Future<QueryResult> search({
    Query query,
    Reach reach,
  }) {
    return searchIncrementally(
      query: query,
      reach: reach,
    ).last;
  }

  /// Deletes all documents that match the filter.
  ///
  /// Optional argument [queryString] defines a query string. The syntax is
  /// based on Lucene query syntax. For a description of the syntax, see
  /// [SearchQueryParser].
  ///
  /// Optional argument [filter] defines a filter.
  ///
  /// If both [queryString] and [filter] are non-null, the database will
  /// receive an [AndFilter] that contains both the parsed filter and the other
  /// filter.
  Future<void> searchAndDelete({
    Query query,
    Reach reach,
  }) async {
    return DocumentSearchChunkedRequest(
      collection: this,
      query: query,
      reach: reach,
    ).delegateTo(database.adapter);
  }

  /// Searches documents and returns the snapshots in chunks, which means that
  /// the snapshots don't have to be kept to the memory at the same time.
  ///
  /// Optional argument [queryString] defines a query string. The syntax is
  /// based on Lucene query syntax. For a description of the syntax, see
  /// [SearchQueryParser].
  ///
  /// Optional argument [filter] defines a filter.
  ///
  /// If both [queryString] and [filter] are non-null, the database will
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
  /// final stream = database.searchIncrementally(
  ///   query: Query.parse(
  ///     'cat OR dog',
  ///     skip: 0,
  ///     take: 1,
  ///   ),
  /// );
  /// ```
  Stream<QueryResult> searchChunked({
    Query query,
    Reach reach = Reach.server,
  }) async* {
    // TODO: Real implementation
    final all = await search(
      query: query,
      reach: reach,
    );
    yield (all);
  }

  /// Searches documents and returns the result as a stream where the snapshot
  /// list incrementally grows larger.
  ///
  /// Optional argument [queryString] defines a query string. The syntax is
  /// based on Lucene query syntax. For a description of the syntax, see
  /// [SearchQueryParser].
  ///
  /// Optional argument [filter] defines a filter.
  ///
  /// If both [queryString] and [filter] are non-null, the database will
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
  /// final stream = database.searchIncrementally(
  ///   query: Query.parse(
  ///     'cat OR dog',
  ///     skip: 0,
  ///     take: 1,
  ///   ),
  /// );
  /// ```
  Stream<QueryResult> searchIncrementally({
    Query query,
    Reach reach = Reach.server,
  }) {
    return DocumentSearchRequest(
      collection: this,
      query: query,
      reach: reach,
    ).delegateTo(database.adapter);
  }

  @override
  String toString() => '$database.collection("$collectionId")';
}
