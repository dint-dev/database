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
import 'package:database/schema.dart';
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
  Future<void> delete({
    Reach reach,
    bool mustExist = false,
  }) {
    return DocumentDeleteRequest(
      document: this,
      mustExist: mustExist,
      reach: reach,
    ).delegateTo(parentDatabase.adapter);
  }

  /// Tells whether the document exists.
  Future<bool> exists({
    Reach reach = Reach.regional,
  }) async {
    final snapshot = await get(
      schema: MapSchema(const {}),
      reach: reach,
    );
    return snapshot.exists;
  }

  /// Returns the current snapshot.
  ///
  /// Optional parameter [reach] can be used to specify the minimum level of
  /// authority needed. For example:
  ///   * [Reach.local] tells that a locally cached snapshot is sufficient.
  ///   * [Reach.global] tells that the snapshot must be from the global
  ///     transactional database, reflecting the latest state.
  Future<Snapshot> get({
    Schema schema,
    Reach reach,
  }) {
    return getIncrementally(
      schema: schema,
      reach: reach,
    ).last;
  }

  /// Returns an incrementally improving stream snapshots until the best
  /// available snapshot has been received.
  Stream<Snapshot> getIncrementally({
    Schema schema,
    Reach reach,
  }) {
    return DocumentReadRequest(
      document: this,
      outputSchema: schema,
      reach: reach,
    ).delegateTo(parentDatabase.adapter);
  }

  /// Inserts the document.
  ///
  /// If it doesn't matter whether the document exists, use method
  /// [upsert].
  ///
  /// TODO: Specify what happens when the document already exists
  Future<void> insert({
    @required Map<String, Object> data,
    Reach reach = Reach.regional,
  }) async {
    return DocumentInsertRequest(
      collection: null,
      document: this,
      data: data,
      reach: reach,
    ).delegateTo(parentDatabase.adapter);
  }

  /// Patches the document.
  Future<void> patch({
    @required Map<String, Object> data,
    Reach reach,
  }) {
    // TODO: Patching supporting without transactions
    return parentDatabase.runInTransaction(
      reach: reach,
      callback: (transaction) async {
        final snapshot = await transaction.get(this);
        if (!snapshot.exists) {
          throw DatabaseException.notFound(this);
        }
        final newData = Map<String, Object>.from(
          snapshot.data,
        );
        for (var entry in data.entries) {
          newData[entry.key] = entry.value;
        }
        await transaction.update(
          this,
          data: Map<String, Object>.unmodifiable(newData),
        );
      },
    );
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
    Reach reach = Reach.regional,
  }) async {
    return DocumentUpdateRequest(
      document: this,
      data: data,
      isPatch: false,
      reach: reach,
    ).delegateTo(parentDatabase.adapter);
  }

  /// Inserts or deletes the document.
  Future<void> upsert({
    @required Map<String, Object> data,
    Reach reach,
  }) {
    return DocumentUpsertRequest(
      document: this,
      data: data,
      reach: reach,
    ).delegateTo(parentDatabase.adapter);
  }

  /// Returns am infinite stream of snapshots.
  Stream<Snapshot> watch({
    Schema schema,
    Duration interval,
    Reach reach,
  }) async* {
    while (true) {
      final stream = DocumentReadWatchRequest(
        document: this,
        outputSchema: schema,
        pollingInterval: interval,
        reach: reach,
      ).delegateTo(parentDatabase.adapter);
      yield* (stream);
      await Future.delayed(interval ?? const Duration(seconds: 1));
    }
  }
}
