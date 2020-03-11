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

/// Connects the package [database](https://pub.dev/packages/database)
/// to [Google Cloud Firestore](https://cloud.google.com/firestore/).
/// Works only in Flutter.
library database_adapter_firestore_flutter;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/filter.dart';
import 'package:database/schema.dart';

Object _valueFromFirestore(Database database, Object argument) {
  if (argument == null ||
      argument is bool ||
      argument is num ||
      argument is String) {
    return argument;
  }
  if (argument is DateTime) {
    return argument.toUtc();
  }
  if (argument is firestore.Timestamp) {
    return argument.toDate().toUtc();
  }
  if (argument is firestore.GeoPoint) {
    return GeoPoint(argument.latitude, argument.longitude);
  }
  if (argument is firestore.DocumentReference) {
    if (argument.parent().parent() != null) {
      throw ArgumentError.value(argument);
    }
    final collectionId = argument.parent().id;
    final documentId = argument.documentID;
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

Object _valueToFirestore(firestore.Firestore impl, Object argument) {
  if (argument == null ||
      argument is bool ||
      argument is num ||
      argument is DateTime ||
      argument is String) {
    return argument;
  }
  if (argument is Int64) {
    return argument.toInt();
  }
  if (argument is Date) {
    return argument.toString();
  }
  if (argument is Timestamp) {
    return argument.toString();
  }
  if (argument is GeoPoint) {
    return firestore.GeoPoint(argument.latitude, argument.longitude);
  }
  if (argument is Document) {
    final collectionId = argument.parent.collectionId;
    final documentId = argument.documentId;
    return impl.collection(collectionId).document(documentId);
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

/// A database adapter for [Google Cloud Firestore](https://cloud.google.com/firestore/).
///
/// ```
/// final database = FirestoreFlutter();
/// database.collection('greeting').insert({'value': 'Hello world!'});
/// ```
class FirestoreFlutter extends DocumentDatabaseAdapter {
  final firestore.Firestore _impl;

  /// Uses the default Firestore configuration.
  factory FirestoreFlutter() {
    return FirestoreFlutter.withImpl(firestore.Firestore.instance);
  }

  /// Enables choosing a custom Firestore configuration.
  FirestoreFlutter.withImpl(this._impl);

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.document(document.documentId);

    if (request.mustExist) {
      var didFail = false;
      await _impl.runTransaction((transaction) async {
        final implSnapshot = await transaction.get(implDocument);
        if (!implSnapshot.exists) {
          didFail = true;
          // If we return, we will have an exception.
          //
          // I'm not sure whether it would make more sense to return or
          // delete.
        }
        await transaction.delete(implDocument);
        return null;
      });
      if (didFail) {
        throw DatabaseException.notFound(document);
      }
    } else {
      return implDocument.delete();
    }
  }

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.document(document.documentId);
    final implData = _valueToFirestore(_impl, request.data);

    //
    // A preliminary checkup of existence
    //
    final implSnapshot = await implDocument.get(
      source: firestore.Source.server,
    );
    if (implSnapshot.exists) {
      throw DatabaseException.found(document);
    }

    //
    // Actual transaction
    //
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
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) async* {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.document(document.documentId);
    final implSnapshot = await implDocument.get();
    if (!implSnapshot.exists) {
      yield (Snapshot.notFound(document));
      return;
    }
    var value = _valueFromFirestore(
      request.document.database,
      implSnapshot.data,
    );
    final schema = request.outputSchema;
    if (schema != null) {
      value = schema.decodeWith(
        JsonDecoder(database: collection.database),
        value,
      );
    }
    yield (Snapshot(
      document: document,
      data: value,
    ));
  }

  @override
  Stream<QueryResult> performDocumentSearch(
      DocumentSearchRequest request) async* {
    final collection = request.collection;
    final query = request.query ?? Query();
    final implCollection = _impl.collection(collection.collectionId);
    firestore.Query implQuery = implCollection;

    //
    // Filter
    //
    implQuery = _handleFilter(implQuery, null, query.filter);

    //
    // Sorters
    //
    {
      final sorter = query.sorter;
      if (sorter != null) {
        if (sorter is MultiSorter) {
          //
          // Many sorters
          //
          for (var sorter in sorter.sorters) {
            if (sorter is PropertySorter) {
              implQuery = implQuery.orderBy(
                sorter.name,
                descending: sorter.isDescending,
              );
            } else {
              throw UnsupportedError('${sorter.runtimeType}');
            }
          }
        } else if (sorter is PropertySorter) {
          //
          // Single sorter
          //
          implQuery = implQuery.orderBy(
            sorter.name,
            descending: sorter.isDescending,
          );
        } else {
          throw UnsupportedError('${sorter.runtimeType}');
        }
      }
    }

    // Skip is handled later in the function because Firestore API doesn't
    // support it natively.

    //
    // Take
    //
    {
      final take = query.take;
      if (take != null) {
        implQuery = implQuery.limit(take);
      }
    }

    // TODO: Watching, incremental results

    final implSnapshot = await implQuery.getDocuments();
    final snapshots = implSnapshot.documents
        .skip(
      query.skip ?? 0,
    )
        .map((implSnapshot) {
      final document = collection.document(
        implSnapshot.documentID,
      );
      var value = _valueFromFirestore(
        request.collection.database,
        implSnapshot.data,
      );
      final schema = request.outputSchema;
      if (schema != null) {
        value = schema.decodeWith(
          JsonDecoder(database: collection.database),
          value,
        );
      }
      return Snapshot(
        document: document,
        data: value,
      );
    });
    final queryResult = QueryResult(
      collection: collection,
      query: query,
      snapshots: List<Snapshot>.unmodifiable(snapshots),
    );
    yield (queryResult);
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.document(document.documentId);
    final implData = _valueToFirestore(_impl, request.data);

    try {
      await implDocument.updateData(implData);
    } catch (e) {
      throw DatabaseException.notFound(document);
    }
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.document(document.documentId);
    final implData = _valueToFirestore(_impl, request.data);

    await implDocument.setData(implData);
  }

  firestore.Query _handleFilter(
      firestore.Query q, String propertyName, Filter filter) {
    if (filter == null) {
      return q;
    } else if (filter is AndFilter) {
      for (var filter in filter.filters) {
        q = _handleFilter(q, propertyName, filter);
      }
      return q;
    } else if (filter is MapFilter) {
      if (propertyName != null) {
        throw UnsupportedError('Nested properties');
      }
      for (var entry in filter.properties.entries) {
        q = _handleFilter(q, entry.key, _valueToFirestore(_impl, entry.value));
      }
      return q;
    } else if (filter is ValueFilter) {
      return q.where(
        propertyName,
        isEqualTo: _valueToFirestore(_impl, filter.value),
      );
    } else if (filter is RangeFilter) {
      if (filter.min != null) {
        if (filter.isExclusiveMin) {
          q = q.where(
            propertyName,
            isGreaterThan: _valueToFirestore(_impl, filter.min),
          );
        } else {
          q = q.where(
            propertyName,
            isGreaterThanOrEqualTo: _valueToFirestore(_impl, filter.min),
          );
        }
      }
      if (filter.max != null) {
        if (filter.isExclusiveMin) {
          q = q.where(
            propertyName,
            isGreaterThan: _valueToFirestore(_impl, filter.max),
          );
        } else {
          q = q.where(
            propertyName,
            isGreaterThanOrEqualTo: _valueToFirestore(_impl, filter.max),
          );
        }
      }
      return q;
    } else {
      throw UnsupportedError('${filter.runtimeType}');
    }
  }
}
