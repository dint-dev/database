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

/// An adapter that stores data in the local memory.
///
/// An example:
/// ```
/// import 'package:database/adapters.dart';
/// import 'package:database/database.dart';
///
/// void main() {
///   Database.freezeDefaultInstance(
///     MemoryDatabase(),
///   );
///   // ...
/// }
/// ```
class MemoryDatabase extends DatabaseAdapter {
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
  MemoryDatabase({
    this.documentScoring = const DocumentScoring(),
    this.latency = const Duration(),
  })  : assert(documentScoring != null),
        assert(latency != null);

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    final document = request.document;
    final documentId = document.documentId;
    final collectionId = document.parent.collectionId;
    if (collectionId.isEmpty) {
      throw ArgumentError('collectionId must be non-blank');
    }
    if (documentId.isEmpty) {
      throw ArgumentError('documentId must be non-blank');
    }
    final key = _Key(
      collectionId,
      documentId,
    );
    final value = _values[key];
    await _wait();
    if (value == null) {
      yield (Snapshot(
        document: document,
        data: null,
        exists: false,
      ));
    } else {
      yield (Snapshot(
        document: document,
        data: value.data,
      ));
    }
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
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
  Future<void> performWrite(WriteRequest request) {
    final document = request.document;
    final documentId = document.documentId;
    final collectionId = document.parent.collectionId;
    if (collectionId.isEmpty) {
      throw ArgumentError('collectionId must be non-blank');
    }
    if (documentId.isEmpty) {
      throw ArgumentError('documentId must be non-blank');
    }
    final key = _Key(
      collectionId,
      documentId,
    );
    final map = _values;
    final exists = map[key] != null;

    // Does it matter whether the document exists?
    switch (request.type) {
      case WriteType.delete:
        if (!exists) {
          return Future<void>.error(DatabaseException.notFound(document));
        }
        map.remove(key);
        break;

      case WriteType.deleteIfExists:
        map.remove(key);
        break;

      case WriteType.insert:
        if (exists) {
          return Future<void>.error(DatabaseException.found(document));
        }
        map[key] = _Value(_immutableData(request.data));
        break;

      case WriteType.update:
        if (!exists) {
          return Future<void>.error(DatabaseException.notFound(document));
        }
        map[key] = _Value(_immutableData(request.data));
        break;

      case WriteType.upsert:
        map[key] = _Value(_immutableData(request.data));
        break;

      default:
        throw UnimplementedError();
    }

    // Return a future
    return _wait();
  }

  Object _immutableData(Object argument) {
    if (argument is List) {
      return List<Object>.unmodifiable(argument.map(_immutableData));
    }
    if (argument is Map) {
      final clone = <String, Object>{};
      for (var entry in argument.entries) {
        clone[entry.key] = _immutableData(entry.value);
      }
      return Map<String, Object>.unmodifiable(clone);
    }
    return argument;
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
  int get hashCode => documentId.hashCode ^ collectionId.hashCode;

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
