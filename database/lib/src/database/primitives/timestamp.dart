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

/// A nanosecond-precision timestamp.
class Timestamp implements Comparable<Timestamp> {
  final int seconds;
  final int nanos;

  Timestamp(this.seconds, this.nanos);

  factory Timestamp.fromDateTime(DateTime dateTime) {
    dateTime = dateTime.toUtc();
    return Timestamp(
      dateTime.millisecondsSinceEpoch ~/ 1000,
      (dateTime.microsecondsSinceEpoch % 1000000) * 1000,
    );
  }

  @override
  int get hashCode => seconds.hashCode ^ nanos.hashCode;

  @override
  bool operator ==(other) =>
      other is Timestamp && seconds == other.seconds && nanos == other.nanos;

  @override
  int compareTo(Timestamp other) {
    final r = seconds.compareTo(other.seconds);
    if (r != 0) {
      return r;
    }
    return nanos.compareTo(other.nanos);
  }

  DateTime toDateTime() {
    return DateTime.fromMicrosecondsSinceEpoch(
      seconds * 1000000 + nanos ~/ 1000,
    );
  }

  @override
  String toString() {
    return toDateTime().toIso8601String();
  }
}
