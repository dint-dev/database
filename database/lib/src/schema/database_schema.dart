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
import 'package:database/schema.dart';

/// Describes database schema.
class DatabaseSchema {
  /// Schemas by collection ID.
  final Map<String, Schema> schemasByCollection;

  /// Default schema for any collection that doesn't have a schema specified by
  /// [schemasByCollection].
  ///
  /// If null, only collections specified by [schemasByCollection] can be used.
  final Schema defaultSchema;

  DatabaseSchema({
    this.schemasByCollection,
    this.defaultSchema,
  });

  Schema getSchemaForCollection(Collection collection) {
    if (schemasByCollection != null) {
      final schema = schemasByCollection[collection.collectionId];
      if (schema != null) {
        return schema;
      }
    }
    return defaultSchema;
  }
}
