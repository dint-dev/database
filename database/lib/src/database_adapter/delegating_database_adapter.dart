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
import 'package:database/mapper.dart';

/// Superclass for delegating database adapters.
class DelegatingDatabaseAdapter extends Database implements DatabaseAdapter {
  final DatabaseAdapter _database;

  const DelegatingDatabaseAdapter(this._database) : assert(_database != null);

  @override
  DatabaseAdapter get adapter => this;

  @override
  Future<void> checkHealth({Duration timeout}) {
    return _database.checkHealth(timeout: timeout);
  }

  @override
  Future<Document> collectionInsert(Collection collection,
      {Map<String, Object> data}) {
    return _database.collectionInsert(collection, data: data);
  }

  @override
  Schema getSchema({String collectionId, FullType fullType}) {
    return adapter.getSchema(collectionId: collectionId, fullType: fullType);
  }

  @override
  Stream<DatabaseExtensionResponse> performExtension(
      DatabaseExtensionRequest request) {
    return request.delegateTo(_database);
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) {
    return request.delegateTo(_database);
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) {
    return request.delegateTo(_database);
  }

  @override
  Future<void> performWrite(WriteRequest request) {
    return request.delegateTo(_database);
  }

  @override
  Future<void> runInTransaction({
    Duration timeout,
    Future<void> Function(Transaction transaction) callback,
  }) {
    return _database.runInTransaction(
      timeout: timeout,
      callback: callback,
    );
  }
}
