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
class SqlClientTableSelectionHelper {
  final SqlClient _client;
  final String _tableName;
  final List<SqlStatement> _where;
  final List<_OrderBy> _orderBy;
  final int _offset;
  final int _limit;

  SqlClientTableSelectionHelper._(
    this._client,
    this._tableName, {
    @required List<SqlStatement> where,
    @required List<_OrderBy> orderBy,
    @required int offset,
    @required int limit,
  })  : _where = where,
        _orderBy = orderBy,
        _offset = offset,
        _limit = limit;

  SqlClientTableSelectionHelper ascending(String name) {
    return SqlClientTableSelectionHelper._(
      _client,
      _tableName,
      where: _where,
      orderBy: [
        ...(_orderBy ?? const <_OrderBy>[]),
        _OrderBy(name, isDescending: false)
      ],
      offset: _offset,
      limit: _limit,
    );
  }

  /// Deletes rows in the table.
  ///
  /// ```
  /// client.table('person').selectWhere({'id': 1});
  /// ```
  Future<SqlStatementResult> deleteAll() {
    if ((_orderBy?.isNotEmpty ?? false) || _offset != null || _limit != null) {
      throw StateError(
        'DELETE statement doesnt support ORDER BY, OFFSET, or LIMIT ',
      );
    }
    final b = SqlSourceBuilder();
    b.write('DELETE FROM ');
    b.identifier(_tableName);

    final where = _where ?? const <SqlStatement>[];
    if (where.isNotEmpty) {
      b.write(' WHERE ');
      var comma = false;
      for (var sqlSource in where) {
        if (comma) {
          b.write(', ');
        }
        comma = true;
        b.write(sqlSource.value);
        b.arguments.addAll(sqlSource.arguments);
      }
    }

    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  SqlClientTableSelectionHelper descending(String name) {
    return SqlClientTableSelectionHelper._(
      _client,
      _tableName,
      where: _where,
      orderBy: [
        ...(_orderBy ?? const <_OrderBy>[]),
        _OrderBy(name, isDescending: true)
      ],
      offset: _offset,
      limit: _limit,
    );
  }

  /// Sets maximum number of returned rows.
  SqlClientTableSelectionHelper limit(int value) {
    return SqlClientTableSelectionHelper._(
      _client,
      _tableName,
      where: _where,
      orderBy: _orderBy,
      offset: _offset,
      limit: (_limit == null || value < _limit) ? value : _limit,
    );
  }

  /// Sets offset for the first returned row.
  SqlClientTableSelectionHelper offset(int value) {
    return SqlClientTableSelectionHelper._(
      _client,
      _tableName,
      where: _where,
      orderBy: _orderBy,
      offset: (_offset ?? 0) + value,
      limit: _limit,
    );
  }

  /// Selects rows in the table.
  ///
  /// ```
  /// final persons = await client
  ///   .table('person')
  ///   .whereColumn('id', 2)
  ///   .select(columns:['name'])
  ///   .toMaps();
  /// ```
  ///
  /// ```
  /// final products = await client
  ///   .table('person')
  ///   .whereColumn('id', 2)
  ///   .select(columns:['name'])
  ///   .toMaps();
  /// ```
  SqlClientTableQueryHelper select({
    List<String> columnNames,
    List<SqlColumnEntry> columnEntries,
  }) {
    final b = SqlSourceBuilder();
    b.write('SELECT ');

    //
    // Columns and expressions
    //
    {
      // Column names
      var comma = false;
      if (columnNames == null) {
        b.write('*');
        comma = true;
      } else {
        for (var columnName in columnNames) {
          if (comma) {
            b.write(', ');
          }
          comma = true;
          b.identifier(columnName);
        }
      }

      // Expressions
      if (columnEntries != null) {
        for (var columnEntry in columnEntries) {
          if (comma) {
            b.write(', ');
          }
          comma = true;
          if (columnEntry.expression != null) {
            b.write(columnEntry.expression);
            b.write(' ');
          }
          b.identifier(columnEntry.name);
        }
      }
    }

    b.write(' FROM ');
    b.identifier(_tableName);

    //
    // Where
    //
    final where = _where ?? const <SqlStatement>[];
    if (where.isNotEmpty) {
      b.write(' WHERE ');
      var comma = false;
      for (var condition in where) {
        if (comma) {
          b.write(', ');
        }
        comma = true;
        b.write(condition.value);
        b.arguments.addAll(condition.arguments);
      }
    }

    //
    // Order by
    //
    final orderBy = _orderBy ?? const <_OrderBy>[];
    if (orderBy.isNotEmpty) {
      b.write(' ORDER BY ');
      var comma = false;
      for (var item in orderBy) {
        if (comma) {
          b.write(', ');
        }
        comma = true;
        b.write(item.isDescending ? 'DESC ' : 'ASC ');
        b.identifier(item.name);
      }
    }

    //
    // Offset
    //
    if (_offset != null) {
      b.write(' OFFSET ');
      b.argument(_offset);
    }

    //
    // Limit
    //
    if (_limit != null) {
      b.write(' LIMIT ');
      b.argument(_limit);
    }

    final sqlSource = b.build();
    return _client.query(sqlSource.value, sqlSource.arguments);
  }

  SqlClientTableSelectionHelper whereColumn(String name, {Object equals}) {
    final where = List<SqlStatement>.from(_where ?? const <SqlStatement>[]);
    if (equals != null) {
      final b = SqlSourceBuilder();
      b.identifier(name);
      b.write(' = ');
      b.argument(equals);
      where.add(b.build());
    }
    return SqlClientTableSelectionHelper._(
      _client,
      _tableName,
      where: where,
      orderBy: _orderBy,
      offset: _offset,
      limit: _limit,
    );
  }

  SqlClientTableSelectionHelper whereColumns(Map<String, Object> properties) {
    final where = List<SqlStatement>.from(_where ?? const <SqlStatement>[]);
    for (var columnName in properties.keys.toList()..sort()) {
      final b = SqlSourceBuilder();
      b.identifier(columnName);
      b.write(' = ');
      b.argument(properties[columnName]);
      where.add(b.build());
    }
    return SqlClientTableSelectionHelper._(
      _client,
      _tableName,
      where: where,
      orderBy: _orderBy,
      offset: _offset,
      limit: _limit,
    );
  }

  SqlClientTableSelectionHelper whereSql(String sql, [List arguments]) {
    final where = List<SqlStatement>.from(_where ?? const <SqlStatement>[]);
    where.add(SqlStatement(sql, arguments));
    return SqlClientTableSelectionHelper._(
      _client,
      _tableName,
      where: where,
      orderBy: _orderBy,
      offset: _offset,
      limit: _limit,
    );
  }
}

class SqlColumnEntry {
  final String name;
  final String table;
  final String column;
  final String expression;
  SqlColumnEntry(this.name, {this.table, this.column, this.expression});
}

enum SqlReferenceDeleteAction {
  setNull,
  restrict,
  cascade,
}

enum SqlReferenceUpdateAction {
  setNull,
  restrict,
  cascade,
}

class _OrderBy {
  final String name;
  final bool isDescending;
  _OrderBy(this.name, {@required this.isDescending});
}
