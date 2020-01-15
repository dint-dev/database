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

import 'package:collection/collection.dart';
import 'package:database/database.dart';

class SqlRequest {
  final String sql;
  final List arguments;
  final bool isNotQuery;

  const SqlRequest(this.sql, this.arguments, {this.isNotQuery = false})
      : assert(sql != null),
        assert(arguments != null);

  @override
  int get hashCode =>
      sql.hashCode ^ const ListEquality().hash(arguments) ^ isNotQuery.hashCode;

  @override
  bool operator ==(other) =>
      other is SqlRequest &&
      sql == other.sql &&
      ListEquality().equals(arguments, other.arguments) &&
      isNotQuery == other.isNotQuery;

  Future<SqlResponse> delegateTo(Database database) {
    // ignore: invalid_use_of_protected_member
    return database.adapter.performSql(this);
  }
}
