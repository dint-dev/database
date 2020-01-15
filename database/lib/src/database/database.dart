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

/// A database contains any number of collections ([Collection]). A collection
/// contains any number of documents ([Document]).
abstract class Database {
  const Database();

  /// Actual low-level implementation of the database methods.
  DatabaseAdapter get adapter;

  /// Checks that the database can be used.
  ///
  /// The future will complete with a descriptive error if the database can't be
  /// used.
  Future<void> checkHealth();

  /// Returns a collection with the name.
  Collection collection(String collectionId) {
    return Collection(this, collectionId);
  }

  Future<SqlResponse> executeSql(String sql) {
    ArgumentError.checkNotNull(sql);
    return executeSqlArgs(sql, const []);
  }

  // TODO: Transaction options (consistency, etc.)
  Future<SqlResponse> executeSqlArgs(String sql, List arguments) async {
    ArgumentError.checkNotNull(sql);
    ArgumentError.checkNotNull(arguments);
    return SqlRequest(
      sql,
      arguments,
      isNotQuery: true,
    ).delegateTo(adapter);
  }

  /// Return a new write batch. This should always succeed.
  WriteBatch newWriteBatch() {
    return WriteBatch.simple();
  }

  Future<SqlResponse> querySqlArgsSnapshots(String sql, List arguments) async {
    ArgumentError.checkNotNull(sql);
    ArgumentError.checkNotNull(arguments);
    return SqlRequest(
      sql,
      arguments,
    ).delegateTo(adapter);
  }

  Future<SqlResponse> querySqlSnapshots(String sql) {
    ArgumentError.checkNotNull(sql);
    return querySqlArgsSnapshots(sql, const []);
  }

  /// Begins a transaction.
  ///
  /// Note that many database implementations do not support transactions.
  /// Adapter should throw [DatabaseException.transactionUnsupported] if it
  /// doesn't support transactions.
  Future<void> runInTransaction({
    @required Future<void> Function(Transaction transaction) callback,
    Duration timeout,
  }) async {
    throw UnsupportedError(
      'Transactions are not supported by $runtimeType',
    );
  }
}
