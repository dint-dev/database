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

/// A document in a [Collection].
///
/// In relational databases, "document" means a row.
///
/// An example:
///
///     Future<void> main() async {
///       // Use an in-memory database
///       final database = MemoryDatabaseAdapter().database();
///
///       // Our collection
///       final collection = database.collection('pizzas');
///
///       // Our document
///       final document = collection.newDocument();
///
///       await document.insert({
///         'name': 'Pizza Margherita',
///         'rating': 3.5,
///         'ingredients': ['dough', 'tomatoes'],
///         'similar': [
///           database.collection('recipes').document('pizza_funghi'),
///         ],
///       });
///       print('Successfully inserted pizza.');
///
///       await document.patch({
///         'rating': 4.5,
///       });
///       print('Successfully patched pizza.');
///
///       await document.delete();
///       print('Successfully deleted pizza.');
///     }
///
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
  ///
  /// An example:
  ///
  ///     final document = database.collection('recipe').document('tiramisu');
  ///     await document.delete(mustExist:true);
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
  ///
  /// An example:
  ///
  ///     final document = database.collection('recipe').document('tiramisu');
  ///     final exists = await document.exists(reach:Reach.regional);
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
  ///
  /// An example:
  ///
  ///     final document = database.collection('recipe').document('tiramisu');
  ///     final snapshot = await document.get(
  ///       schema: recipeSchema,
  ///       reach: Reach.regional,
  ///     );
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
  /// If the document exists already, the method will throw
  /// [DatabaseException.found].
  ///
  /// Optional parameter [reach] can be used to specify the minimum level of
  /// authority needed. For example:
  ///   * [Reach.local] tells that the write only needs to reach the local
  ///     database (which may synchronized with the global database later).
  ///   * [Reach.global] tells that the write should reach the global master
  ///     database.
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
  ///
  /// Optional parameter [reach] can be used to specify the minimum level of
  /// authority needed. For example:
  ///   * [Reach.local] tells that the write only needs to reach the local
  ///     database (which may synchronized with the global database later).
  ///   * [Reach.global] tells that the write should reach the global master
  ///     database.
  Future<void> patch({
    @required Map<String, Object> data,
    Reach reach,
  }) {
    return DocumentUpdateRequest(
      document: this,
      data: data,
      isPatch: true,
      reach: reach,
    ).delegateTo(parentDatabase.adapter);
  }

  @override
  String toString() => '$parent.document("$documentId")';

  /// Updates the document.
  ///
  /// If the document does not exist, the method will throw
  /// [DatabaseException.notFound].
  ///
  /// Optional parameter [reach] can be used to specify the minimum level of
  /// authority needed. For example:
  ///   * [Reach.local] tells that the write only needs to reach the local
  ///     database (which may synchronized with the global database later).
  ///   * [Reach.global] tells that the write should reach the global master
  ///     database.
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

  /// Upserts ("inserts or updates") the document.
  ///
  /// Optional parameter [reach] can be used to specify the minimum level of
  /// authority needed. For example:
  ///   * [Reach.local] tells that the write only needs to reach the local
  ///     database (which may synchronized with the global database later).
  ///   * [Reach.global] tells that the write should reach the global master
  ///     database.
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
  ///
  /// Some databases such as Firebase or Firestore support this operation
  /// natively. In other databases, the operation may be implemented with
  /// polling.
  Stream<Snapshot> watch({
    Schema schema,
    Duration interval,
    Reach reach,
  }) async* {
    // As long as the stream is not closed.
    while (true) {
      // Construct a stream.
      final stream = DocumentReadWatchRequest(
        document: this,
        outputSchema: schema,
        pollingInterval: interval,
        reach: reach,
      ).delegateTo(parentDatabase.adapter);

      // Yield the stream.
      yield* (stream);

      // Wait a bit before watching again.
      await Future.delayed(interval ?? const Duration(seconds: 1));
    }
  }
}
