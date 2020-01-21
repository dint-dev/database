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
class SqlClientTableHelper extends SqlClientTableSelectionHelper {
  SqlClientTableHelper._(SqlClient sqlClient, String tableName)
      : super._(
          sqlClient,
          tableName,
          where: null,
          orderBy: null,
          offset: null,
          limit: null,
        );

  Future<void> addColumn(String name, SqlType type, {Object defaultValue}) {
    final b = SqlSourceBuilder();
    b.write('ALTER TABLE ');
    b.identifier(_tableName);
    b.write(' ADD COLUMN ');
    b.identifier(name);
    b.write(' ');
    b.write(type.toString());
    if (defaultValue != null) {
      b.write(' DEFAULT ');
      b.argument(defaultValue);
    }
    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  Future<void> addForeignKeyConstraint({
    @required String constraintName,
    @required List<String> localColumnNames,
    @required String foreignTableName,
    @required List<String> foreignColumnNames,
    SqlReferenceDeleteAction onDelete,
    SqlReferenceUpdateAction onUpdate,
  }) {
    final b = SqlSourceBuilder();
    b.write('ALTER TABLE ');
    b.identifier(_tableName);
    b.write(' ADD CONSTRAINT ');
    b.identifier(constraintName);
    b.write(' FOREIGN KEY (');
    {
      var comma = false;
      for (var column in localColumnNames) {
        if (comma) {
          b.write(', ');
        }
        comma = true;
        b.identifier(column);
      }
    }
    b.write(') REFERENCES ');
    b.identifier(foreignTableName);
    b.write(' (');
    {
      var comma = false;
      for (var column in foreignColumnNames) {
        if (comma) {
          b.write(', ');
        }
        comma = true;
        b.identifier(column);
      }
    }
    b.write(')');

    if (onUpdate != null) {
      b.write(' ON UPDATE ');
      switch (onUpdate) {
        case SqlReferenceUpdateAction.setNull:
          b.write('SET NULL');
          break;
        case SqlReferenceUpdateAction.restrict:
          b.write('RESTRICT');
          break;
        case SqlReferenceUpdateAction.cascade:
          b.write('CASCADE');
          break;
      }
    }

    if (onDelete != null) {
      b.write(' ON DELETE ');
      switch (onDelete) {
        case SqlReferenceDeleteAction.setNull:
          b.write('SET NULL');
          break;
        case SqlReferenceDeleteAction.restrict:
          b.write('RESTRICT');
          break;
        case SqlReferenceDeleteAction.cascade:
          b.write('CASCADE');
          break;
      }
    }
    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  Future<void> createIndex(String name, List<String> columnNames) {
    final b = SqlSourceBuilder();
    b.write('CREATE INDEX ');
    b.identifier(name);
    b.write(' ON ');
    b.identifier(_tableName);
    var comma = false;
    b.write(' (');
    for (var columnName in columnNames) {
      if (comma) {
        b.write(', ');
      }
      comma = true;
      b.identifier(columnName);
    }
    b.write(')');
    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  Future<void> dropColumn(String name) {
    final b = SqlSourceBuilder();
    b.write('ALTER TABLE ');
    b.identifier(_tableName);
    b.write(' DROP COLUMN ');
    b.identifier(name);
    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  Future<void> dropConstraint(String name) {
    final b = SqlSourceBuilder();
    b.write('ALTER TABLE ');
    b.identifier(_tableName);
    b.write(' DROP CONSTRAINT ');
    b.identifier(name);
    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  Future<void> dropIndex(String name) {
    final b = SqlSourceBuilder();
    b.write('DROP INDEX ');
    b.identifier(name);
    b.write(' ON ');
    b.identifier(_tableName);
    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  /// Inserts a row in the table.
  ///
  /// ```
  /// client.table('person').insert({'name': 'Alan Turing'});
  /// ```
  Future<SqlStatementResult> insert(Map<String, Object> map) {
    return insertAll([map]);
  }

  /// Inserts rows in the table.
  ///
  /// ```
  /// client.table('person').insertAll([row0, row1]);
  /// ```
  Future<SqlStatementResult> insertAll(
    Iterable<Map<String, Object>> maps,
  ) {
    /// Construct list of values
    final mapsList = maps.toList();
    if (mapsList.isEmpty) {
      // Nothing is inserted
      return Future<SqlStatementResult>.value(
        SqlStatementResult(affectedRows: 0),
      );
    }

    /// Determine what columns we will insert
    final columnNamesSet = <String>{};
    for (var item in mapsList) {
      columnNamesSet.addAll(item.keys);
    }
    final columnNamesList = columnNamesSet.toList()..sort();

    final b = SqlSourceBuilder();
    b.write('INSERT INTO ');
    b.identifier(_tableName);
    b.write(' (');
    {
      var comma = false;
      for (var columnName in columnNamesList) {
        if (comma) {
          b.write(', ');
        }
        comma = true;
        b.identifier(columnName);
      }
    }
    b.write(') VALUES ');
    {
      var rowComma = false;
      for (var map in mapsList) {
        if (rowComma) {
          b.write(', ');
        }
        rowComma = true;
        b.write('(');
        var valueComma = false;
        for (var columnName in columnNamesList) {
          if (valueComma) {
            b.write(', ');
          }
          valueComma = true;
          b.argument(map[columnName]);
        }
        b.write(')');
      }
    }

    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }

  /// Renames a column.
  Future<void> renameColumn({
    @required String oldName,
    @required String newName,
  }) {
    final b = SqlSourceBuilder();
    b.write('ALTER TABLE ');
    b.identifier(_tableName);
    b.write(' RENAME COLUMN ');
    b.identifier(oldName);
    b.write(' ');
    b.identifier(newName);
    final sqlSource = b.build();
    return _client.execute(sqlSource.value, sqlSource.arguments);
  }
}
