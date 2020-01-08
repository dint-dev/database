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

import 'package:datastore/datastore.dart';
import 'package:meta/meta.dart';

/// A datastore contains any number of collections ([Collection]). A collection
/// contains any number of documents ([Document]).
abstract class Datastore {
  /// Value returned by [defaultInstance].
  static Datastore _defaultInstance;

  /// Whether value of static field [_defaultInstance] is frozen.
  static bool _defaultInstanceFrozen = false;

  /// Returns global default instance of [Datastore].
  static Datastore get defaultInstance => _defaultInstance;

  /// Sets the value returned by [Datastore.defaultInstance].
  ///
  /// Throws [StateError] if the value has already been frozen by
  /// [freezeDefaultInstance].
  static set defaultInstance(Datastore datastore) {
    if (_defaultInstanceFrozen) {
      throw StateError('Datastore.defaultInstance is already frozen');
    }
    _defaultInstance = datastore;
  }

  const Datastore();

  /// Checks that the datastore can be used.
  ///
  /// The future will complete with an error if an error occurred.
  Future<void> checkHealth();

  /// Returns a collection with the name.
  Collection collection(String collectionId) {
    return Collection(this, collectionId);
  }

  /// Return a new write batch.
  WriteBatch newWriteBatch() {
    return WriteBatch.simple();
  }

  // TODO: Transaction options (consistency, etc.)
  /// Begins a transaction.
  ///
  /// Note that many datastore implementations do not support transactions.
  Future<void> runInTransaction({
    Duration timeout,
    @required Future<void> Function(Transaction transaction) callback,
  }) async {
    throw UnsupportedError('Transactions are not supported by $this');
  }

  /// Sets the value returned by [Datastore.defaultInstance] and prevents
  /// future mutations.
  ///
  /// Throws [StateError] if the value has already been frozen.
  static void freezeDefaultInstance(Datastore datastore) {
    if (_defaultInstanceFrozen) {
      throw StateError('Datastore.defaultInstance is already frozen');
    }
    _defaultInstanceFrozen = true;
    _defaultInstance = datastore;
  }
}
