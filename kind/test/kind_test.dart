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
  group('$Kind:', () {
    test('Kind.all is unmodifiable', () {
      final kind = _Animal.kind;
      expect(() => Kind.all.add(kind), throwsUnsupportedError);
      expect(() => Kind.all.clear(), throwsUnsupportedError);
    });

    test('registerAll', () {
      final kind = _Animal.kind;
      expect(Kind.all.where((item) => identical(item, kind)).length, 0);
      Kind.registerAll([
        kind,
      ]);
      expect(Kind.all.where((item) => identical(item, kind)).length, 1);
      Kind.registerAll([
        kind,
      ]);
      expect(Kind.all.where((item) => identical(item, kind)).length, 1);
    });

    group('Kind.findByType(...):', () {
      test('Null', () {
        expect(
          Kind.maybeFindByType<Null>(),
          same(Kind.forNull),
        );
      });

      test('bool', () {
        expect(
          Kind.maybeFindByType<bool>(),
          same(Kind.forBool),
        );
      });

      test('int', () {
        expect(
          Kind.maybeFindByType<int>(),
          same(Kind.forInt),
        );
      });

      test('int?', () {
        expect(
          Kind.maybeFindByType<int?>(),
          same(Kind.forInt.toNullable()),
        );
      });

      test('List<int>', () {
        expect(
          Kind.maybeFindByType<List<int>>(),
          ListKind(elementKind: Kind.forInt),
        );
      });

      test('List<int>?', () {
        expect(
          Kind.maybeFindByType<List<int>?>(),
          ListKind(elementKind: Kind.forInt).toNullable(),
        );
      });

      test('Set<int>', () {
        expect(
          Kind.maybeFindByType<Set<int>>(),
          SetKind(elementKind: Kind.forInt),
        );
      });

      test('double', () {
        expect(
          Kind.maybeFindByType<double>(),
          same(Kind.forDouble),
        );
      });

      test('DateTime', () {
        expect(
          Kind.maybeFindByType<DateTime>(),
          same(Kind.forDateTime),
        );
      });

      test('Duration', () {
        expect(
          Kind.maybeFindByType<Duration>(),
          same(Kind.forDuration),
        );
      });

      test('String', () {
        expect(
          Kind.maybeFindByType<String>(),
          same(Kind.forString),
        );
      });

      test('Uint8List', () {
        expect(
          Kind.maybeFindByType<Uint8List>(),
          same(Kind.forUint8List),
        );
      });
    });

    group('maybeFindByInstance(...):', () {
      test('null', () {
        expect(
          Kind.maybeFindByInstance(null),
          same(Kind.forNull),
        );
      });

      test('bool: false', () {
        expect(
          Kind.maybeFindByInstance(false),
          same(Kind.forBool),
        );
      });

      test('bool: true', () {
        expect(
          Kind.maybeFindByInstance(true),
          same(Kind.forBool),
        );
      });

      test('int', () {
        expect(
          Kind.maybeFindByInstance(0),
          same(Kind.forInt),
        );
      });

      test('int?', () {
        expect(
          Kind.maybeFindByInstance<int?>(0),
          same(Kind.forInt.toNullable()),
        );
        if (isRunningInJs) {
          expect(
            Kind.maybeFindByInstance<Object?>(0),
            same(Kind.forDouble.toNullable()),
          );
        } else {
          expect(
            Kind.maybeFindByInstance<Object?>(0),
            same(Kind.forInt.toNullable()),
          );
        }
      });

      test('String', () {
        expect(
          Kind.maybeFindByInstance(''),
          same(Kind.forString),
        );
      });

      test('String?', () {
        expect(
          Kind.maybeFindByInstance<Object?>(''),
          same(Kind.forString.toNullable()),
        );
      });
    });
    group('find<T>(instance: ...):', () {
      test('null', () {
        expect(
          Kind.find(instance: null),
          same(Kind.forNull),
        );
      });

      test('bool: false', () {
        expect(
          Kind.find(instance: false),
          same(Kind.forBool),
        );
      });

      test('bool: true', () {
        expect(
          Kind.find(instance: true),
          same(Kind.forBool),
        );
      });

      test('int', () {
        expect(
          Kind.find(instance: 0),
          same(Kind.forInt),
        );
      });

      test('double', () {
        expect(
          Kind.find(instance: 3.14),
          same(Kind.forDouble),
        );
      });

      test('Uint8List', () {
        expect(
          Kind.find(instance: Uint8List(0)),
          Uint8ListKind(),
        );
      });

      test('Uint16List', () {
        expect(
          Kind.find<List<int>>(instance: Uint16List(0)),
          ListKind(elementKind: IntKind.uint16()),
        );
      });

      test('Uint32List', () {
        expect(
          Kind.find<List<int>>(instance: Uint32List(0)),
          ListKind(elementKind: IntKind.uint32()),
        );
      });

      if (!isRunningInJs) {
        test('Uint64List', () {
          expect(
            Kind.find<List<int>>(instance: Uint64List(0)),
            ListKind(elementKind: IntKind.uint64()),
          );
        });
      }

      test('Int16List', () {
        expect(
          Kind.find<List<int>>(instance: Int16List(0)),
          ListKind(elementKind: IntKind.int16()),
        );
      });

      test('Int32List', () {
        expect(
          Kind.find<List<int>>(instance: Int32List(0)),
          ListKind(elementKind: IntKind.int32()),
        );
      });

      if (!isRunningInJs) {
        test('Int64List', () {
          expect(
            Kind.find<List<int>>(instance: Int64List(0)),
            ListKind(elementKind: IntKind.int64()),
          );
        });
      }

      test('List<int>', () {
        expect(
          Kind.find(instance: <int>[]),
          ListKind(elementKind: IntKind()),
        );

        // Type parameter: Object?
        expect(
          Kind.find<Object?>(instance: <int>[]),
          ListKind(elementKind: IntKind()).toNullable(),
        );

        // Type parameter: List
        expect(
          Kind.find<List>(instance: <int>[]),
          ListKind(elementKind: IntKind()),
        );
      });

      test('Set<int>', () {
        expect(
          Kind.find(instance: <int>{}),
          SetKind(elementKind: IntKind()),
        );
      });
    });

    test('isSubKind', () {
      final animal = _Animal.kind;
      final mammal = _Mammal.kind;
      final dog = _Dog.kind;
      expect(mammal.isSubKind(animal), isFalse);
      expect(mammal.isSubKind(animal, andNotEqual: false), isFalse);
      expect(mammal.isSubKind(mammal), isFalse);
      expect(mammal.isSubKind(mammal, andNotEqual: false), isTrue);
      expect(mammal.isSubKind(dog), isTrue);
      expect(mammal.isSubKind(dog, andNotEqual: false), isTrue);

      expect(mammal.isSubKind(animal.toNullable()), isFalse);
      expect(mammal.isSubKind(mammal.toNullable()), isFalse);
      expect(
          mammal.isSubKind(mammal.toNullable(), andNotEqual: false), isFalse);
      expect(mammal.isSubKind(dog.toNullable()), isFalse);
    });

    test('isNullableSubKind', () {
      final animal = _Animal.kind;
      final mammal = _Mammal.kind;
      final dog = _Dog.kind;
      expect(mammal.isNullableSubKind(animal), isFalse);
      expect(mammal.isNullableSubKind(animal, andNotEqual: false), isFalse);
      expect(mammal.isNullableSubKind(mammal), isFalse);
      expect(mammal.isNullableSubKind(mammal, andNotEqual: false), isTrue);
      expect(mammal.isNullableSubKind(dog), isTrue);
      expect(mammal.isNullableSubKind(dog, andNotEqual: false), isTrue);

      expect(mammal.isNullableSubKind(animal.toNullable()), isFalse);
      expect(mammal.isNullableSubKind(mammal.toNullable()), isFalse);
      expect(mammal.isNullableSubKind(mammal.toNullable(), andNotEqual: false),
          isTrue);
      expect(mammal.isNullableSubKind(dog.toNullable()), isTrue);
    });
  });
}

class _Animal {
  static final kind = ImmutableKind<_Animal>(
    name: 'Animal',
    blank: _Animal(),
    walk: (f, t) => throw Error(),
  );
}

class _Dog extends _Mammal {
  static final kind = ImmutableKind<_Dog>(
    name: 'Dog',
    blank: _Dog(),
    walk: (f, t) => throw Error(),
  );
}

class _Mammal extends _Animal {
  static final kind = ImmutableKind<_Mammal>(
    name: 'Mammal',
    blank: _Mammal(),
    walk: (f, t) => throw Error(),
  );
}
