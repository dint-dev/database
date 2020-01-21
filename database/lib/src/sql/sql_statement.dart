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

/// SQL source and arguments.
///
/// ```
/// final statement = SqlStatement(
///   'SELECT * FROM products WHERE price < ?',
///   [8],
/// );
/// ```
class SqlStatement {
  final String value;
  final List arguments;

  SqlStatement(this.value, [List arguments])
      : assert(value != null),
        arguments = arguments ?? const [];

  @override
  int get hashCode => value.hashCode ^ const ListEquality().hash(arguments);

  @override
  bool operator ==(other) =>
      other is SqlStatement &&
      value == other.value &&
      ListEquality().equals(arguments, other.arguments);

  /// Replaces parameters in the SQL string using the function.
  String replaceParameters(String Function(int index, Object value) f) {
    final sql = value;

    // Optimize simple case
    if (!sql.contains('?')) {
      return sql;
    }

    var parameterIndex = 0;
    final sb = StringBuffer();
    var start = 0;
    while (true) {
      final i = sql.indexOf('?', start);

      // No more '?' characters?
      if (i < 0) {
        // Write the remaining string
        sb.write(sql.substring(start));
        break;
      }

      // Escape sequence?
      if (sql.startsWith('??', i)) {
        // Write the string until the second '?'
        sb.write(sql.substring(start, i + 1));

        // Continue after the second '?'
        start = i + 2;
        continue;
      }

      // Write string until '?'
      sb.write(sql.substring(start, i));

      // Evaluate replacement
      final replacement = f(parameterIndex, arguments[parameterIndex]);

      // Write replacement
      sb.write(replacement);

      // Increment variables
      parameterIndex++;
      start = i + 1;
    }
    return sb.toString();
  }

  String replaceParametersWithLiterals() {
    return replaceParameters((i, value) {
      if (value == null) {
        return 'NULL';
      }
      if (value == false) {
        return 'FALSE';
      }
      if (value == true) {
        return 'TRUE';
      }
      if (value is int) {
        return value.toString();
      }
      if (value is double) {
        if (value.isNaN) {
          return "float64 'nan'";
        }
        if (value == double.negativeInfinity) {
          return "float64 '-infinity'";
        }
        if (value == double.infinity) {
          return "float64 '+infinity'";
        }
        return value.toString();
      }
      if (value is String) {
        return value
            .replaceAll(r'\', r'\\')
            .replaceAll("'", r"\'")
            .replaceAll('\n', r'\n');
      }
      if (value is Date) {
        return "date '$value'";
      }
      if (value is DateTime) {
        var s = value.toIso8601String();
        if (s.endsWith('Z')) {
          s = s.substring(0, s.length - 1);
        }
        return "timestamp '$s'";
      }
      if (value is GeoPoint) {
        return 'Point(${value.latitude}, ${value.longitude})';
      }

      throw ArgumentError.value(value, 'value', 'Unsupported SQL value');
    });
  }

  /// Returns the SQL string.
  @override
  String toString() {
    if (arguments.isEmpty) {
      return 'SqlSource(\'$value\')';
    }
    return 'SqlSource(\'$value\', [${arguments.join(', ')}])';
  }
}
