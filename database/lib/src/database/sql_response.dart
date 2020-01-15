import 'package:collection/collection.dart';

class ColumnDescription implements Comparable<ColumnDescription> {
  final String tableName;
  final String columnName;

  ColumnDescription({this.tableName, this.columnName});

  @override
  int get hashCode => tableName.hashCode ^ columnName.hashCode;

  @override
  bool operator ==(other) =>
      other is ColumnDescription &&
      tableName == other.tableName &&
      columnName == other.columnName;

  @override
  int compareTo(ColumnDescription other) {
    {
      final r = tableName.compareTo(other.tableName);
      if (r != 0) {
        return r;
      }
    }
    return columnName.compareTo(other.columnName);
  }

  @override
  String toString() {
    if (tableName == null) {
      return columnName;
    }
    return '$tableName.$columnName';
  }
}

class SqlResponse {
  final int affectedRows;
  final List<ColumnDescription> columnDescriptions;
  final List<List> rows;

  SqlResponse.fromLists({
    this.affectedRows,
    this.columnDescriptions,
    this.rows = const <List>[],
  });

  factory SqlResponse.fromMaps(
    Iterable<Map<String, Object>> maps, {
    List<ColumnDescription> columnDescriptions,
  }) {
    if (columnDescriptions == null) {
      final columnDescriptionsSet = <ColumnDescription>{};
      for (var map in maps) {
        for (var key in map.keys) {
          columnDescriptionsSet.add(ColumnDescription(columnName: key));
        }
      }
      columnDescriptions = columnDescriptionsSet.toList(growable: false);
      columnDescriptions.sort();
    }
    final rows = maps.map((map) {
      return columnDescriptions.map((columnName) {
        return map[columnName];
      }).toList(growable: false);
    }).toList(growable: false);
    return SqlResponse.fromLists(
      columnDescriptions: columnDescriptions,
      rows: rows,
    );
  }

  @override
  int get hashCode =>
      affectedRows.hashCode ^
      const ListEquality().hash(columnDescriptions) ^
      const DeepCollectionEquality().hash(rows);

  @override
  bool operator ==(other) =>
      other is SqlResponse &&
      affectedRows == other.affectedRows &&
      const ListEquality()
          .equals(columnDescriptions, other.columnDescriptions) &&
      const DeepCollectionEquality().equals(rows, other.rows);
}
