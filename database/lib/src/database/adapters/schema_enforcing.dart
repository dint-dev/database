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
import 'package:database/src/database_adapter/requests/schema_read_request.dart';
import 'package:meta/meta.dart';

/// Enforces schema validation on writes.
///
/// This class can be useful for detecting programming errors.
/// The schema is loaded from the database adapter tree with
/// `document.schema()`. If you use a schemaless database, you can define
/// schema in the constructor of this adapter.
///
/// ## Example
/// ```
/// import 'package:database/database.dart';
///
/// // Database schema
/// final schema = DatabaseSchema(
///   schemas: [
///     productSchema,
///     productCategorySchema,
///   ],
/// });
///
///
/// final productSchema = CollectionSchema(
///   id: 'Product',
///   schemaBuilder: () => MapSchema({
///     'name': StringSchema(),
///     'price': DoubleSchema(),
///     'category': DocumentSchema(
///       const ['category_id'],
///       productCategorySchema,
///       const ['id'],
///     ),
///   }),
/// );
///
/// final productCategorySchema = CollectionSchema(
///   id: 'ProductCategory',
///   schemaBuilder: () => MapSchema({
///     'name': StringSchema(),
///     'products': DocumentListSchema(
///       const ['id'],
///       productSchema,
///       const ['category_id'],
///     ),
///   }),
/// );
///
/// void main() {
///   final database = SchemaEnforcingAdapter(
///     databaseSchema: schema,
///   ).database();
/// }
/// ```
class SchemaEnforcingDatabaseAdapter extends DelegatingDatabaseAdapter {
  final DatabaseSchema databaseSchema;

  SchemaEnforcingDatabaseAdapter({
    @required DatabaseAdapter adapter,
    @required this.databaseSchema,
  }) : super(adapter);

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) async {
    final schema = await request.collection.schema();
    request.inputSchema ??= schema;
    schema?.checkTreeIsValid(request.data);
    return super.performDocumentInsert(request);
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) async* {
    final schema = await request.document.parent.schema();
    request.outputSchema ??= schema;
    yield* (super.performDocumentRead(request));
  }

  @override
  Stream<Snapshot> performDocumentReadWatch(
      DocumentReadWatchRequest request) async* {
    final schema = await request.document.parent.schema();
    request.outputSchema ??= schema;
    yield* (super.performDocumentReadWatch(request));
  }

  @override
  Stream<QueryResult> performDocumentSearch(
      DocumentSearchRequest request) async* {
    final schema = await request.collection.schema();
    request.outputSchema ??= schema;
    yield* (super.performDocumentSearch(request));
  }

  @override
  Stream<QueryResult> performDocumentSearchWatch(
      DocumentSearchWatchRequest request) async* {
    final schema = await request.collection.schema();
    request.outputSchema ??= schema;
    yield* (super.performDocumentSearchWatch(request));
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) async {
    final schema = await request.document.parent.schema();
    request.inputSchema ??= schema;
    schema?.checkTreeIsValid(request.data);
    return super.performDocumentUpdate(request);
  }

  @override
  Future<void> performDocumentUpdateBySearch(
      DocumentUpdateBySearchRequest request) async {
    final schema = await request.collection.schema();
    request.inputSchema ??= schema;
    schema?.checkTreeIsValid(request.data);
    return super.performDocumentUpdateBySearch(request);
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) async {
    final schema = await request.document.parent.schema();
    request.inputSchema ??= schema;
    schema?.checkTreeIsValid(request.data);
    return super.performDocumentUpsert(request);
  }

  @override
  Stream<DatabaseSchema> performSchemaRead(SchemaReadRequest request) {
    if (databaseSchema == null) {
      return super.performSchemaRead(request);
    }
    return Stream<DatabaseSchema>.value(databaseSchema);
  }
}
