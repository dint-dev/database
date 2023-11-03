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
  group('$HasKind:', () {
    test('== / hashCode', () {
      final object = _Example('x', b: 'y');
      final clone = _Example('x', b: 'y');
      final other0 = _Example('x', b: 'OTHER');
      final other1 = _Example('OTHER', b: 'y');

      printOnFailure(
          'Object: ${InstanceMirror.of(object, kind: _Example.kind).toMap()}');
      printOnFailure(
          'Object: ${InstanceMirror.of(clone, kind: _Example.kind).toMap()}');
      printOnFailure(
          'Other: ${InstanceMirror.of(other0, kind: _Example.kind).toMap()}');

      // a == b
      expect(object, clone);
      expect(object, isNot(other0));
      expect(object, isNot(other1));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other0.hashCode));
      expect(object.hashCode, isNot(other1.hashCode));
    });

    group('toString():', () {
      test('all filled', () {
        final object = _Example('positional', b: 'required', c: ['e0', 'e1']);
        expect(
          object.toString(),
          '_Example.constructorIdentifier(\n'
          '  "positional",\n'
          '  b: "required",\n'
          '  c: <String>["e0", "e1"],\n'
          ')',
        );
      });

      test('an optional argument has default value', () {
        final object = _Example('positional', b: 'required', c: []);
        expect(
          object.toString(),
          '_Example.constructorIdentifier(\n'
          '  "positional",\n'
          '  b: "required",\n'
          ')',
        );
      });
    });
  });
}

class _Example with HasKind {
  static const kind = ImmutableKind<_Example>(
    name: '_Example',
    blank: _Example._(),
    walk: _map,
  );

  final String a;
  final String b;
  final List<String> c;

  const _Example(
    this.a, {
    required this.b,
    this.c = const [],
  });

  const _Example._() : this('', b: '');

  @override
  Kind<_Example> get runtimeKind => kind;

  static _Example _map(Mapper f, _Example t) {
    f.setConstructorIdentifier('constructorIdentifier');
    return _Example(
      f.positional(t.a, 'a'),
      b: f.required(t.b, 'b'),
      c: f(t.c, 'c'),
    );
  }
}
