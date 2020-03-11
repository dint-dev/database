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

/// An adapter that stores data in the local memory.
///
/// ## Example
/// ```
/// import 'package:database/database.dart';
///
/// void main() {
///   final database = MemoryDatabaseAdapter().database();
/// }
/// ```
class MemoryDatabaseAdapter extends DocumentDatabaseAdapter {
  /// Values in the database.
  final Map<_Key, _Value> _values = {};

  /// Document scoring system.
  final DocumentScoring documentScoring;

  /// Latency for simulating latency in slower databases.
  final Duration latency;

  /// Constructs a new database.
  ///
  /// Optional parameter [documentScoring] defines how documents are scored.
  ///
  /// Optional parameter [latency] can be used for simulating non-memory
  /// databases.
  MemoryDatabaseAdapter({
    this.documentScoring = const DocumentScoring(),
    this.latency = const Duration(),
  })  : assert(documentScoring != null),
        assert(latency != null);

  int get length => _values.length;

  void clear() {
    _values.clear();
  }

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) async {
    await _wait();
    final key = _keyFromDocument(request.document);
    if (request.mustExist && !_values.containsKey(key)) {
      throw DatabaseException.notFound(request.document);
    }
    _values.remove(key);
  }

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) async {
    await _wait();
    const ArbitraryTreeSchema().checkTreeIsValid(request.data);
    final document = request.document ?? request.collection.newDocument();
    if (request.onDocument != null) {
      request.onDocument(document);
    }
    final key = _keyFromDocument(document);
    if (_values.containsKey(key)) {
      throw DatabaseException.found(document);
    }
    _values[key] = _Value(request.data);
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) async* {
    final key = _keyFromDocument(request.document);
    final value = _values[key];
    await _wait();
    if (value == null) {
      yield (Snapshot(
        document: request.document,
        data: null,
        exists: false,
      ));
    } else {
      yield (Snapshot(
        document: request.document,
        data: value.data,
      ));
    }
  }

  @override
  Stream<QueryResult> performDocumentSearch(
      DocumentSearchRequest request) async* {
    final collection = request.collection;
    final collectionId = collection.collectionId;
    if (collectionId.isEmpty) {
      throw ArgumentError('collectionId must be non-blank');
    }
    var iterable = _values.entries.where((entry) {
      return entry.key.collectionId == collectionId;
    }).map((entry) {
      final document = collection.document(entry.key.documentId);
      return Snapshot(
        document: document,
        data: entry.value.data,
      );
    });

    final query = request.query ?? const Query();
    final list = query.documentListFromIterable(
      iterable,
      documentScoring: documentScoring,
    );

    final result = QueryResult(
      collection: collection,
      query: query,
      snapshots: list,
    );
    await _wait();
    yield (result);
  }

  @override
  Future<void> performDocumentTransaction(DocumentTransactionRequest request) {
    throw DatabaseException.transactionUnsupported();
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) async {
    await _wait();
    const ArbitraryTreeSchema().checkTreeIsValid(request.data);
    final key = _keyFromDocument(request.document);
    final oldValue = _values[key];
    if (oldValue == null) {
      throw DatabaseException.notFound(request.document);
    }

    // Is this a patch?
    var data = request.data;
    if (request.isPatch) {
      final patchedData = Map<String, Object>.from(oldValue.data);
      patchedData.addAll(data);
      data = patchedData;
    }

    // Update
    _values[key] = _Value(request.data);
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) async {
    await _wait();
    const ArbitraryTreeSchema().checkTreeIsValid(request.data);
    final key = _keyFromDocument(request.document);
    _values[key] = _Value(request.data);
  }

  _Key _keyFromDocument(Document document) {
    final documentId = document.documentId;
    final collectionId = document.parent.collectionId;
    if (collectionId.isEmpty) {
      throw ArgumentError('collectionId must be non-blank');
    }
    if (documentId.isEmpty) {
      throw ArgumentError('documentId must be non-blank');
    }
    return _Key(
      collectionId,
      documentId,
    );
  }

  Future<void> _wait() {
    if (latency.inMicroseconds != 0) {
      return Future.delayed(latency);
    }
    return Future.value();
  }
}

class _Key {
  final String collectionId;
  final String documentId;

  _Key(this.collectionId, this.documentId);

  @override
  int get hashCode {
    final h = documentId.hashCode;
    return (h * 31) ^ h ^ collectionId.hashCode;
  }

  @override
  bool operator ==(other) =>
      other is _Key &&
      documentId == other.documentId &&
      collectionId == other.collectionId;

  @override
  String toString() => '$collectionId/$documentId';
}

class _Value {
  final Map<String, Object> data;
  _Value(this.data);
}
