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
import 'package:meta/meta.dart';

/// Returns true if the argument is [WriteType.delete] or
/// [WriteType.deleteIfExists].
bool isDeleteWriteType(WriteType type) {
  switch (type) {
    case WriteType.delete:
      return true;
    case WriteType.deleteIfExists:
      return true;
    default:
      return false;
  }
}

/// A request to perform a write in the storage.
@sealed
class WriteRequest {
  /// A collection where the data is written. Ignored [document] is non-null.
  Collection collectionWhereInserted;

  /// Document where the data is written. If null, [collectionWhereInserted]
  /// must be non=null.
  Document document;

  /// Type of the write.
  WriteType type;

  /// Written data.
  Map<String, Object> data;

  Schema schema;

  WriteRequest({
    @required this.document,
    @required this.type,
    this.data,
  });

  /// Delegates this request to another database.
  Future<void> delegateTo(Database database) {
    // ignore: invalid_use_of_protected_member
    return database.adapter.performWrite(this);
  }
}

enum WriteType {
  /// Deletes a document. If the document doesn't exist, throws an error.
  delete,

  /// Deletes a document. IF the document doesn't exist, ignores the operation.
  deleteIfExists,

  /// Insert a document.
  insert,

  /// Updates a document.
  update,

  /// Inserts or updates the document.
  upsert,
}
