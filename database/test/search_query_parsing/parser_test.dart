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

import 'dart:typed_data';

import 'package:database/database.dart';
import 'package:database/search_query_parsing.dart';
import 'package:test/test.dart';

void main() {
  group('QueryParser', () {
    final parser = SearchQueryParser();

    test('`a`', () {
      const input = 'a';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        KeywordFilter('a'),
      );
    });

    test('`a b c', () {
      const input = 'a b c';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
          KeywordFilter('c'),
        ]),
      );
    });

    test('`"`', () {
      const input = '"';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        KeywordFilter(''),
      );
    });

    test('`""`', () {
      const input = '""';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        KeywordFilter(''),
      );
    });

    test('`"a`', () {
      const input = '"a';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        KeywordFilter('a'),
      );
    });

    test('`"a"`', () {
      const input = '"a"';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        KeywordFilter('a'),
      );
    });

    test('`"a" "b"`', () {
      const input = '"a" "b"';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
    });

    test('`"a b c" "d e f"`', () {
      const input = '"a b c" "d e f"';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        AndFilter([
          KeywordFilter('a b c'),
          KeywordFilter('d e f'),
        ]),
      );
    });

    test('a -b c', () {
      const input = 'a -b c';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        AndFilter([
          KeywordFilter('a'),
          NotFilter(KeywordFilter('b')),
          KeywordFilter('c'),
        ]),
      );
    });

    test('a -{b c}', () {
      const inputs = [
        'a -(b c)',
        'a -( b c )',
      ];
      for (var input in inputs) {
        final filter = parser.parseFilterFromString(input);
        expect(
          filter,
          AndFilter([
            KeywordFilter('a'),
            NotFilter(AndFilter([
              KeywordFilter('b'),
              KeywordFilter('c'),
            ])),
          ]),
        );
      }
    });

    test('a -(b c)', () {
      const inputs = [
        'a -(b c)',
        'a -( b c )',
      ];
      for (var input in inputs) {
        final filter = parser.parseFilterFromString(input);
        expect(
          filter,
          AndFilter([
            KeywordFilter('a'),
            NotFilter(AndFilter([
              KeywordFilter('b'),
              KeywordFilter('c'),
            ])),
          ]),
        );
      }
    });

    test('a AND b', () {
      const input = 'a AND b';
      final filter = parser.parseFilterFromString(input);
      expect(filter, isA<AndFilter>());
      if (filter is AndFilter) {
        expect(filter.filters, hasLength(2));
        expect(filter.filters[0], KeywordFilter('a'));
        expect(filter.filters[1], KeywordFilter('b'));
      }
      expect(
        filter,
        AndFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
    });

    test('a OR b', () {
      const input = 'a OR b';
      final filter = parser.parseFilterFromString(input);
      expect(filter, isA<OrFilter>());
      if (filter is OrFilter) {
        expect(filter.filters, hasLength(2));
        expect(filter.filters[0], KeywordFilter('a'));
        expect(filter.filters[1], KeywordFilter('b'));
      }
      expect(
        filter,
        OrFilter([
          KeywordFilter('a'),
          KeywordFilter('b'),
        ]),
      );
    });

    test('a:b', () {
      const input = 'a:b';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': KeywordFilter('b')}),
      );
    });

    test('a:b c:d', () {
      const input = 'a:b c:d';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        AndFilter([
          MapFilter({'a': KeywordFilter('b')}),
          MapFilter({'c': KeywordFilter('d')}),
        ]),
      );
    });

    test('a:=example', () {
      const input = 'a:=example';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter('example')}),
      );
    });

    test('a:=example:=<<=>>=', () {
      const input = 'a:=example:=<<=>>=';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter('example:=<<=>>=')}),
      );
    });

    test('a:="null"', () {
      const input = 'a:="null"';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter('null')}),
      );
    });

    test('a:=null', () {
      const input = 'a:=null';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(null)}),
      );
    });

    test('a:=false', () {
      const input = 'a:=false';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(false)}),
      );
    });

    test('a:=true', () {
      const input = 'a:=true';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(true)}),
      );
    });

    test('a:=3', () {
      const input = 'a:=3';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(3)}),
      );
    });

    test('a:=3.14', () {
      const input = 'a:=3.14';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(3.14)}),
      );
    });

    test('a:=2020-', () {
      const input = 'a:=2020-';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter('2020-')}),
      );
    });

    test('a:=2020-12', () {
      const input = 'a:=2020-12';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter('2020-12')}),
      );
    });

    test('a:=2020-12-', () {
      const input = 'a:=2020-12-';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter('2020-12-')}),
      );
    });

    test('a:=2020-12-31', () {
      const input = 'a:=2020-12-31';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(Date(2020, 12, 31))}),
      );
    });

    test('a:=2020-12-31T00:00:00.000Z', () {
      const input = 'a:=2020-12-31T00:00:00.000Z';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(DateTime.utc(2020, 12, 31, 0, 0, 0, 0))}),
      );
    });

    test('a:=base64:', () {
      const input = 'a:=base64:';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter(Uint8List(0))}),
      );
    });

    test('a:=base64:^%#!not-base-64', () {
      const input = 'a:=base64:^%#!not-base-64';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': ValueFilter('base64:^%#!not-base-64')}),
      );
    });

    test('a:[3 TO 4]', () {
      const input = 'a:[3 TO 4]';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': RangeFilter(min: 3, max: 4)}),
      );
    });

    test('a:[* TO 4]', () {
      const input = 'a:[3 TO *]';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': RangeFilter(min: 3)}),
      );
    });

    test('a:[* TO 4]', () {
      const input = 'a:[* TO 4]';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': RangeFilter(max: 4)}),
      );
    });

    test('a:>=3', () {
      const input = 'a:>=3';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': RangeFilter(min: 3)}),
      );
    });

    test('a:<=4', () {
      const input = 'a:<=4';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': RangeFilter(max: 4)}),
      );
    });

    test('a:>3', () {
      const input = 'a:>3';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': RangeFilter(min: 3, isExclusiveMin: true)}),
      );
    });

    test('a:<4', () {
      const input = 'a:<4';
      final filter = parser.parseFilterFromString(input);
      expect(
        filter,
        MapFilter({'a': RangeFilter(max: 4, isExclusiveMax: true)}),
      );
    });
  });
}
