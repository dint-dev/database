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
  group('$SetKind:', () {
    final kind = const SetKind(elementKind: IntKind());

    test('== / hashCode', () {
      final object = kind;
      final clone = SetKind(elementKind: IntKind());
      final other = Kind.forInt;

      // a == b
      expect(object, clone);
      expect(object, isNot(other));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other.hashCode));
    });

    test('name', () {
      expect(kind.name, 'Set');
    });

    test('newInstance()', () {
      expect(kind.newInstance(), <int>{});
      expect(kind.newInstance()..add(42), {42});
    });

    test('memorySize', () {
      expect(
        SetKind(elementKind: IntKind()).memorySize({0, 1, 2}),
        32 + 3 * 8,
      );
    });

    group('json:', () {
      test('<int>{}', () {
        final value = <int>{};
        final json = [];

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('{42}', () {
        final value = {42};
        final json = [42.0];

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}
