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
import 'package:meta/meta.dart';

/// Enforces schemas on documents.
class SchemaUsingDatabase extends DelegatingDatabaseAdapter {
  final Map<String, Schema> schemaByCollection;
  final Schema validatedCommonSchema;
  final Schema otherCollections;

  SchemaUsingDatabase({
    @required Database database,
    @required this.schemaByCollection,
    this.validatedCommonSchema,
    this.otherCollections,
  })  : assert(database != null),
        super(database);

  Schema getSchema(String collectionId) {
    if (schemaByCollection == null) {
      return otherCollections;
    }
    return schemaByCollection[collectionId] ?? otherCollections;
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) {
    request.schema ??= getSchema(request.document.parent.collectionId);
    return super.performRead(request);
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) {
    request.schema ??= getSchema(request.collection.collectionId);
    return super.performSearch(request);
  }

  @override
  Future<void> performWrite(WriteRequest request) async {
    final document = request.document;
    final collectionId = document.parent.collectionId;
    final schema = getSchema(collectionId);
    request.schema ??= schema;

    if (isDeleteWriteType(request.type)) {
      return super.performWrite(request);
    }

    // Check that we found a schema
    if (schema == null) {
      throw ArgumentError('Invalid collection "$collectionId"');
    }

    // Validate that data matches the common schema
    final data = request.data;
    if (validatedCommonSchema != null &&
        !validatedCommonSchema.isValidTree(data)) {
      throw ArgumentError('Doesn\'t match common schema');
    }

    // Validate data
    if (!schema.isValidTree(data)) {
      throw ArgumentError('Doesn\'t match schema "$collectionId"');
    }

    request.schema = schema;
    return super.performWrite(request);
  }
}
