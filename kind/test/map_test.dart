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
  group('$MapKind:', () {
    final kind = MapKind(
      keyKind: IntKind(),
      valueKind: StringKind(),
    );

    test('== / hashCode', () {
      final object = kind;
      final clone = MapKind(
        keyKind: IntKind(),
        valueKind: StringKind(),
      );
      final other = Kind.forInt;

      // a == b
      expect(object, clone);
      expect(object, isNot(other));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other.hashCode));
    });

    test('newInstance()', () {
      expect(kind.newInstance(), <int, String>{});
    });

    group('debugString(...):', () {
      test('empty', () {
        final kind = MapKind(
          keyKind: StringKind(),
          valueKind: IntKind(),
        );
        final instance = <String, int>{};
        expect(
          kind.debugString(instance),
          '<String, int>{}',
        );
      });

      test('single-line', () {
        final kind = MapKind(
          keyKind: StringKind(),
          valueKind: IntKind(),
        );
        final instance = <String, int>{
          'v0': 0,
          'v1': 1,
        };
        expect(
          kind.debugString(instance),
          '<String, int>{"v0": 0, "v1": 1}',
        );
      });

      test('multi-line', () {
        final kind = MapKind(
          keyKind: StringKind(),
          valueKind: IntKind(),
        );
        final instance = <String, int>{
          '-' * 60: 1,
        };
        expect(
          kind.debugString(instance),
          '<String, int>{\n'
          '  "------------------------------------------------------------": 1,\n'
          '}',
        );
      });
    });

    test('memorySize', () {
      final kind = MapKind(
        keyKind: const StringKind(),
        valueKind: IntKind(),
      );
      expect(
        kind.memorySize({'x': 42}),
        104,
      );
    });

    group('json:', () {
      test('{3.13: "example"}', () {
        final value = <int, String>{
          42: 'example',
        };
        final json = {'42': 'example'};

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}
