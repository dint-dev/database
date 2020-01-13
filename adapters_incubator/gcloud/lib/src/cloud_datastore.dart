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

/// An adapter for using [Cloud Database](https://cloud.google.com/database).
/// a commercial cloud service by Google.
library database_adapter_gcloud;

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:googleapis/datastore/v1.dart' as impl;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'auth.dart';

/// An adapter for using [Cloud Database](https://cloud.google.com/database).
/// a commercial cloud service by Google.
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
class GoogleCloudDatastore extends DatabaseAdapter {
  final impl.DatastoreApi api;
  final String projectId;

  GoogleCloudDatastore.withApi(this.api, {@required this.projectId});

  factory GoogleCloudDatastore.withApiKey({
    @required String apiKey,
    @required String projectId,
  }) {
    ArgumentError.checkNotNull(apiKey);
    return GoogleCloudDatastore.withHttpClient(
      client: newGoogleCloudClientWithApiKey(apiKey),
      projectId: projectId,
    );
  }

  factory GoogleCloudDatastore.withHttpClient({
    @required http.Client client,
    @required String projectId,
  }) {
    return GoogleCloudDatastore.withApi(impl.DatastoreApi(client),
        projectId: projectId);
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    final document = request.document;
    final implOutput = await api.projects.lookup(
      impl.LookupRequest()..keys.add(_implKeyFromDocument(document)),
      projectId,
    );
    for (var implFound in implOutput.found) {
      final implEntity = implFound.entity;
      if (implEntity != null) {
        final foundDocument = _implKeyToDocument(implEntity.key);
        if (foundDocument == document) {
          yield (Snapshot(
            document: document,
            data: implEntity.properties,
          ));
          return;
        }
      }
    }
    yield (null);
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
    final collection = request.collection;
    final query = request.query;
    final implQuery = impl.Query();
    final implRequest = impl.RunQueryRequest()..query = implQuery;
    final implResponse = await api.projects.runQuery(
      implRequest,
      projectId,
    );
    final implBatch = implResponse.batch;
    final snapshots = <Snapshot>[];
    for (var implEntityResult in implBatch.entityResults) {
      final implEntity = implEntityResult.entity;
      final document = _implKeyToDocument(implEntity.key);
      final data = implEntity.properties;
      snapshots.add(Snapshot(
        document: document,
        data: data,
      ));
    }
    yield (QueryResult(
      query: query,
      collection: collection,
      snapshots: List<Snapshot>.unmodifiable(snapshots),
    ));
  }

  @override
  Future<void> performWrite(WriteRequest request) async {
    final implMutation = impl.Mutation();
    switch (request.type) {
      case WriteType.delete:
        implMutation.delete = _implKeyFromDocument(request.document);
        break;

      case WriteType.deleteIfExists:
        implMutation.delete = _implKeyFromDocument(request.document);
        break;

      case WriteType.insert:
        implMutation.insert = impl.Entity()
          ..key = _implKeyFromDocument(request.document)
          ..properties = request.data;
        break;

      case WriteType.update:
        implMutation.update = impl.Entity()
          ..key = _implKeyFromDocument(request.document)
          ..properties = request.data;
        break;

      case WriteType.upsert:
        implMutation.upsert = impl.Entity()
          ..key = _implKeyFromDocument(request.document)
          ..properties = request.data;
        break;

      default:
        throw UnimplementedError();
    }
    final implCommitRequest = impl.CommitRequest();
    implCommitRequest.mutations.add(implMutation);
    await api.projects.commit(
      implCommitRequest,
      projectId,
    );
  }

  impl.Key _implKeyFromDocument(Document document) {
    final collectionId = document.parent.collectionId;
    final documentId = document.documentId;
    return impl.Key()
      ..path.add(impl.PathElement()
        ..kind = collectionId
        ..id = documentId);
  }

  Document _implKeyToDocument(impl.Key impl) {
    final implPath = impl.path.single; // TODO: Longer paths
    final kind = implPath.kind;
    final id = implPath.name;
    return collection(kind).document(id);
  }
}
