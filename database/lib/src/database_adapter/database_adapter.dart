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
import 'package:meta/meta.dart';

/// Superclass for database adapters.
///
/// If your adapter delegates calls to another adopter, you should extend
/// [DelegatingDatabaseAdapter].
///
/// If your adapter is read-only, you should use mixin
/// [ReadOnlyDatabaseAdapterMixin].
abstract class DatabaseAdapter extends Database {
  @override
  DatabaseAdapter get adapter => this;

  /// Performs health check.
  @override
  Future<void> checkHealth({Duration timeout}) {
    return Future<void>.value();
  }

  /// Closes the database adapter.
  @mustCallSuper
  Future<void> close() async {}

  /// Called by document. Databases that can issue their own IDs should override
  /// this method.
  Future<Document> collectionInsert(Collection collection,
      {Map<String, Object> data}) async {
    final document = collection.newDocument();
    await document.insert(data: data);
    return document;
  }

  /// Returns schema of the [collectionId] or [fullType].
  Schema getSchema({String collectionId, FullType fullType}) {
    return null;
  }

  /// Performs vendor extension.
  @protected
  Stream<DatabaseExtensionResponse> performExtension(
    DatabaseExtensionRequest request,
  ) {
    return request.unsupported(this);
  }

  /// Performs document reading.
  @protected
  Stream<Snapshot> performRead(
    ReadRequest request,
  );

  /// Performs document searching.
  @protected
  Stream<QueryResult> performSearch(
    SearchRequest request,
  );

  @protected
  Future<SqlResponse> performSql(
    SqlRequest request,
  ) async {
    throw UnsupportedError('Adapter does not support SQL: $runtimeType');
  }

  /// Performs document writing.
  @protected
  Future<void> performWrite(
    WriteRequest request,
  );
}
