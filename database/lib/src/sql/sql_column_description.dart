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

/// Identifies an SQL column.
class SqlColumnDescription implements Comparable<SqlColumnDescription> {
  /// SQL table name.
  final String tableName;

  /// SQL column name.
  final String columnName;

  SqlColumnDescription({
    @required this.tableName,
    @required this.columnName,
  }) : assert(columnName != null);

  @override
  int get hashCode => tableName.hashCode ^ columnName.hashCode;

  @override
  bool operator ==(other) =>
      other is SqlColumnDescription &&
      tableName == other.tableName &&
      columnName == other.columnName;

  @override
  int compareTo(SqlColumnDescription other) {
    if (other == null) {
      return 1;
    }
    if (tableName != other.tableName) {
      if (tableName == null) {
        return -1;
      }
      if (other.tableName == null) {
        return 1;
      }
      return tableName.compareTo(other.tableName);
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

/// Identifies an SQL type such as LONG INT or VARCHAR(160).
class SqlType {
  final String typeName;
  final int length;

  const SqlType(this.typeName, {this.length});

  /// Constructs a VARCHAR type.
  const SqlType.varChar(int length)
      : this(
          'VARCHAR',
          length: length,
        );

  @override
  int get hashCode => typeName.hashCode;

  @override
  bool operator ==(other) => other is SqlType && typeName == other.typeName;

  @override
  String toString() {
    if (length == null) {
      return typeName;
    }
    return '$typeName($length)';
  }
}
