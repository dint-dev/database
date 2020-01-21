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

part of database.sql;

/// Result of making an SQL statements with [SqlClient].
class SqlStatementResult {
  /// How many rows were affected.
  final int affectedRows;

  SqlStatementResult({this.affectedRows});

  @override
  int get hashCode => affectedRows.hashCode;

  @override
  bool operator ==(other) =>
      other is SqlStatementResult && affectedRows == other.affectedRows;
}
