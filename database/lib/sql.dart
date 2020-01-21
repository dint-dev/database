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

/// Supports accessing databases using SQL language.
///
/// ## Example
/// ```
/// // Configure database
/// final database = MyDatabaseAdapter().database();
///
/// // Get SQL client. Currently only SQL databases support this.
/// final sqlClient = database.sqlClient;
///
/// // Read matching rows
/// final products = sqlClient.query(
///   'SELECT * FROM employee WHERE role = ?',
///   ['software developer],
/// ).toMapStream();
///
/// // Iterate the stream
/// await for (var product in products) {
///   print('Name: ${product['name']}');
/// }
/// ```
library database.sql;

import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

part 'src/sql/sql_client.dart';
part 'src/sql/sql_client_table_helper.dart';
part 'src/sql/sql_client_table_query_helper.dart';
part 'src/sql/sql_client_table_selection_helper.dart';
part 'src/sql/sql_column_description.dart';
part 'src/sql/sql_iterator.dart';
part 'src/sql/sql_source_builder.dart';
part 'src/sql/sql_statement.dart';
part 'src/sql/sql_statement_result.dart';
part 'src/sql/sql_transaction.dart';
