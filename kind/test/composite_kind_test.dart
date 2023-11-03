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
  group('$CompositeKind:', () {
    final kind = Example.kind;

    test('== / hashCode', () {
      final object = kind;
      final clone = kind;
      final other = Kind.forInt;

      // a == b
      expect(object, clone);
      expect(object, isNot(other));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other.hashCode));
    });

    test('newInstance()', () {
      expect(kind.newInstance(), Example(''));
    });

    group('json:', () {
      test('example', () {
        final value = Example('abc');
        final json = 'abc';

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}

class Example {
  static final kind = CompositeKind<Example, String>.inline(
    name: 'Example',
    kind: const StringKind(),
    encode: (v) => v.value,
    decode: (v) => Example(v),
  );

  final String value;

  const Example(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(other) => other is Example && value == other.value;
}
