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

import 'package:datastore/datastore.dart';
import 'package:test/test.dart';

void main() {
  group('FilterPrinter', () {
    test('AndFilter', () {
      expect(
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]).toString(),
        'a AND b',
      );
      expect(
        AndFilter([
          KeywordFilter('v0'),
          OrFilter([KeywordFilter('v1'), KeywordFilter('v2')]),
          AndFilter([KeywordFilter('v3'), KeywordFilter('v4')]),
        ]).toString(),
        'v0 AND (v1 OR v2) AND (v3 AND v4)',
      );
    });

    test('GeoPointFilter', () {
      expect(
        GeoPointFilter.withDistance(GeoPoint.zero, RangeFilter(max: 2))
            .toString(),
        '(near 0.00000,0.00000 <=2)',
      );
    });

    test('KeywordFilter', () {
      expect(KeywordFilter('a').toString(), 'a');
      expect(KeywordFilter('a b').toString(), '"a b"');
      expect(KeywordFilter('a"b').toString(), r'"a\"b"');
      expect(KeywordFilter('a\tb').toString(), '"a\tb"');
      expect(KeywordFilter('-a').toString(), '"-a"');
      expect(KeywordFilter('a||b').toString(), '"a||b"');
    });

    test('ListFilter', () {
      expect(
        ListFilter(items: KeywordFilter('a')).toString(),
        'a',
      );
    });

    test('NotFilter', () {
      expect(
        NotFilter(KeywordFilter('a')).toString(),
        '-a',
      );
    });

    test('OrFilter', () {
      expect(
        OrFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]).toString(),
        'a OR b',
      );
      expect(
        OrFilter([
          KeywordFilter('v0'),
          AndFilter([KeywordFilter('v1'), KeywordFilter('v2')]),
          OrFilter([KeywordFilter('v3'), KeywordFilter('v4')]),
        ]).toString(),
        'v0 OR (v1 AND v2) OR (v3 OR v4)',
      );
    });

    test('PropertyValueFilter', () {
      expect(
        MapFilter({'name': KeywordFilter('value')}).toString(),
        'name:value',
      );
    });

    test('PropertyRangeFilter', () {
      expect(
        RangeFilter(min: 2).toString(),
        '>=2',
      );
      expect(
        RangeFilter(max: 3).toString(),
        '<=3',
      );
      expect(
        RangeFilter(min: 2, isExclusiveMin: true).toString(),
        '>2',
      );
      expect(
        RangeFilter(max: 3, isExclusiveMax: true).toString(),
        '<3',
      );
      expect(
        RangeFilter(min: 2, max: 3).toString(),
        '[2 TO 3]',
      );
      expect(
        RangeFilter(
          min: 2,
          max: 3,
          isExclusiveMin: true,
          isExclusiveMax: true,
        ).toString(),
        '{2 TO 3}',
      );
      expect(
        RangeFilter(min: 2, max: 3, isExclusiveMin: true).toString(),
        '{2 TO 3]',
      );
      expect(
        RangeFilter(min: 2, max: 3, isExclusiveMax: true).toString(),
        '[2 TO 3}',
      );
    });

    test('RegExpFilter', () {
      expect(
        RegExpFilter(RegExp('a')).toString(),
        '/a/',
      );
    });
  });
}
