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
  group('$PolymorphicKind:', () {
    const kind = _Animal.kind;

    test('== / hashCode', () {
      final object = kind;
      final clone = PolymorphicKind<_Animal>(
        defaultKinds: [
          _Cat.kind,
          _Dog.kind,
        ],
      );
      final other = PolymorphicKind<_Animal>(
        defaultKinds: [
          _Cat.kind,
        ],
      );

      // a == b
      expect(object, clone);
      expect(object, isNot(other));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other.hashCode));
    });

    test('PolymorphicKind(...)', () {
      final kind = PolymorphicKind<Object?>(
        defaultKinds: [
          Kind.forInt,
          Kind.forString,
        ],
      );

      expect(kind.findKindByInstance(42), same(Kind.forInt));
      expect(kind.findKindByInstance('abc'), same(Kind.forString));
      expect(kind.findKindByInstance(true), same(Kind.forBool));

      expect(kind.findKindByName('int'), same(Kind.forInt));
      expect(kind.findKindByName('String'), same(Kind.forString));
      expect(kind.findKindByName('bool'), same(Kind.forBool));

      expect(kind.kindIndexOfKind(Kind.forInt), 0);
      expect(kind.kindIndexOfKind(Kind.forString), 1);
      expect(kind.kindIndexOfKind(Kind.forBool), 3);
    });

    test('PolymorphicKind.sealed(...)', () {
      final kind = PolymorphicKind<Object?>.sealed(
        defaultKinds: [
          Kind.forInt,
          Kind.forString,
        ],
      );

      expect(kind.findKindByInstance(42), same(Kind.forInt));
      expect(kind.findKindByInstance('abc'), same(Kind.forString));
      expect(() => kind.findKindByInstance(false), throwsArgumentError);

      expect(kind.findKindByName('int'), same(Kind.forInt));
      expect(kind.findKindByName('String'), same(Kind.forString));
      expect(() => kind.findKindByName('bool'), throwsArgumentError);

      expect(kind.kindIndexOfKind(Kind.forInt), 0);
      expect(kind.kindIndexOfKind(Kind.forString), 1);
      expect(kind.kindIndexOfKind(Kind.forBool), -1);
    });

    test('register()', () {
      kind.register();
      Kind.registerAll([kind]);
      expect(Kind.all, isNot(contains(kind)));
    });

    test('toPolymorphic()', () {
      expect(kind.toPolymorphic(), same(kind));
    });

    test('newInstance()', () {
      expect(kind.newInstance(), _Cat());
    });

    group('json:', () {
      test('null', () {
        final value = null;
        final json = null;

        // Encode
        expect(kind.toNullable().encodeJsonTree(value), json);
        // Decode
        expect(kind.toNullable().decodeJsonTree(json), value);
      });

      test('Decoding something unsupported fails', () {
        final json = {
          '@type': 'SOMETHING ELSE',
          'name': '',
        };

        // Decode
        expect(() => kind.decodeJsonTree(json), throwsArgumentError);
      });

      test('Cat', () {
        final value = _Cat();
        final json = {
          '@type': 'Cat',
          'name': '',
        };

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('Dog', () {
        final value = _Dog(
          name: 'Einstein',
        );
        final json = {
          '@type': 'Dog',
          'name': 'Einstein',
        };

        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });
    });
  });
}

class _Animal {
  static const kind = PolymorphicKind<_Animal>(
    defaultKinds: [
      _Cat.kind,
      _Dog.kind,
    ],
  );

  final String name;

  const _Animal({
    required this.name,
  });
}

class _Cat extends _Animal {
  static const kind = ImmutableKind<_Cat>(
    name: 'Cat',
    blank: _Cat(),
    walk: _mapper,
  );

  const _Cat({super.name = ''});

  @override
  int get hashCode => Object.hash(_Cat, name);

  @override
  bool operator ==(other) => other is _Cat && name == other.name;

  static _Cat _mapper(Mapper mapper, _Cat t) {
    return _Cat(
      name: mapper.required<String>(t.name, 'name'),
    );
  }
}

class _Dog extends _Animal {
  static const kind = ImmutableKind<_Dog>(
    name: 'Dog',
    blank: _Dog(),
    walk: _mapper,
  );

  const _Dog({super.name = ''});

  @override
  int get hashCode => Object.hash(_Dog, name);

  @override
  bool operator ==(other) => other is _Dog && name == other.name;

  static _Dog _mapper(Mapper mapper, _Dog t) {
    return _Dog(
      name: mapper<String>(t.name, 'name'),
    );
  }
}
