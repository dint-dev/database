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

/// Enables access to databases.
///
/// The API is designed to support:
///   * SQL databases
///   * Document databases
///   * Search engines
///
/// ## Examples
/// ### Hello world
/// ```
/// import 'package:database/database.dart';
///
/// Future main() async {
///   // Configure an in-memory database
///   final database = MemoryDatabaseAdapter().database();
///
///   // Insert a greeting
///   await database.collection('greetings').insert({
///     'text': 'Hello world!',
///   });
///
///   // Print greetings
///   await for (var snapshot in database.collection('greetings').search()) {
///     print(snapshot.data['text']);
///   }
/// }
/// ```
///
/// ### Direct SQL access
///
/// ```
/// import 'package:database/database.dart';
/// import 'package:database/sql.dart';
/// import 'package:database_adapter_postgre/database_adapter_postgre.dart';
///
/// Future main() async {
///   // Configure a PostgreSQL database connection
///   final database = PostgreAdapter(
///     // ...
///   ).database();
///
///   // Insert rows
///   await database.sqlClient.execute(
///     'INSERT INTO employee(name) VALUES (?)',
///     ['John Doe'],
///   );
/// }
/// ```
library database;

export 'package:fixnum/fixnum.dart' show Int64;

export 'src/database/adapters/caching.dart';
export 'src/database/adapters/memory.dart';
export 'src/database/adapters/schema_enforcing.dart';
export 'src/database/adapters/search_engine_promoting.dart';
export 'src/database/collection.dart';
export 'src/database/column.dart';
export 'src/database/database.dart';
export 'src/database/document.dart';
export 'src/database/exceptions.dart';
export 'src/database/extensions.dart';
export 'src/database/primitives/blob.dart';
export 'src/database/primitives/date.dart';
export 'src/database/primitives/geo_point.dart';
export 'src/database/primitives/timestamp.dart';
export 'src/database/query.dart';
export 'src/database/query_result.dart';
export 'src/database/query_result_item.dart';
export 'src/database/reach.dart';
export 'src/database/snapshot.dart';
export 'src/database/sorter.dart';
export 'src/database/transaction.dart';
