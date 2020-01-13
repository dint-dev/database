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

import 'package:database/database.dart';
import 'package:test/test.dart';

void main() {
  group('Date', () {
    test('fromDateTime', () {
      expect(
        Date.fromDateTime(DateTime(2020, 12, 31)),
        Date(2020, 12, 31),
      );
    });

    test('now', () {
      final now = DateTime.now();
      final dateNow = Date.now();
      final now2 = DateTime.now();
      expect(dateNow.day, anyOf(now.day, now2.day));
    });

    test('parse', () {
      expect(
        Date.parse('2020-12-31'),
        Date(2020, 12, 31),
      );
    });

    test('toDateTime', () {
      expect(Date(2020, 1, 1).toDateTime(), DateTime(2020, 1, 1));
      expect(Date(2020, 12, 31).toDateTime(), DateTime(2020, 12, 31));
    });

    test('toString', () {
      expect(Date(2020, 1, 1).toString(), '2020-01-01');
      expect(Date(2020, 12, 31).toString(), '2020-12-31');
    });
  });
}
