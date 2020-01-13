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

/// A reference to a tree of Dart objects.
class Document<T> {
  /// Collection where the document is.
  final Collection parent;

  /// A non-blank document identifier.
  ///
  /// A few rules to know:
  ///   * Characters "/", "?", "#", and "%" should be avoided.
  ///     * This is because many implementations use REST URIs such as
  ///       "/index/{COLLECTION}/{DOCUMENT}".
  ///  * We recommend avoiding uppercase characters.
  ///    * Many implementations are case-insensitive.
  final String documentId;

  /// Constructs a document. Usually you should call the method
  /// `collection.document("id")` instead of this constructor.
  Document(this.parent, this.documentId)
      : assert(parent != null),
        assert(documentId != null) {
    ArgumentError.checkNotNull(database, 'database');
    if (documentId == null || documentId.isEmpty) {
      throw ArgumentError.value(documentId, 'documentId');
    }
  }

  /// Returns database where the document is.
  Database get database => parent.database;

  @override
  int get hashCode => documentId.hashCode ^ parent.hashCode;

  Database get parentDatabase => parent.database;

  @override
  bool operator ==(other) =>
      other is Document &&
      documentId == other.documentId &&
      parent == other.parent;

  /// Deletes the document.
  Future<void> delete() {
    return WriteRequest(
      document: this,
      type: WriteType.delete,
    ).delegateTo(parentDatabase);
  }

  /// Deletes the document.
  Future<void> deleteIfExists() {
    return WriteRequest(
      document: this,
      type: WriteType.deleteIfExists,
    ).delegateTo(parentDatabase);
  }

  /// Gets the best available snapshot.
  Future<Snapshot> get({Schema schema}) {
    return getIncrementalStream(schema: schema).last;
  }

  /// Returns an incrementally improving stream snapshots until the best
  /// available snapshot has been received.
  Stream<Snapshot> getIncrementalStream({Schema schema}) {
    return ReadRequest(
      document: this,
      schema: schema,
    ).delegateTo(parentDatabase);
  }

  /// Inserts the document.
  ///
  /// If it doesn't matter whether the document exists, use method
  /// [upsert].
  ///
  /// TODO: Specify what happens when the document already exists
  Future<void> insert({@required Map<String, Object> data}) async {
    return WriteRequest(
      document: this,
      type: WriteType.insert,
      data: data,
    ).delegateTo(parentDatabase);
  }

  @override
  String toString() => '$parent.document("$documentId")';

  /// Updates the document.
  ///
  /// If it doesn't matter whether the document exists, use method
  /// [upsert].
  ///
  /// TODO: Specify what happens when the document does NOT exist
  Future<void> update({
    Map<String, Object> data,
  }) async {
    return WriteRequest(
      document: this,
      type: WriteType.update,
      data: data,
    ).delegateTo(parentDatabase);
  }

  /// Inserts or deletes the document.
  Future<void> upsert({@required Map<String, Object> data}) {
    return WriteRequest(
      document: this,
      type: WriteType.upsert,
      data: data,
    ).delegateTo(parentDatabase);
  }

  /// Returns am infinite stream of snapshots.
  Stream<Snapshot> watch({Schema schema, Duration interval}) async* {
    while (true) {
      final stream = ReadRequest(
        document: this,
        schema: schema,
        watchSettings: WatchSettings(interval: interval),
      ).delegateTo(parentDatabase);
      yield* (stream);
      await Future.delayed(interval ?? const Duration(seconds: 1));
    }
  }
}
