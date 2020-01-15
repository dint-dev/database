// Copyright 2019 terrier989@gmail.com.
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
import 'package:database/database_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('DocumentScoring:', () {
    double f(Filter filter, Object value) {
      final scoringState = const DocumentScoring().newState(filter);
      final document =
          MemoryDatabase().collection('collectionId').document('documentId');
      final snapshot = Snapshot(
        document: document,
        data: <String, Object>{
          'x': value,
        },
      );
      return scoringState.evaluateSnapshot(snapshot);
    }

    test('RangeFilter: min', () {
      final filter = MapFilter({
        'x': RangeFilter(min: 3.14),
      });
      expect(
        f(filter, 3.0),
        0.0,
      );
      expect(
        f(filter, 3.14),
        1.0,
      );
      expect(
        f(filter, 4.0),
        1.0,
      );
    });

    test('RangeFilter: exclusive min', () {
      final filter = MapFilter({
        'x': RangeFilter(min: 3.14, isExclusiveMin: true),
      });
      expect(
        f(filter, 3.0),
        0.0,
      );
      expect(
        f(filter, 3.14),
        0.0,
      );
      expect(
        f(filter, 4.0),
        1.0,
      );
    });

    test('RangeFilter: max', () {
      final filter = MapFilter({
        'x': RangeFilter(max: 3.14),
      });
      expect(
        f(filter, 3.0),
        1.0,
      );
      expect(
        f(filter, 3.14),
        1.0,
      );
      expect(
        f(filter, 4.0),
        0.0,
      );
    });

    test('RangeFilter: exclusive max', () {
      final filter = MapFilter({
        'x': RangeFilter(max: 3.14, isExclusiveMax: true),
      });
      expect(
        f(filter, 3.0),
        1.0,
      );
      expect(
        f(filter, 3.14),
        0.0,
      );
      expect(
        f(filter, 4.0),
        0.0,
      );
    });

    test('RangeFilter: min, max', () {
      final filter = MapFilter({
        'x': RangeFilter(min: 3.14, max: 3.14),
      });
      expect(
        f(filter, 3.0),
        0.0,
      );
      expect(
        f(filter, 3.14),
        1.0,
      );
      expect(
        f(filter, 4.0),
        0.0,
      );
    });

    test('RangeFilter: exclusive min, exclusive max', () {
      final filter = MapFilter({
        'x': RangeFilter(
          min: 3.0,
          max: 4.0,
          isExclusiveMin: true,
          isExclusiveMax: true,
        ),
      });
      expect(
        f(filter, 3.0),
        0.0,
      );
      expect(
        f(filter, 3.14),
        1.0,
      );
      expect(
        f(filter, 4.0),
        0.0,
      );
    });

    test('ValueFilter', () {
      final filter = MapFilter({
        'x': ValueFilter(['value'])
      });
      expect(
        f(filter, ['value']),
        1.0,
      );
      expect(
        f(filter, ['not the value']),
        0.0,
      );
    });
  });
}
