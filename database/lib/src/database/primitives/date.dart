// Copyright 2019 'dint' project authors.
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

/// A date in the Gregorian calendar. It doesn't have a timezone.
///
/// ```
/// final date = Date(2020, 12, 31);
/// ```
class Date implements Comparable<Date> {
  /// Year.
  final int year;

  /// Month. January is 1.
  final int month;

  /// Day. The first day of month is 1.
  final int day;

  /// Constructs a date from year, month, and day.
  ///
  /// ```
  /// final date = Date(2020, 12, 31);
  /// ```
  const Date(this.year, this.month, this.day)
      : assert(year != null),
        assert(month != null),
        assert(day != null);

  /// Constructs a date from [DateTime].
  ///
  /// ```
  /// final date = Date.fromDateTime(DateTime.now());
  /// ```
  factory Date.fromDateTime(DateTime dateTime) {
    return Date(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  int get hashCode =>
      year.hashCode ^ month.hashCode ^ day.hashCode ^ (day.hashCode << 4);

  @override
  bool operator ==(other) =>
      other is Date &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int compareTo(Date other) {
    {
      final r = year.compareTo(other.year);
      if (r != 0) {
        return r;
      }
    }
    {
      final r = month.compareTo(other.month);
      if (r != 0) {
        return r;
      }
    }
    return day.compareTo(other.day);
  }

  /// Returns `DateTime(year, month, day)`.
  DateTime toDateTime({bool isUtc = false}) {
    if (isUtc) {
      return DateTime.utc(year, month, day);
    }
    return DateTime(year, month, day);
  }

  @override
  String toString() {
    final year = this.year.toString();
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Returns the current date.
  static Date now({bool isUtc = false}) {
    var now = DateTime.now();
    if (isUtc) {
      now = now.toUtc();
    }
    return Date.fromDateTime(now);
  }

  /// Parses a string with format '2020-12-31'. Throws [FormatException] if the
  /// parsing fails.
  static Date parse(String s) {
    final result = tryParse(s);
    if (result == null) {
      throw FormatException(
        'Date does not match the format "2020-12-31": "$s"',
      );
    }
    return result;
  }

  /// Parses a string with format '2020-12-31'. Returns null if parsing fails.
  static Date tryParse(String s) {
    final i = s.indexOf('-');
    if (i < 0) {
      return null;
    }
    final j = s.indexOf('-', i + 1);
    if (j < 0) {
      return null;
    }
    final year = int.tryParse(s.substring(0, i));
    if (year == null) {
      return null;
    }
    final month = int.tryParse(s.substring(i + 1, j));
    if (month == null || month < 1 || month > 12) {
      return null;
    }
    final day = int.tryParse(s.substring(j + 1));
    if (day == null || day < 1 || day > 31) {
      return null;
    }
    return Date(year, month, day);
  }
}
