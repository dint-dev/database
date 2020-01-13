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
class Date {
  final int year;
  final int month;
  final int day;

  const Date(this.year, this.month, this.day)
      : assert(year != null),
        assert(month != null),
        assert(day != null);

  /// Constructs using year/month/day in a `DateTime`.
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

  /// Returns current date.
  static Date now({bool isUtc = false}) {
    var now = DateTime.now();
    if (isUtc) {
      now = now.toUtc();
    }
    return Date.fromDateTime(now);
  }

  /// Parses a string with format '2020-12-31'.
  static Date parse(String s) {
    final i = s.indexOf('-');
    final j = s.indexOf('-', i + 1);
    final year = int.parse(s.substring(0, i));
    final month = int.parse(s.substring(i + 1, j));
    final day = int.parse(s.substring(j + 1));
    return Date(year, month, day);
  }
}
