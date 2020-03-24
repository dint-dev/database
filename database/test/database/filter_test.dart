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

import 'package:database/database.dart';
import 'package:database/filter.dart';
import 'package:test/test.dart';

void main() {
  group('AndFilter', () {
    test('"hashCode" / "=="', () {
      final filter = AndFilter([KeywordFilter('a'), KeywordFilter('b')]);
      final clone = AndFilter([KeywordFilter('a'), KeywordFilter('b')]);
      // Shorter
      final other0 = AndFilter([KeywordFilter('a')]);
      // Different element
      final other1 = AndFilter([KeywordFilter('a'), KeywordFilter('OTHER')]);
      // Longer
      final other2 = AndFilter(
          [KeywordFilter('a'), KeywordFilter('b'), KeywordFilter('OTHER')]);
      expect(filter, clone);
      expect(filter, isNot(other0));
      expect(filter, isNot(other1));
      expect(filter, isNot(other2));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other0.hashCode));
      expect(filter.hashCode, isNot(other1.hashCode));
      expect(filter.hashCode, isNot(other2.hashCode));
    });

    test('simplify', () {
      expect(
        AndFilter([]).simplify(),
        isNull,
      );
      expect(
        AndFilter([
          KeywordFilter('a'),
        ]).simplify(),
        KeywordFilter('a'),
      );
      expect(
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
      expect(
        AndFilter([
          AndFilter([KeywordFilter('a')]),
          AndFilter([KeywordFilter('b')]),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
      expect(
        AndFilter([
          AndFilter([KeywordFilter('a'), KeywordFilter('b')]),
          AndFilter([KeywordFilter('c'), KeywordFilter('d')]),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
          KeywordFilter('c'),
          KeywordFilter('d'),
        ]),
      );
      expect(
        AndFilter([
          OrFilter([KeywordFilter('a')]),
          OrFilter([KeywordFilter('b')]),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
      expect(
        AndFilter([
          OrFilter([KeywordFilter('a'), KeywordFilter('b')]),
          OrFilter([KeywordFilter('c'), KeywordFilter('d')]),
        ]).simplify(),
        AndFilter([
          OrFilter([KeywordFilter('a'), KeywordFilter('b')]),
          OrFilter([KeywordFilter('c'), KeywordFilter('d')]),
        ]),
      );
    });
  });

  group('GeoPointFilter', () {
    test('"hashCode" / "=="', () {
      final filter = GeoPointFilter(
        near: GeoPoint.zero,
        maxDistanceInMeters: 3.0,
      );
      final clone = GeoPointFilter(
        near: GeoPoint.zero,
        maxDistanceInMeters: 3.0,
      );
      final other0 = GeoPointFilter(
        near: GeoPoint.zero,
        maxDistanceInMeters: 99.0,
      );
      final other1 = GeoPointFilter(
        near: GeoPoint(99.0, 99.0),
        maxDistanceInMeters: 3.0,
      );
      expect(filter, clone);
      expect(filter, isNot(other0));
      expect(filter, isNot(other1));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other0.hashCode));
      expect(filter.hashCode, isNot(other1.hashCode));
    });
  });

  group('KeywordFilter', () {
    test('"hashCode" / "=="', () {
      final filter = KeywordFilter('a');
      final clone = KeywordFilter('a');
      final other = KeywordFilter('b');
      expect(filter, clone);
      expect(filter, isNot(other));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other.hashCode));
    });
  });

  group('ListFilter', () {
    test('"hashCode" / "=="', () {
      final filter = ListFilter(items: KeywordFilter('a'));
      final clone = ListFilter(items: KeywordFilter('a'));
      final other = ListFilter(items: KeywordFilter('b'));
      expect(filter, clone);
      expect(filter, isNot(other));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other.hashCode));
    });
  });

  group('NotFilter', () {
    test('"hashCode" / "=="', () {
      final filter = NotFilter(KeywordFilter('a'));
      final clone = NotFilter(KeywordFilter('a'));
      final other = NotFilter(KeywordFilter('b'));
      expect(filter, clone);
      expect(filter, isNot(other));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other.hashCode));
    });
  });

  group('OrFilter', () {
    test('"hashCode" / "=="', () {
      final filter = OrFilter([KeywordFilter('a'), KeywordFilter('b')]);
      final clone = OrFilter([KeywordFilter('a'), KeywordFilter('b')]);
      // Shorter
      final other0 = OrFilter([KeywordFilter('a')]);
      // Different element
      final other1 = OrFilter([KeywordFilter('a'), KeywordFilter('OTHER')]);
      // Longer
      final other2 = OrFilter(
          [KeywordFilter('a'), KeywordFilter('b'), KeywordFilter('OTHER')]);
      expect(filter, clone);
      expect(filter, isNot(other0));
      expect(filter, isNot(other1));
      expect(filter, isNot(other2));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other0.hashCode));
      expect(filter.hashCode, isNot(other1.hashCode));
      expect(filter.hashCode, isNot(other2.hashCode));
    });

    test('simplify', () {
      expect(
        AndFilter([]).simplify(),
        isNull,
      );
      expect(
        AndFilter([
          KeywordFilter('a'),
        ]).simplify(),
        KeywordFilter('a'),
      );
      expect(
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
      expect(
        AndFilter([
          AndFilter([KeywordFilter('a')]),
          AndFilter([KeywordFilter('b')]),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
      expect(
        AndFilter([
          AndFilter([KeywordFilter('a'), KeywordFilter('b')]),
          AndFilter([KeywordFilter('c'), KeywordFilter('d')]),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
          KeywordFilter('c'),
          KeywordFilter('d'),
        ]),
      );
      expect(
        AndFilter([
          OrFilter([KeywordFilter('a')]),
          OrFilter([KeywordFilter('b')]),
        ]).simplify(),
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
      expect(
        OrFilter([
          AndFilter([KeywordFilter('a'), KeywordFilter('b')]),
          AndFilter([KeywordFilter('c'), KeywordFilter('d')]),
        ]).simplify(),
        OrFilter([
          AndFilter([KeywordFilter('a'), KeywordFilter('b')]),
          AndFilter([KeywordFilter('c'), KeywordFilter('d')]),
        ]),
      );
    });
  });

  group('PropertyValueFilter', () {
    test('"hashCode" / "=="', () {
      final filter = MapFilter({'k': KeywordFilter('v')});
      final clone = MapFilter({'k': KeywordFilter('v')});
      final other0 = MapFilter({'other': KeywordFilter('v')});
      final other1 = MapFilter({'k': KeywordFilter('other')});
      expect(filter, clone);
      expect(filter, isNot(other0));
      expect(filter, isNot(other1));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other0.hashCode));
      expect(filter.hashCode, isNot(other1.hashCode));
    });
  });

  group('PropertyRangeFilter', () {
    test('"hashCode" / "=="', () {
      final filter = RangeFilter(min: 2, max: 3);
      final clone = RangeFilter(min: 2, max: 3);
      // Different min
      final other0 = RangeFilter(max: 3);
      // Different max
      final other1 = RangeFilter(min: 2);
      // Different isExclusiveMin
      final other2 = RangeFilter(min: 2, max: 3, isExclusiveMin: true);
      // Different isExclusiveMax
      final other3 = RangeFilter(min: 2, max: 3, isExclusiveMax: true);
      expect(filter, clone);
      expect(filter, isNot(other0));
      expect(filter, isNot(other1));
      expect(filter, isNot(other2));
      expect(filter, isNot(other3));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other0.hashCode));
      expect(filter.hashCode, isNot(other1.hashCode));
      expect(filter.hashCode, isNot(other2.hashCode));
      expect(filter.hashCode, isNot(other3.hashCode));
    });
  });

  group('RegExpFilter', () {
    test('"hashCode" / "=="', () {
      final filter = RegExpFilter(RegExp('a'));
      final clone = RegExpFilter(RegExp('a'));
      final other = RegExpFilter(RegExp('b'));
      expect(filter, clone);
      expect(filter, isNot(other));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other.hashCode));
    });
  });

  group('ValueFilter', () {
    test('"hashCode" / "=="', () {
      final filter = ValueFilter(['a']);
      final clone = ValueFilter(['a']);
      final other = ValueFilter(['b']);
      expect(filter, clone);
      expect(filter, isNot(other));
      expect(filter.hashCode, clone.hashCode);
      expect(filter.hashCode, isNot(other.hashCode));
    });
  });
}
