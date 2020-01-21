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

import 'package:database/sql.dart';
import 'package:test/test.dart';

void main() {
  group('SqlStatement:', () {
    test('"==" / hashCode', () {
      final value = SqlStatement('example ? ?', ['a', 'b']);
      final clone = SqlStatement('example ? ?', ['a', 'b']);
      final other0 = SqlStatement('example ? ?', ['a', 'c']);
      final other1 = SqlStatement('other', ['a', 'b']);

      expect(value, clone);
      expect(value, isNot(other0));
      expect(value, isNot(other1));

      expect(value.hashCode, clone.hashCode);
      expect(value.hashCode, isNot(other0.hashCode));
      expect(value.hashCode, isNot(other1.hashCode));
    });

    group('replaceParameters:', () {
      test('empty', () {
        expect(
          SqlStatement(
            'example',
            [],
          ).replaceParameters((i, value) => '@$i'),
          'example',
        );
      });
      test('one parameter', () {
        expect(
          SqlStatement(
            '-?-',
            ['a'],
          ).replaceParameters((i, value) => '@$i'),
          '-@0-',
        );
      });
      test('two parameters', () {
        expect(
          SqlStatement(
            'example ? ?',
            ['a', 'b'],
          ).replaceParameters((i, value) => '@$i'),
          'example @0 @1',
        );
      });
    });
  });

  group('SqlStatemetnBuilder:', () {
    test('argument(...)', () {
      final b = SqlSourceBuilder();
      b.write('a ');
      b.argument(3);
      b.write(' b');
      expect(b.build(), SqlStatement('a ? b', [3]));
    });

    test('identifier(...)', () {
      final b = SqlSourceBuilder();
      expect(() => b.identifier('\n'), throwsArgumentError);
      expect(() => b.identifier(' '), throwsArgumentError);
      expect(() => b.identifier('"'), throwsArgumentError);
      expect(() => b.identifier(r'\'), throwsArgumentError);
      expect(() => b.identifier(r'%'), throwsArgumentError);
      b.identifier('example_');
      expect(b.build(), SqlStatement('"example_"'));
    });

    group('replaceParameters:', () {
      test('empty', () {
        expect(
          SqlStatement(
            'example',
            [],
          ).replaceParameters((i, value) => '@$i'),
          'example',
        );
      });
      test('one parameter', () {
        expect(
          SqlStatement(
            '-?-',
            ['a'],
          ).replaceParameters((i, value) => '@$i'),
          '-@0-',
        );
      });
      test('two parameters', () {
        expect(
          SqlStatement(
            'example ? ?',
            ['a', 'b'],
          ).replaceParameters((i, value) => '@$i'),
          'example @0 @1',
        );
      });
    });
  });
}
