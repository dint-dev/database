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

/// Iterates rows in the database.
///
/// This is the result of making an SQL query with [SqlClient].
abstract class SqlIterator {
  List _currentRow;

  bool _isClosed = false;
  SqlIterator.constructor();

  factory SqlIterator.fromFunction({
    @required List<SqlColumnDescription> columnDescriptions,
    @required Future<List<List>> Function({int length}) onNextRowBatch,
  }) = _SqlQueryResultWithFunction;

  factory SqlIterator.fromLists({
    @required List<SqlColumnDescription> columnDescriptions,
    @required List<List> rows,
  }) {
    if (rows.isEmpty) {
      rows = null;
    }
    var i = 0;
    return SqlIterator.fromFunction(
      columnDescriptions: columnDescriptions,
      onNextRowBatch: ({int length}) async {
        if (rows == null) {
          return null;
        }
        final result = rows.sublist(i);
        i += result.length;
        if (i >= rows.length) {
          // Help garbage collector
          rows = null;
        }
        return result;
      },
    );
  }

  factory SqlIterator.fromMaps(
    Iterable<Map<String, Object>> maps, {
    List<SqlColumnDescription> columnDescriptions,
  }) {
    if (columnDescriptions == null) {
      final columnDescriptionsSet = <SqlColumnDescription>{};
      for (var map in maps) {
        for (var key in map.keys) {
          columnDescriptionsSet.add(SqlColumnDescription(columnName: key));
        }
      }
      columnDescriptions = columnDescriptionsSet.toList(growable: false);
      columnDescriptions.sort();
    }
    final rows = maps.map((map) {
      return columnDescriptions.map((columnDescription) {
        return map[columnDescription.columnName] ??
            map['${columnDescription.tableName}.${columnDescription.columnName}'];
      }).toList(growable: false);
    }).toList(growable: false);
    return SqlIterator.fromLists(
      columnDescriptions: columnDescriptions,
      rows: rows,
    );
  }

  /// Descriptions of columns. Must be non-null and the length must be equal to
  /// the length of every rows.
  List<SqlColumnDescription> get columnDescriptions;

  /// Reads the next row as a map. If there are no more rows, returns null.
  Future<Map<String, Object>> get currentMap async {
    final result = <String, Object>{};
    final row = currentRow;
    for (var i = 0; i < row.length; i++) {
      result[columnDescriptions[i]?.columnName ?? '$i'] = row[i];
    }
    return Map<String, Object>.unmodifiable(result);
  }

  List get currentRow => _currentRow;

  bool get isClosed => _isClosed;

  Future<void> close() async {
    _isClosed = true;
  }

  /// Returns current value in the column with the specified index.
  ///
  /// Throws [ArgumentError] if the index is invalid.
  Object index(int index) {
    if (_currentRow == null) {
      throw StateError('Current row is null. Call next() to get the next row.');
    }
    final length = columnDescriptions.length;
    if (index < 0 || index >= length) {
      throw ArgumentError.value(index, 'The result set has $length columns');
    }
    return currentRow[index];
  }

  /// Reads the next row as list. If there are no more rows, returns null.
  Future<bool> next() async {
    _currentRow = null;
    final batch = await readBatchOfRows(length: 1);
    if (batch.isEmpty) {
      return false;
    }
    _currentRow = batch.single;
    return true;
  }

  /// Returns current value in the column with the specified name.
  ///
  /// Throws [ArgumentError] if the column doesn't exist.
  Object property(String name, {String tableName}) {
    if (_currentRow == null) {
      throw StateError('Current row is null. Call next() to get the next row.');
    }
    final columnDescriptions = this.columnDescriptions;
    for (var i = 0; i < columnDescriptions.length; i++) {
      final columnDescription = columnDescriptions[i];
      if (columnDescription.columnName == name) {
        if (tableName == null ||
            tableName == columnDescription.tableName ||
            columnDescription.tableName == null) {
          return index(i);
        }
      }
    }
    final columnNames = columnDescriptions.join(', ');
    throw ArgumentError.value(name, 'name',
        'Invalid column. The result set has columns: $columnNames');
  }

  /// Reads the next batch of rows as a map. If there are no more rows, returns
  /// null. This method could have better performance than reading row-by-row.
  ///
  /// The method will always return a non-empty list.
  ///
  /// The length is optional. If non-null, it must be greater than 0. The
  /// returned list will never be longer than the specified length.
  Future<List<Map<String, Object>>> readBatchOfMaps({int length}) async {
    if (length != null && length <= 0) {
      throw ArgumentError.value(length, 'length');
    }
    final rowBatch = await readBatchOfRows(length: length);
    if (rowBatch == null) {
      return null;
    }
    return List<Map<String, Object>>.unmodifiable(rowBatch.map((row) {
      final result = <String, Object>{};
      for (var i = 0; i < row.length; i++) {
        result[columnDescriptions[i]?.columnName ?? '$i'] = row[i];
      }
      return result;
    }));
  }

  /// Reads the next batch of rows as a list. If there are no more rows, returns
  /// null. This method could have better performance than reading row-by-row.
  ///
  /// The method will always return a non-empty list.
  ///
  /// The length is optional. If non-null, it must be greater than 0. The
  /// returned list will never be longer than the specified length.
  Future<List<List>> readBatchOfRows({int length});

  /// Reads all remaining rows as a stream of maps. Each row is immutable.
  Stream<Map<String, Object>> readMapStream() async* {
    while (true) {
      final batch = await readBatchOfMaps();
      if (batch == null) {
        return;
      }
      for (var item in batch) {
        yield (item);
      }
    }
  }

  /// Reads all remaining rows as a stream of lists. Each row is immutable.
  Stream<List> readRowStream() async* {
    while (true) {
      final batch = await readBatchOfRows();
      if (batch == null) {
        return;
      }
      for (var item in batch) {
        yield (item);
      }
    }
  }

  /// Reads all remaining rows as maps. The result is immutable.
  Future<List<Map<String, Object>>> toMaps() async {
    final result = <Map<String, Object>>[];
    while (true) {
      final batch = await readBatchOfMaps();
      if (batch == null) {
        return List<Map<String, Object>>.unmodifiable(result);
      }
      result.addAll(batch);
    }
  }

  /// Reads all remaining rows as lists. The result is immutable.
  Future<List<List>> toRows() async {
    final result = <List>[];
    while (true) {
      final batch = await readBatchOfRows();
      if (batch == null) {
        return List<List>.unmodifiable(result);
      }
      result.addAll(batch);
    }
  }
}

class _SqlQueryResultWithFunction extends SqlIterator {
  @override
  final List<SqlColumnDescription> columnDescriptions;

  final Future<List<List>> Function({int length}) onNextRowBatch;

  _SqlQueryResultWithFunction({
    this.columnDescriptions,
    this.onNextRowBatch,
  }) : super.constructor();

  @override
  Future<List<List>> readBatchOfRows({int length}) async {
    if (length != null && length <= 0) {
      throw ArgumentError.value(length, 'length');
    }
    final result = await onNextRowBatch(length: length);
    if (result == null) {
      await close();
      return result;
    }
    if (length != null && result.length > length) {
      throw StateError('Function returned more rows than requested.');
    }
    return result;
  }
}
