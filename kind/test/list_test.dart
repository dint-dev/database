// Copyright 2021 Gohilla Ltd.
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

import 'package:kind/kind.dart';
import 'package:test/test.dart';

void main() {
  group('$ListKind:', () {
    final kind = ListKind<int>(elementKind: IntKind());

    test('== / hashCode', () {
      final object = kind;
      final clone = ListKind(elementKind: IntKind());
      final other = ListKind(elementKind: StringKind());

      // a == b
      expect(object, clone);
      expect(object, isNot(other));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other.hashCode));
    });

    test('name', () {
      expect(kind.name, 'List');
    });

    test('newInstance()', () {
      expect(kind.newInstance(), []);
      expect(kind.newInstance()..add(42), [42]);
    });

    group('debugString(...)', () {
      test('empty', () {
        expect(kind.debugString(<int>[]), '<int>[]');
      });

      test('single item, 2 characters', () {
        expect(kind.debugString([42]), '<int>[42]');
      });

      test('single item, 60 characters', () {
        final kind = ListKind(elementKind: StringKind());
        expect(
          kind.debugString(['-' * 60]),
          '<String>[\n'
          '  "------------------------------------------------------------",\n'
          ']',
        );
      });

      test('6 items, each 1 character', () {
        expect(
          kind.debugString([1, 2, 3, 4, 5, 6]),
          '<int>[1, 2, 3, 4, 5, 6]',
        );
      });

      test('6 items, each 10 characters', () {
        final kind = ListKind(elementKind: StringKind());
        expect(
          kind.debugString([
            '-' * 10,
            '-' * 10,
            '-' * 10,
            '-' * 10,
            '-' * 10,
            '-' * 10,
          ]),
          '<String>[\n'
          '  "----------",\n'
          '  "----------",\n'
          '  "----------",\n'
          '  "----------",\n'
          '  "----------",\n'
          '  "----------",\n'
          ']',
        );
      });

      test('200 items', () {
        expect(
          kind.debugString(List<int>.generate(200, (index) => index)),
          '<int>[...200 items...]',
        );
      });
    });

    test('memorySize', () {
      expect(
        ListKind(elementKind: IntKind()).memorySize([0, 1, 2]),
        32 + 3 * 8,
      );
    });

    group('json:', () {
      test('[]', () {
        final value = <int>[];
        final json = [];

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('[42]', () {
        final value = [42];
        final json = [42.0];

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}
