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

import 'package:datastore/adapters_framework.dart';
import 'package:datastore/datastore.dart';
import 'package:firebase/firebase.dart' as firebase_core;
import 'package:firebase/firestore.dart' as firestore;
import 'package:meta/meta.dart';

import 'google_cloud_firestore.dart';

class FirestoreImpl extends DatastoreAdapter implements Firestore {
  final firestore.Firestore _impl;

  factory FirestoreImpl({
    @required String apiKey,
    @required String appId,
  }) {
    if (appId == null) {
      return FirestoreImpl._(firebase_core.firestore());
    }
    final implApp = firebase_core.initializeApp(
      name: appId,
      apiKey: apiKey,
    );
    final impl = implApp.firestore();
    return FirestoreImpl._(impl);
  }

  FirestoreImpl._(this._impl);

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    final document = request.document;
    final collection = document.parent;
    final datastore = collection.datastore;
    final schema = request.schema;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.doc(document.documentId);
    final implSnapshot = await implDocument.get();
    yield (Snapshot(
      document: document,
      exists: implSnapshot.exists,
      data: _dataToDart(
        datastore,
        schema,
        implSnapshot.data(),
      ),
    ));
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
    final collection = request.collection;
    final datastore = collection.datastore;
    final schema = request.schema;
    final query = request.query;
    firestore.Query fsQuery = _impl.collection(collection.collectionId);
    final result = fsQuery.onSnapshot.map((implSnapshot) {
      final snapshots = implSnapshot.docs.map((implSnapshot) {
        return Snapshot(
          document: collection.document(
            implSnapshot.id,
          ),
          exists: implSnapshot.exists,
          data: _dataToDart(
            datastore,
            schema,
            implSnapshot.data(),
          ),
        );
      });
      return QueryResult(
        collection: collection,
        query: query,
        snapshots: List<Snapshot>.unmodifiable(snapshots),
      );
    });
    yield* (result);
  }

  @override
  Future<void> performWrite(WriteRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final implCollection = _impl.collection(collection.collectionId);
    final implDocument = implCollection.doc(document.documentId);
    final implData = _dataFromDart(request.schema, request.data);

    switch (request.type) {
      case WriteType.delete:
        await implDocument.delete();
        return;

      case WriteType.deleteIfExists:
        await implDocument.delete();
        return;

      case WriteType.insert:
        await implDocument.set(implData);
        return;

      case WriteType.update:
        await implDocument.set(implData);
        return;

      case WriteType.upsert:
        await implDocument.set(implData);
        return;

      default:
        throw UnimplementedError();
    }
  }

  Map<String, Object> _dataFromDart(Schema schema, Map<String, Object> data) {
    // A special case
    if (data == null) {
      return null;
    }
    var attachSchema = false;
    if (schema == null) {
      schema = Schema.fromValue(data);
      attachSchema = true;
    }

    // Dart tree --> Firestore tree
    final newData = schema.encodeLessTyped(
      data,
      context: LessTypedEncodingContext(
          supportsDateTime: true,
          supportsDocument: true,
          mapDocument: (value) {
            return _impl
                .collection(value.parent.collectionId)
                .doc(value.documentId);
          },
          supportsGeoPoint: true,
          mapGeoPoint: (value) {
            return firestore.GeoPoint(
              value.latitude,
              value.longitude,
            );
          }),
    ) as Map<String, Object>;

    if (!attachSchema) {
      return newData;
    }

    // We attach schema to the data
    final dataWithSchema = Map<String, Object>.from(newData);
    dataWithSchema['@schema'] = schema.toJson();
    return Map<String, Object>.unmodifiable(dataWithSchema);
  }

  Map<String, Object> _dataToDart(
      Datastore datastore, Schema schema, Map<String, Object> data) {
    // A special case
    if (data == null) {
      return null;
    }

    if (schema == null) {
      // See whether the data has schema attached
      final schemaJson = data['@schema'];
      if (schemaJson != null) {
        schema = Schema.fromJson(schemaJson);
      }

      // Use arbitrary schema otherwise
      schema ??= ArbitraryTreeSchema();
    }

    // Firestore tree --> Dart tree
    return schema.decodeLessTyped(
      data,
      context: LessTypedDecodingContext(
        datastore: datastore,
        onUnsupported: (context, value) {
          if (value is firestore.GeoPoint) {
            return GeoPoint(
              value.latitude,
              value.longitude,
            );
          }
          if (value is firestore.DocumentReference) {
            return context.datastore
                .collection(value.parent.id)
                .document(value.id);
          }
          throw ArgumentError.value(value);
        },
      ),
    ) as Map<String, Object>;
  }
}
