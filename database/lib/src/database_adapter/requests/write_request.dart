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
  Document document;
  WriteType type;
  Map<String, Object> data;
  Schema schema;

  WriteRequest({
    @required this.document,
    @required this.type,
    this.data,
  });

  Future<void> delegateTo(Database database) {
    // ignore: invalid_use_of_protected_member
    return (database as DatabaseAdapter).performWrite(this);
  }
}

enum WriteType {
  delete,
  deleteIfExists,
  insert,
  update,
  upsert,
}
