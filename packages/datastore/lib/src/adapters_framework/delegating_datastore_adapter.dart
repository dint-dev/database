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

import 'package:datastore/adapters_framework.dart';
import 'package:datastore/datastore.dart';

class DelegatingDatastoreAdapter extends Datastore implements DatastoreAdapter {
  final DatastoreAdapter _datastore;

  const DelegatingDatastoreAdapter(this._datastore)
      : assert(_datastore != null);

  @override
  Future<Transaction> beginTransaction({Duration timeout}) {
    return _datastore.beginTransaction(timeout: timeout);
  }

  @override
  Future<void> checkHealth({Duration timeout}) {
    return _datastore.checkHealth(timeout: timeout);
  }

  @override
  Stream<DatastoreExtensionResponse> performExtension(
      DatastoreExtensionRequest request) {
    return request.delegateTo(_datastore);
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) {
    return request.delegateTo(_datastore);
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) {
    return request.delegateTo(_datastore);
  }

  @override
  Future<void> performWrite(WriteRequest request) {
    return request.delegateTo(_datastore);
  }
}
