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

abstract class SqlTransaction extends SqlClientBase {
  final DatabaseAdapter _databaseAdapter;
  final Future<bool> isSuccess;

  SqlTransaction(this._databaseAdapter, this.isSuccess);

  @override
  Future<SqlStatementResult> rawExecute(SqlStatement sqlSource) {
    return SqlStatementRequest(
      sqlSource,
      sqlTransaction: this,
    ).delegateTo(_databaseAdapter);
  }

  @override
  Future<SqlIterator> rawQuery(SqlStatement sqlSource) {
    return SqlQueryRequest(
      sqlSource,
      sqlTransaction: this,
    ).delegateTo(_databaseAdapter);
  }
}
