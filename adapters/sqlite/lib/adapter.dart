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
import 'package:sqflite/sqflite.dart' as sq;

class SQLite extends SqlDatabaseAdapter {
  final String host;
  final int port;
  final String user;
  final String password;
  final String path;

  Future<sq.Database> _databaseFutureCache;

  SQLite({
    @required this.host,
    @required this.port,
    @required this.user,
    @required this.password,
    @required this.path,
  });

  Future<sq.Database> get _databaseFuture {
    _databaseFutureCache ??= sq.openDatabase(path);
    return _databaseFutureCache;
  }

  @override
  Future<SqlResponse> performSql(SqlRequest request) async {
    final rawDatabase = await _databaseFuture;
    final arguments = _rawFrom(request.arguments);
    final rawResults = await rawDatabase.rawQuery(request.sql, arguments);
    return SqlResponse.fromMaps(rawResults);
  }

  Object _rawFrom(Object value) {
    if (value is Int64) {
      return value.toInt();
    }
    if (value is List) {
      return value.map(_rawFrom).toList(growable: false);
    }
    return value;
  }
}
