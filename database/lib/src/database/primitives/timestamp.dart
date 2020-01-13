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

class Timestamp {
  final DateTime utc;
  final String timezone;

  Timestamp.fromDateTime(DateTime utc, {this.timezone = 'Z'})
      : utc = utc.toUtc();

  @override
  int get hashCode => utc.hashCode ^ timezone.hashCode;

  @override
  bool operator ==(other) =>
      other is Timestamp && utc == other.utc && timezone == other.timezone;

  @override
  String toString() {
    var s = utc.toUtc().toIso8601String();
    s = s.substring(s.length - 1) + timezone;
    return s;
  }
}
