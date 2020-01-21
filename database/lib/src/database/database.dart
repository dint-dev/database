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
import 'package:database/sql.dart';
import 'package:meta/meta.dart';

/// A database contains any number of collections ([Collection]). A collection
/// contains any number of documents ([Document]).
abstract class Database {
  /// Cached collections.
  final _collections = <String, Collection>{};

  SqlClient _sqlClient;

  Database();

  factory Database.withAdapter(DatabaseAdapter adapter) = _Database;

  /// Database adapter that implements operations for this database.
  DatabaseAdapter get adapter;

  SqlClient get sqlClient {
    return _sqlClient ??= SqlClient(this);
  }

  /// Checks that the database can be used.
  ///
  /// The future will complete with a descriptive error if the database can't be
  /// used.
  Future<void> checkHealth() async {}

  /// Returns a collection with the name.
  Collection collection(String collectionId) {
    // A small optimization: we cache collections.s
    final collections = _collections;
    var collection = collections[collectionId];
    if (collection != null) {
      return collection;
    }

    // Keep maximum 100 collections in memory
    if (collections.length > 100) {
      collections.clear();
    }

    // Add collection
    collection = Collection(this, collectionId);
    collections[collectionId] = collection;
    return collection;
  }

  /// Return a new write batch. This should always succeed.
  WriteBatch newWriteBatch() {
    return WriteBatch.simple();
  }

  /// Begins a transaction.
  ///
  /// Note that many database implementations do not support transactions.
  /// Adapter should throw [DatabaseException.transactionUnsupported] if it
  /// doesn't support transactions.
  Future<void> runInTransaction({
    Reach reach,
    Duration timeout,
    @required Future<void> Function(Transaction transaction) callback,
  }) async {
    throw UnsupportedError(
      'Transactions are not supported by $runtimeType',
    );
  }

  @override
  String toString() => 'Database(...)';
}

class _Database extends Database {
  @override
  final DatabaseAdapter adapter;

  _Database(this.adapter);
}
