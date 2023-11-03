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
  group('$Uint8ListKind:', () {
    final kind = Kind.forUint8List;

    test('== / hashCode', () {
      final object = kind;
      final clone = Uint8ListKind(
        length: IntKind(min: 0),
      );
      final other0 = Uint8ListKind(
        name: 'OTHER',
      );
      final other1 = Uint8ListKind(
        length: IntKind(min: 1),
      );

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
      expect(kind.name, 'Uint8List');
    });

    test('newInstance()', () {
      expect(kind.newInstance(), same(Uint8ListKind.empty));
    });

    test('debugString(...)', () {
      expect(
        kind.debugString(Uint8List.fromList([])),
        'hex""',
      );
      expect(
        kind.debugString(Uint8List.fromList([0x00])),
        'hex"00"',
      );
      expect(
        kind.debugString(Uint8List.fromList([0xFF, 0x00])),
        'hex"ff00"',
      );
      expect(
        kind.debugString(
          Uint8List.fromList(List<int>.generate(65, (index) => index)),
        ),
        'hex"00010203...3d3e3f40" (L=65)',
      );
    });

    group('memorySize(...):', () {
      test('empty', () {
        final instance = Uint8List(0);
        expect(kind.memorySize(instance), 128);
      });

      test('length = 3', () {
        final instance = Uint8List(3);
        expect(kind.memorySize(instance), 136);
      });
    });

    group('json:', () {
      test('[2,3]', () {
        final value = Uint8List.fromList([2, 3]);
        final json = 'AgM=';

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}
