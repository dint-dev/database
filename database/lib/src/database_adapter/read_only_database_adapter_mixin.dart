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

/// Mixin for read-only database adapters.
mixin ReadOnlyDatabaseAdapterMixin implements DatabaseAdapter {
  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) {
    return Future<Transaction>.error(
      DatabaseException.databaseReadOnly(),
    );
  }

  @override
  Future<void> performDocumentDeleteBySearch(
      DocumentDeleteBySearchRequest request) {
    return Future<Transaction>.error(
      DatabaseException.databaseReadOnly(),
    );
  }

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) {
    return Future<Transaction>.error(
      DatabaseException.databaseReadOnly(),
    );
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) {
    return Future<Transaction>.error(
      DatabaseException.databaseReadOnly(),
    );
  }

  @override
  Future<void> performDocumentUpdateBySearch(
      DocumentUpdateBySearchRequest request) {
    return Future<Transaction>.error(
      DatabaseException.databaseReadOnly(),
    );
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) {
    return Future<Transaction>.error(
      DatabaseException.databaseReadOnly(),
    );
  }
}
