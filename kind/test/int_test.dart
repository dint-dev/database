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
import 'package:os/os.dart';
import 'package:test/test.dart';

void main() {
  group('$IntKind:', () {
    final kind = Kind.forInt;

    test('IntKind()', () {
      final kind = IntKind();
      expect(kind.bits, IntKind.bitsWhenJsCompatible);
      expect(kind.bits, 53);
      expect(kind.isUnsigned, false);
      expect(kind.isJsCompatible, true);

      const mask52 = 0xFFFFFFFFFFFFF;
      expect(kind.isValid(mask52 + 1), false);
      expect(kind.isValid(mask52), true);
      expect(kind.isValid(-mask52), true);
      expect(kind.isValid(-mask52 - 1), true);
      expect(kind.isValid(-mask52 - 2), false);
    });

    test('IntKind.unsigned()', () {
      final kind = IntKind.unsigned();
      expect(kind.bits, 52);
      expect(kind.bits, IntKind.bitsWhenJsCompatibleUnsigned);
      expect(kind.isUnsigned, true);
      expect(kind.isJsCompatible, true);

      const mask52 = 0xFFFFFFFFFFFFF;
      expect(kind.isValid(mask52 + 1), false);
      expect(kind.isValid(mask52), true);
      expect(kind.isValid(0), true);
      expect(kind.isValid(-1), false);
    });

    test('IntKind.int8(...)', () {
      final kind = IntKind.int8();
      expect(kind.bits, 8);
      expect(kind.isUnsigned, false);
      expect(kind.isJsCompatible, true);
      expect(kind.isValid(0x7F + 1), false);
      expect(kind.isValid(0x7F), true);
      expect(kind.isValid(-0x7F), true);
      expect(kind.isValid(-0x7F - 1), true);
      expect(kind.isValid(-0x7F - 2), false);
    });

    test('IntKind.int16(...)', () {
      final kind = IntKind.int16();
      expect(kind.bits, 16);
      expect(kind.isUnsigned, false);
      expect(kind.isJsCompatible, true);
      expect(kind.isValid(0x7FFF + 1), false);
      expect(kind.isValid(0x7FFF), true);
      expect(kind.isValid(-0x7FFF), true);
      expect(kind.isValid(-0x7FFF - 1), true);
      expect(kind.isValid(-0x7FFF - 2), false);
    });

    test('IntKind.int32(...)', () {
      final kind = IntKind.int32();
      expect(kind.bits, 32);
      expect(kind.isUnsigned, false);
      expect(kind.isJsCompatible, true);
      expect(kind.isValid(0x7FFFFFFF + 1), false);
      expect(kind.isValid(0x7FFFFFFF), true);
      expect(kind.isValid(-0x7FFFFFFF), true);
      expect(kind.isValid(-0x7FFFFFFF - 1), true);
      expect(kind.isValid(-0x7FFFFFFF - 2), false);
    });

    test('IntKind.int64(...)', () {
      final kind = IntKind.int64();
      expect(kind.bits, 64);
      expect(kind.isUnsigned, false);
      expect(kind.isJsCompatible, false);
      if (!isRunningInJs) {
        const mask32 = 0xFFFFFFFF;
        const bit32 = mask32 + 1;
        const mask63 = ((mask32 >> 1) * bit32) | mask32;
        expect(kind.isValid(mask63 + 1), true);
        expect(kind.isValid(mask63), true);
        expect(kind.isValid(-mask63), true);
        expect(kind.isValid(-mask63 - 1), true);
        expect(kind.isValid(-mask63 - 2), true);
      }
    });

    test('IntKind.uint8(...)', () {
      final kind = IntKind.uint8();
      expect(kind.bits, 8);
      expect(kind.isUnsigned, true);
      expect(kind.isJsCompatible, true);
      expect(kind.isValid(0xFF + 1), false);
      expect(kind.isValid(0xFF), true);
      expect(kind.isValid(0), true);
      expect(kind.isValid(-1), false);
    });

    test('IntKind.uint16(...)', () {
      final kind = IntKind.uint16();
      expect(kind.bits, 16);
      expect(kind.isUnsigned, true);
      expect(kind.isJsCompatible, true);
      expect(kind.isValid(0xFFFF + 1), false);
      expect(kind.isValid(0xFFFF), true);
      expect(kind.isValid(0), true);
      expect(kind.isValid(-1), false);
    });

    test('IntKind.uint32(...)', () {
      final kind = IntKind.uint32();
      expect(kind.bits, 32);
      expect(kind.isUnsigned, true);
      expect(kind.isJsCompatible, true);
      expect(kind.isValid(0xFFFFFFFF + 1), false);
      expect(kind.isValid(0xFFFFFFFF), true);
      expect(kind.isValid(0), true);
      expect(kind.isValid(-1), false);
    });

    test('IntKind.uint64(...)', () {
      final kind = IntKind.uint64();
      expect(kind.bits, 64);
      expect(kind.isUnsigned, true);
      expect(kind.isJsCompatible, false);
      expect(kind.isValid(0), true);

      // The Javascript complainer complains if you use 0x7FFFFFFFFFFFFFFF
      // directly.
      const maxBeforeOverflow = 0x7FFFFFFF * 0x100000000 + 0xFFFFFFFF;
      const max = 0xFFFFFFFF * 0x100000000 + 0xFFFFFFFF;
      expect(kind.isValid(0), true);
      expect(kind.isValid(maxBeforeOverflow), true);
      expect(kind.isValid(max), true);

      if (isRunningInJs) {
        expect(kind.isValid(-1), false);
        expect(kind.isValid(2 * max), false);
      } else {
        expect(max, -1);
      }
    });

    test('== / hashCode', () {
      final object = kind;
      final clone = IntKind();
      final other0 = IntKind(min: 42);
      final other1 = IntKind(max: 42);

      // a == b
      expect(object, clone);
      expect(object, isNot(other0));
      expect(object, isNot(other1));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other0.hashCode));
      expect(object.hashCode, isNot(other1.hashCode));
    });

    test('toString()', () {
      expect(
        IntKind().toString(),
        'IntKind()',
      );
      expect(
        IntKind.unsigned().toString(),
        'IntKind.unsigned()',
      );
      expect(
        IntKind.uint32().toString(),
        'IntKind.uint32()',
      );
      expect(
        IntKind.uint64().toString(),
        'IntKind.uint64()',
      );
      expect(
        IntKind.unsigned(min: 16).toString(),
        'IntKind.unsigned(min: 16)',
      );
      expect(
        IntKind.unsigned(max: 16).toString(),
        'IntKind.unsigned(max: 16)',
      );
    });

    test('name', () {
      expect(kind.name, 'int');
    });

    test('newInstance()', () {
      expect(kind.newInstance(), 0);
    });

    group('newFixedLengthList(...):', () {
      test('IntKind()', () {
        if (isRunningInJs) {
          expect(
            IntKind().newList(2, growable: false),
            allOf(isA<List<int>>(), hasLength(2)),
          );
        } else {
          expect(
            IntKind().newList(2, growable: false),
            allOf(isA<Int64List>(), hasLength(2)),
          );
        }
      });
      test('IntKind.unsigned()', () {
        if (isRunningInJs) {
          expect(
            IntKind.unsigned().newList(2, growable: false),
            allOf(isA<List<int>>(), hasLength(2)),
          );
        } else {
          expect(
            IntKind.unsigned().newList(2, growable: false),
            allOf(isA<Uint64List>(), hasLength(2)),
          );
        }
      });
      test('int8', () {
        expect(
          IntKind.int8().newList(2, growable: false),
          allOf(isA<Int8List>(), hasLength(2)),
        );
      });
      test('int16', () {
        expect(
          IntKind.int16().newList(2, growable: false),
          allOf(isA<Int16List>(), hasLength(2)),
        );
      });
      test('int32', () {
        expect(
          IntKind.int32().newList(2, growable: false),
          allOf(isA<Int32List>(), hasLength(2)),
        );
      });
      test('uint8', () {
        expect(
          IntKind.uint8().newList(2, growable: false),
          allOf(isA<Uint8List>(), hasLength(2)),
        );
      });
      test('uint16', () {
        expect(
          IntKind.uint16().newList(2, growable: false),
          allOf(isA<Uint16List>(), hasLength(2)),
        );
      });
      test('uint32', () {
        expect(
          IntKind.uint32().newList(2, growable: false),
          allOf(isA<Uint32List>(), hasLength(2)),
        );
      });
      test('int64', () {
        if (isRunningInJs) {
          expect(
            IntKind.int64().newList(2, growable: false),
            allOf(isA<List<int>>(), hasLength(2)),
          );
        } else {
          expect(
            IntKind.int64().newList(2, growable: false),
            allOf(isA<Int64List>(), hasLength(2)),
          );
        }
      });
      test('uint64', () {
        if (isRunningInJs) {
          expect(
            IntKind.uint64().newList(2, growable: false),
            allOf(isA<List<int>>(), hasLength(2)),
          );
        } else {
          expect(
            IntKind.uint64().newList(2, growable: false),
            allOf(isA<Uint64List>(), hasLength(2)),
          );
        }
      });
    });

    test('debugString(...)', () {
      expect(kind.debugString(0), '0');
      expect(kind.debugString(-99), '-99');
    });

    test('isValid(...): min', () {
      final kind = IntKind(min: 2);
      expect(kind.isValid(1), false);
      expect(kind.isValid(2), true);
      expect(kind.isValid(3), true);
    });

    test('isValid(...): max', () {
      final kind = IntKind(max: 2);
      expect(kind.isValid(1), true);
      expect(kind.isValid(2), true);
      expect(kind.isValid(3), false);
    });

    test('isValid(...): min and max', () {
      final kind = IntKind(min: 1, max: 1);
      expect(kind.isValid(0), false);
      expect(kind.isValid(1), true);
      expect(kind.isValid(2), false);
    });

    group('json:', () {
      test('0', () {
        final value = 0;
        final json = 0.0;

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('42', () {
        final value = 42;
        final json = 42.0;

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('-42', () {
        final value = -42;
        final json = -42.0;

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}
