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

import 'package:database/search_query_parsing.dart';
import 'package:test/test.dart';

void main() {
  group('QueryScanner', () {
    final scanner = Scanner();

    test('`a`', () {
      const input = 'a';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
        ],
      );
    });
    test('`abc`', () {
      const input = 'abc';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'abc'),
        ],
      );
    });

    test('`a b`', () {
      const input = 'a b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`"a" "b"`', () {
      const input = '"a" "b"';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.quotedString, 'a'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.quotedString, 'b'),
        ],
      );
    });

    test('`a AND b`', () {
      const input = 'a AND b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.operatorAnd, 'AND'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`a OR b`', () {
      const input = 'a OR b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.operatorOr, 'OR'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`(a)`', () {
      const input = '(a)';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.leftParenthesis, '('),
          Token(TokenType.string, 'a'),
          Token(TokenType.rightParenthesis, ')'),
        ],
      );
    });

    test('`(a b)`', () {
      const input = '(a b)';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.leftParenthesis, '('),
          Token(TokenType.string, 'a'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'b'),
          Token(TokenType.rightParenthesis, ')'),
        ],
      );
    });

    test('`[a b]`', () {
      const input = '[a b]';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.leftSquareBracket, '['),
          Token(TokenType.string, 'a'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'b'),
          Token(TokenType.rightSquareBracket, ']'),
        ],
      );
    });

    test('`{a b}`', () {
      const input = '{a b}';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.leftCurlyBracket, '{'),
          Token(TokenType.string, 'a'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'b'),
          Token(TokenType.rightCurlyBracket, '}'),
        ],
      );
    });

    test('`-a`', () {
      const input = '-a';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.operatorNot, '-'),
          Token(TokenType.string, 'a'),
        ],
      );
    });

    test('`a:b`', () {
      const input = 'a:b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`a:b c:d`', () {
      const input = 'a:b c:d';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.string, 'b'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'c'),
          Token(TokenType.colon, ':'),
          Token(TokenType.string, 'd'),
        ],
      );
    });

    test('`a:=b`', () {
      const input = 'a:=b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.equal, '='),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`a:="b"`', () {
      const input = 'a:="b"';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.equal, '='),
          Token(TokenType.quotedString, 'b'),
        ],
      );
    });

    test('`a:=2020-12-31T00:00:00.000Z`', () {
      const input = 'a:=2020-12-31T00:00:00.000Z';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.equal, '='),
          Token(TokenType.string, '2020-12-31T00:00:00.000Z'),
        ],
      );
    });

    test('`a=b`', () {
      const input = 'a=b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a=b'),
        ],
      );
    });

    test('`a:[b TO c]', () {
      const input = 'a:[b TO c]';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.leftSquareBracket, '['),
          Token(TokenType.string, 'b'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'TO'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'c'),
          Token(TokenType.rightSquareBracket, ']'),
        ],
      );
    });

    test('`a:{b TO c}', () {
      const input = 'a:{b TO c}';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.leftCurlyBracket, '{'),
          Token(TokenType.string, 'b'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'TO'),
          Token(TokenType.whitespace, ' '),
          Token(TokenType.string, 'c'),
          Token(TokenType.rightCurlyBracket, '}'),
        ],
      );
    });

    test('`a:>b', () {
      const input = 'a:>b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.greaterThan, '>'),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`a:>=b', () {
      const input = 'a:>=b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.greaterThanEqual, '>='),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`a:<b', () {
      const input = 'a:<b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.lessThan, '<'),
          Token(TokenType.string, 'b'),
        ],
      );
    });

    test('`a:<=b', () {
      const input = 'a:<=b';
      expect(
        scanner.scanString(input),
        [
          Token(TokenType.string, 'a'),
          Token(TokenType.colon, ':'),
          Token(TokenType.lessThanEqual, '<='),
          Token(TokenType.string, 'b'),
        ],
      );
    });
  });
}
