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

/// A set of collections ([Collection]).
///
/// An example:
///
///     Future<void> main() async {
///       // Use an in-memory database
///       final database = MemoryDatabaseAdapter().database();
///
///       // Our collection
///       final collection = database.collection('pizzas');
///
///       // Our document
///       final document = collection.newDocument();
///
///       await document.insert({
///         'name': 'Pizza Margherita',
///         'rating': 3.5,
///         'ingredients': ['dough', 'tomatoes'],
///         'similar': [
///           database.collection('recipes').document('pizza_funghi'),
///         ],
///       });
///       print('Successfully inserted pizza.');
///
///       await document.patch({
///         'rating': 4.5,
///       });
///       print('Successfully patched pizza.');
///
///       await document.delete();
///       print('Successfully deleted pizza.');
///     }
///
abstract class Database {
  /// Cached collections.
  final _collections = <String, Collection>{};

  /// Lazily created SqlClient.
  SqlClient _sqlClient;

  Database();

  /// Returns a database that uses the database adapter.
  factory Database.withAdapter(DatabaseAdapter adapter) = _Database;

  /// Database adapter that implements operations for this database.
  DatabaseAdapter get adapter;

  /// Returns SQL client. The method returns a valid client even if the
  /// underlying database doesn't support SQL.
  SqlClient get sqlClient {
    return _sqlClient ??= SqlClient(this);
  }

  /// Checks that the database can be used.
  ///
  /// The method will throw a descriptive error if the database can't be used.
  Future<void> checkHealth({Duration timeout}) async {
    await adapter.performCheckConnection(timeout: timeout);
  }

  /// Returns a collection with the name.
  ///
  /// An example:
  ///
  ///     database.collection('movies').document('Lion King');
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
  ///
  /// An example:
  ///
  ///     final batch = database.collection('example').newWriteBatch();
  ///     batch.upsert(document0, data0);
  ///     batch.upsert(document1, data1);
  ///     await batch.close();
  WriteBatch newWriteBatch() {
    return WriteBatch.simple();
  }

  /// Runs a transaction.
  ///
  /// Parameter [reach] defines reach of commit. Value null means that the
  /// adapter can choose any reach.
  ///
  /// Parameter [timeout] defines timeout for the transaction. Null value means
  /// that the database adapter should decide itself. Database adapters
  /// should cancel the transaction if the timeout is reached before the
  /// transaction has been committed. Timer starts from [runInTransaction]
  /// invocation. However, database adapters are free to ignore the parameter.
  ///
  /// Parameter [callback] defines the function that performs changes. It may be
  /// invoked any number of times during the transaction. The function receives
  /// a [Transaction] that enables transactional reading and writing.
  ///
  /// Database adapter will throw [DatabaseException.transactionUnsupported] if
  /// it doesn't support transactions.
  ///
  /// Transferring money between two bank accounts would look something like:
  ///
  ///     Future<void> transferMoney(String from, String to, double amount) async {
  ///       final fromDocument = database.collection('bank_account').document(from);
  ///       final toDocument = database.collection('bank_account').document(to);
  ///       await database.runInTransaction(
  ///         reach: Reach.global,
  ///         timeout: Duration(seconds:3),
  ///         callback: (transaction) async {
  ///           // Read documents
  ///           final fromSnapshot = await transaction.get(fromDocument);
  ///           final toSnapshot = await transaction.get(toDocument);
  ///
  ///           // Patch documents
  ///           await transaction.patch(fromDocument, {
  ///             'amount': fromSnapshot.data['amount'] - amount,
  ///           });
  ///           await transaction.patch(toDocument, {
  ///             'amount': toSnapshot.data['amount'] + amount,
  ///           });
  ///         },
  ///       );
  ///     }
  /// ```
  Future<void> runInTransaction({
    @required Reach reach,
    @required Duration timeout,
    @required Future<void> Function(Transaction transaction) callback,
  }) async {
    await adapter.performDocumentTransaction(DocumentTransactionRequest(
      reach: reach,
      callback: callback,
      timeout: timeout,
    ));
  }

  @override
  String toString() => 'Database(...)';
}

class _Database extends Database {
  @override
  final DatabaseAdapter adapter;

  _Database(this.adapter);
}
