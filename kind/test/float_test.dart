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
  group('$FloatKind:', () {
    final kind = Kind.forDouble;

    test('== / hashCode', () {
      final object = kind;
      final clone = FloatKind();
      final other0 = FloatKind(min: 3.14);
      final other1 = FloatKind(max: 3.14);

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
        FloatKind().toString(),
        'FloatKind()',
      );
      expect(
        FloatKind(min: 0.0).toString(),
        'FloatKind(min: 0.0)',
      );
      expect(
        FloatKind.float32().toString(),
        'FloatKind.float32()',
      );
      expect(
        FloatKind.float32(min: 0.0).toString(),
        'FloatKind.float32(min: 0.0)',
      );
      expect(
        FloatKind.float64().toString(),
        'FloatKind.float64()',
      );
      expect(
        FloatKind.float64(min: 0.0).toString(),
        'FloatKind.float64(min: 0.0)',
      );
    });

    test('name', () {
      expect(kind.name, 'double');
    });

    test('newInstance()', () {
      expect(kind.newInstance(), 0.0);
    });

    group('newFixedLengthList(...)', () {
      test('FloatKind()', () {
        expect(
          FloatKind().newList(2, growable: false),
          allOf(isA<Float64List>(), hasLength(2)),
        );
      });
      test('FloatKind.float32()', () {
        expect(
          FloatKind.float32().newList(2, growable: false),
          allOf(isA<Float32List>(), hasLength(2)),
        );
      });
      test('FloatKind.float64()', () {
        expect(
          FloatKind.float64().newList(2, growable: false),
          allOf(isA<Float64List>(), hasLength(2)),
        );
      });
    });

    test('debugString(...)', () {
      expect(kind.debugString(0), '0.0');
      expect(kind.debugString(3.14), '3.14');
    });

    test('compare(a,b)', () {
      expect(kind.compare(0.0, 0.0), 0);
      expect(kind.compare(double.nan, double.nan), 0);
      expect(kind.compare(double.infinity, double.infinity), 0);
      expect(kind.compare(double.negativeInfinity, double.negativeInfinity), 0);

      expect(kind.compare(-1.0, 2.0), -1);
      expect(kind.compare(2.0, -1.0), 1);

      expect(kind.compare(0.0, double.nan), -1);
      expect(kind.compare(double.nan, 0.0), 1);
    });

    test('isValid(instance)', () {
      expect(kind.isValid(0.0), isTrue);

      {
        final kind = FloatKind(min: 2.0);
        expect(kind.isValid(1.9), isFalse);
        expect(kind.isValid(2.0), isTrue);
        expect(kind.isValid(2.1), isTrue);
      }

      {
        final kind = FloatKind(min: 2.0, isExclusiveMin: true);
        expect(kind.isValid(1.9), isFalse);
        expect(kind.isValid(2.0), isFalse);
        expect(kind.isValid(2.1), isTrue);
      }

      {
        final kind = FloatKind(max: 2.0);
        expect(kind.isValid(1.9), isTrue);
        expect(kind.isValid(2.0), isTrue);
        expect(kind.isValid(2.1), isFalse);
      }

      {
        final kind = FloatKind(max: 2.0, isExclusiveMax: true);
        expect(kind.isValid(1.9), isTrue);
        expect(kind.isValid(2.0), isFalse);
        expect(kind.isValid(2.1), isFalse);
      }
    });

    group('json:', () {
      test('0.0', () {
        final value = 0.0;
        final json = 0.0;
        // Encode
        expect(kind.encodeJsonTree(value), json);
        //Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('3.14', () {
        final value = 3.14;
        final json = 3.14;
        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('double.nan', () {
        final value = double.nan;
        final json = 'NaN';
        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), isNaN);
      });

      test('double.infinity', () {
        final value = double.infinity;
        final json = 'Infinity';
        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('double.negativeInfinity', () {
        final value = double.negativeInfinity;
        final json = '-Infinity';
        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('-0.0', () {
        // Encode
        expect(kind.encodeJsonTree(-0.0), 0.0);
        // Decode
        expect(kind.decodeJsonTree(-0.0), 0.0);
      });
    });
  });
}
