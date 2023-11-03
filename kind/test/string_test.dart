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
  group('$StringKind:', () {
    final kind = Kind.forString;

    test('== / hashCode', () {
      final object = kind;
      final clone = StringKind(
        lengthInUtf8: const IntKind(min: 0),
        lengthInUtf16: const IntKind(min: 0),
      );
      final other0 = StringKind(
        maxLines: 1,
      );
      final other1 = StringKind(
        lengthInUtf8: const IntKind(max: 4),
      );
      final other2 = StringKind(
        lengthInUtf16: const IntKind(max: 4),
      );
      final other3 = StringKind(
        pattern: 'abc',
      );

      // a == b
      expect(object, clone);
      expect(object, isNot(other0));
      expect(object, isNot(other1));
      expect(object, isNot(other2));
      expect(object, isNot(other3));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other0.hashCode));
      expect(object.hashCode, isNot(other1.hashCode));
      expect(object.hashCode, isNot(other2.hashCode));
      expect(object.hashCode, isNot(other3.hashCode));
    });

    test('name', () {
      expect(kind.name, 'String');
    });

    test('newInstance()', () {
      expect(kind.newInstance(), '');
    });

    group('debugString(...):', () {
      test(r'\x00', () {
        expect(kind.debugString('\x00'), r'"\x00"');
      });

      test(r'\t', () {
        expect(kind.debugString('\t'), r'"\t"');
      });

      test(r'\n', () {
        expect(kind.debugString('\n'), r'"\n"');
      });

      test(r'\r', () {
        expect(kind.debugString('\r'), r'"\r"');
      });

      test(r'\v', () {
        expect(kind.debugString('\v'), r'"\v"');
      });

      test(r'\x1F', () {
        expect(kind.debugString('\x1F'), r'"\x1f"');
      });

      test(r'\x7F', () {
        expect(kind.debugString('\x7F'), r'"\x7f"');
      });

      test(r'length = 128', () {
        final s = 'x' * 128;
        expect(
          kind.debugString(s),
          '"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"',
        );
      });

      test(r'length = 129', () {
        final s = 'x' * 129;
        expect(
          kind.debugString(s),
          '"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"'
          ' ... '
          '"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"',
        );
      });
    });

    test('maxLines', () {
      final kind = StringKind(maxLines: 1);
      expect(kind.isValid(''), true);
      expect(kind.isValid('a'), true);
      expect(kind.isValid('a\n'), false);
    });

    test('lengthInUtf8', () {
      final kind = StringKind(lengthInUtf8: IntKind(max: 1));
      expect(kind.isValid(''), true);
      expect(kind.isValid('a'), true);
      expect(kind.isValid('ä'), false);
      expect(kind.isValid('ab'), false);
    });

    test('lengthInUtf16', () {
      final kind = StringKind(lengthInUtf16: IntKind(max: 1));
      expect(kind.isValid(''), true);
      expect(kind.isValid('a'), true);
      expect(kind.isValid('ä'), true);
      expect(kind.isValid('ab'), false);
    });

    test('pattern', () {
      final kind = StringKind(pattern: r'^[a-z]*$');
      expect(kind.isValid('A'), false);
      expect(kind.isValid('abc'), true);
    });

    group('json:', () {
      test('""', () {
        final value = '';
        final json = '';

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}
