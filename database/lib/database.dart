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

/// An unified database API.
///
/// The API aims to be usable with:
///   * Relational (SQL) databases
///   * Document databases
///   * Search engines.
///
/// An example:
/// ```
/// import 'package:database/database.dart';
///
/// void main() {
///   final memoryDatabase = MemoryDatabase();
///   memoryDatabase.collection('employee').insert({
///     'name': 'John Doe',
///   });
/// }
///
/// ```
library database;

export 'package:fixnum/fixnum.dart' show Int64;

export 'src/database/adapters/caching_database.dart';
export 'src/database/adapters/memory_database.dart';
export 'src/database/adapters/schema_using_database.dart';
export 'src/database/adapters/search_forwarding_database.dart';
export 'src/database/collection.dart';
export 'src/database/column_description.dart';
export 'src/database/database.dart';
export 'src/database/document.dart';
export 'src/database/exceptions.dart';
export 'src/database/extensions.dart';
export 'src/database/filters/basic_filters.dart';
export 'src/database/filters/filter.dart';
export 'src/database/filters/filter_visitor.dart';
export 'src/database/filters/keyword_filter.dart';
export 'src/database/filters/logical_filters.dart';
export 'src/database/filters/sql_filter.dart';
export 'src/database/primitives/blob.dart';
export 'src/database/primitives/date.dart';
export 'src/database/primitives/geo_point.dart';
export 'src/database/primitives/timestamp.dart';
export 'src/database/query.dart';
export 'src/database/query_result.dart';
export 'src/database/query_result_item.dart';
export 'src/database/schemas/schema.dart';
export 'src/database/schemas/schema_visitor.dart';
export 'src/database/snapshot.dart';
export 'src/database/sorter.dart';
export 'src/database/sql_response.dart';
export 'src/database/transaction.dart';
