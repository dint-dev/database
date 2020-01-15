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

/// Connects the package [database](https://pub.dev/packages/database)
/// to [Google Cloud Firestore](https://cloud.google.com/firestore/). Works only
/// in browsers.
library database_adapter_firebase_browser;

import 'dart:async';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;
import 'package:meta/meta.dart';

Object _valueToFirestore(firestore.Firestore impl, Object argument) {
  if (argument == null ||
      argument is bool ||
      argument is num ||
      argument is DateTime ||
      argument is String) {
    return argument;
  }
  if (argument is GeoPoint) {
    return firestore.GeoPoint(argument.latitude, argument.longitude);
  }
  if (argument is Document) {
    final collectionId = argument.parent.collectionId;
    final documentId = argument.documentId;
    return impl.collection(collectionId).doc(documentId);
  }
  if (argument is List) {
    return argument.map((item) => _valueToFirestore(impl, item)).toList();
  }
  if (argument is Map) {
    final result = <String, Object>{};
    for (var entry in argument.entries) {
      result[entry.key] = _valueToFirestore(impl, entry.value);
    }
    return result;
  }
  throw ArgumentError.value(argument);
}

Object _valueFromFirestore(Database database, Object argument) {
  if (argument == null ||
      argument is bool ||
      argument is num ||
      argument is DateTime ||
      argument is String) {
    return argument;
  }
  if (argument is firestore.GeoPoint) {
    return GeoPoint(argument.latitude, argument.longitude);
  }
  if (argument is firestore.DocumentReference) {
    if (argument.parent.parent != null) {
      throw ArgumentError.value(argument);
    }
    final collectionId = argument.parent.id;
    final documentId = argument.id;
    return database.collection(collectionId).document(documentId);
  }
  if (argument is List) {
    return List.unmodifiable(
      argument.map((item) => _valueFromFirestore(database, item)),
    );
  }
  if (argument is Map) {
    final result = <String, Object>{};
    for (var entry in argument.entries) {
      result[entry.key as String] = _valueFromFirestore(database, entry.value);
    }
    return Map<String, Object>.unmodifiable(result);
  }
  throw ArgumentError.value(argument);
}

/// A database adapter for [Google Cloud Firestore](https://cloud.google.com/firestore/).
class FirestoreBrowser extends DatabaseAdapter {
  final firestore.Firestore _impl;

  /// Constructs a new adapter configuration.
  ///
  /// Parameters [appId] and [apiKey] can be null, but usually you need
  /// non-null values.
  factory FirestoreBrowser({
    @required String apiKey,
    @required String appId,
  }) {
    return FirestoreBrowser.withImpl(firebase.app(appId).firestore());
  }

  FirestoreBrowser.withImpl(this._impl);

  @override
  WriteBatch newWriteBatch() {
    return _WriteBatch(_impl, _impl.batch());
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.doc(document.documentId);
    final implSnapshot = await implDocument.get();
    yield (Snapshot(
      document: request.document,
      exists: implSnapshot.exists,
      data: _valueFromFirestore(request.document.database, implSnapshot.data),
    ));
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
    final collection = request.collection;
    final query = request.query;
    final implCollection = _impl.collection(collection.collectionId);
    firestore.Query fsQuery = implCollection;
    final result = fsQuery.onSnapshot.map((implSnapshot) {
      final snapshots = implSnapshot.docs.map((implSnapshot) {
        return Snapshot(
          document: collection.document(
            implSnapshot.id,
          ),
          data: _valueFromFirestore(
            request.collection.database,
            implSnapshot.data,
          ),
        );
      });
      return QueryResult(
        collection: collection,
        query: query,
        snapshots: List<Snapshot>.unmodifiable(snapshots),
      );
    });
    if (request.isChunked) {
      yield (await result.last);
    } else {
      yield* (result);
    }
  }

  @override
  Future<void> performWrite(WriteRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.doc(document.documentId);

    final implDataOrNull = _valueToFirestore(_impl, request.data);
    Map<String, Object> implData;
    if (implDataOrNull is Map<String, Object>) {
      implData = implDataOrNull;
    }

    switch (request.type) {
      case WriteType.delete:
        bool didFail;
        await _impl.runTransaction((transaction) async {
          final implSnapshot = await transaction.get(implDocument);
          if (!implSnapshot.exists) {
            didFail = true;
            return null;
          }
          await transaction.delete(implDocument);
          didFail = false;
          return null;
        });
        if (didFail) {
          throw DatabaseException.notFound(document);
        }
        return;

      case WriteType.deleteIfExists:
        await implDocument.delete();
        break;

      case WriteType.insert:
        bool didFail;
        await _impl.runTransaction((transaction) async {
          final implSnapshot = await transaction.get(implDocument);
          if (implSnapshot.exists) {
            didFail = true;
            return null;
          }
          await transaction.set(implDocument, implData);
          didFail = false;
          return null;
        });
        if (didFail) {
          throw DatabaseException.found(document);
        }
        return;

      case WriteType.update:
        try {
          await implDocument.update(data: implData);
        } catch (e) {
          throw DatabaseException.notFound(document);
        }
        return;

      case WriteType.upsert:
        await implDocument.set(implData);
        return;

      default:
        throw UnimplementedError();
    }
  }
}

class _WriteBatch implements WriteBatch {
  final firestore.Firestore _impl;
  final firestore.WriteBatch _writeBatch;

  final _completer = Completer();

  _WriteBatch(this._impl, this._writeBatch);

  @override
  Future get done => _completer.future;

  @override
  Future<void> commit() async {
    await _writeBatch.commit();
    _completer.complete();
  }

  @override
  Future<void> deleteIfExists(Document document) async {
    final implDocument =
        _valueToFirestore(_impl, document) as firestore.DocumentReference;
    await _writeBatch.delete(implDocument);
  }

  @override
  Future<void> update(Document document, {Map<String, Object> data}) async {
    final implDocument =
        _valueToFirestore(_impl, document) as firestore.DocumentReference;
    final implValue = _valueToFirestore(_impl, data);
    await _writeBatch.update(implDocument, data: implValue);
  }

  @override
  Future<void> upsert(Document document, {Map<String, Object> data}) async {
    final implDocument =
        _valueToFirestore(_impl, document) as firestore.DocumentReference;
    final implValue = _valueToFirestore(_impl, data);
    await _writeBatch.set(implDocument, implValue);
  }
}
