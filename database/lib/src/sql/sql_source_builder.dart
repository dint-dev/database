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

/// Builds instances of [SqlStatement].
class SqlSourceBuilder {
  // Rejects:
  //   * Identifiers that contain whitespace
  //   * Identifiers that contain percent, quote, or backspace
  static final _identifierRegExp = RegExp('^[^\x00- \x7F"%\\\\]+\$');

  final StringBuffer _sb = StringBuffer();

  final List arguments = [];

  /// Writes argument marker ('?') and adds the value to the list of arguments.
  void argument(Object value) {
    write('?');
    arguments.add(value);
  }

  /// Builds an instance of [SqlStatement].
  SqlStatement build() {
    return SqlStatement(_sb.toString(), arguments);
  }

  /// Writes identifier to the SQL statement.
  void identifier(String value) {
    // We always escape the identifier.
    //
    // If we didn't escape some identifiers, we would have to check that the
    // identifiers are not reserved words. The list of such words is very large.
    //
    // For example, the following identifiers are banned in SQL Server:
    // https://docs.microsoft.com/en-us/sql/t-sql/language-elements/reserved-keywords-transact-sql?view=sql-server-ver15
    if (_identifierRegExp.hasMatch(value)) {
      write('`');
      write(value);
      write('`');
    } else {
      throw ArgumentError.value(
        value,
        'value',
        'Unsupported SQL identifier',
      );
    }
  }

  /// Write the argument.
  void write(Object obj) {
    _sb.write(obj);
  }
}
