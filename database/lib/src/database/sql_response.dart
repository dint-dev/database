import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:database/database.dart';

class SqlResponse {
  final int affectedRows;
  final List<ColumnDescription> columnDescriptions;
  final List<List> rows;

  SqlResponse.fromAffectedRows(
    this.affectedRows,
  )   : columnDescriptions = const <ColumnDescription>[],
        rows = const <List>[];

  SqlResponse.fromLists({
    @required this.columnDescriptions,
    @required this.rows,
    this.affectedRows,
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
