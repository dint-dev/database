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

/// A helper class used by [SqlClient] for building statements/queries.
///
/// An example:
/// ```
/// final queryHelper = sqlClient.table('Product').where('price < ?', [10]).select();
/// ```
class SqlClientTableQueryHelper {
  final SqlClientBase _sqlClient;
  final SqlStatement _sqlStatement;

  SqlClientTableQueryHelper._(this._sqlClient, this._sqlStatement);

  Future<SqlIterator> getIterator() async {
    final response = await _sqlClient.rawQuery(_sqlStatement);
    return response;
  }

  /// Returns results as a list of maps.
  Future<List<Map<String, Object>>> toMaps() async {
    final response = await _sqlClient.rawQuery(_sqlStatement);
    return response.toMaps();
  }

  /// Returns results as a stream of maps.
  Stream<Map<String, Object>> toMapsStream() async* {
    final response = await _sqlClient.rawQuery(_sqlStatement);
    yield* (response.readMapStream());
  }

  /// Returns results as a list of rows.
  Future<List<List<Object>>> toRows() async {
    final response = await _sqlClient.rawQuery(_sqlStatement);
    return response.toRows();
  }

  /// Returns results as a stream of rows.
  Stream<List<Object>> toRowsStream() async* {
    final response = await _sqlClient.rawQuery(_sqlStatement);
    yield* (response.readRowStream());
  }
}
