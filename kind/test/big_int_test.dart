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

import 'dart:typed_data';

import 'package:kind/kind.dart';
import 'package:test/test.dart';

void main() {
  group('$BigIntKind:', () {
    final kind = Kind.forBigInt;

    test('== / hashCode', () {
      final object = kind;
      final clone = BigIntKind();
      final other0 = IntKind();
      final other1 = StringKind();

      // a == b
      expect(object, clone);
      expect(object, isNot(other0));
      expect(object, isNot(other1));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other0.hashCode));
      expect(object.hashCode, isNot(other1.hashCode));
    });

    test('name', () {
      expect(kind.name, 'BigInt');
    });

    test('newInstance()', () {
      expect(kind.newInstance(), BigInt.zero);
    });

    test('newList', () {
      expect(
        BigIntKind().newList(2),
        allOf(isA<List<BigInt>>(), isNot(isA<TypedData>()), hasLength(2)),
      );
    });

    group('json:', () {
      test('0', () {
        final value = BigInt.zero;
        final json = '0';

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}
