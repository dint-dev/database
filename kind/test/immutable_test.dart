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
  group('$ImmutableKind:', () {
    final kind = _Example.kind;

    test('== / hashCode', () {
      final object = kind;
      final clone = kind;
      final other = ImmutableKind<_Example>(
        name: 'Example',
        blank: _Example(),
        walk: (f, t) {
          return t;
        },
      );

      // a == b
      expect(object, clone);
      expect(object, isNot(other));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other.hashCode));
    });

    test('register()', () {
      expect(Kind.all.where((item) => identical(item, kind)).length, 0);
      kind.register();
      expect(Kind.all.where((item) => identical(item, kind)).length, 1);
      kind.register();
      expect(Kind.all.where((item) => identical(item, kind)).length, 1);
      Kind.registerAll([kind]);
      expect(Kind.all.where((item) => identical(item, kind)).length, 1);
      Kind.registerAll([kind]);
      expect(Kind.all.where((item) => identical(item, kind)).length, 1);
    });

    test('toPolymorphic()', () {
      expect(
        kind.toPolymorphic(),
        PolymorphicKind<_Example>(
          name: kind.name,
          defaultKinds: [kind],
        ),
      );
    });

    test('newInstance()', () {
      expect(kind.newInstance(), isA<_Example>());
    });

    test('isValid', () {
      final kind = ImmutableKind<String>(
        blank: '',
        walk: (f, t) {
          f(
            t,
            'stringValue',
            kind: const StringKind(
              lengthInUtf8: IntKind(min: 1, max: 2),
            ),
          );
          return t;
        },
      );
      expect(kind.isValid(''), isFalse);
      expect(kind.isValid('a'), isTrue);
      expect(kind.isValid('ab'), isTrue);
      expect(kind.isValid('abc'), isFalse);
    });

    test('checkValid', () {
      final kind = ImmutableKind<String>(
        blank: '',
        walk: (f, t) {
          f(
            t,
            'stringValue',
            kind: const StringKind(
              lengthInUtf8: IntKind(min: 1, max: 2),
            ),
          );
          return t;
        },
      );
      expect(() => kind.checkValid(''), throwsArgumentError);
      kind.checkValid('a');
      kind.checkValid('ab');
      expect(() => kind.checkValid('abc'), throwsArgumentError);
    });

    test('examples', () {
      final kind = ImmutableKind<String>(
        blank: '',
        walk: (f, t) {
          f(
            t,
            'stringValue',
            kind: const StringKind(
              lengthInUtf8: IntKind(min: 1, max: 2),
            ),
          );
          return t;
        },
      );
      for (var example in kind.examples) {
        expect(kind.isValid(example), isTrue);
      }
      for (var example in kind.examplesThatAreInvalid) {
        expect(kind.isValid(example), isFalse);
      }
      expect(kind.examplesWithoutValidation.length, greaterThan(4));
      for (var example in kind.examplesWithoutValidation) {
        expect(kind.isInstance(example), isTrue);
      }
    });

    test('fieldMirrors', () {
      expect(
        kind.defaultValueMirror.fieldMirrors.map((e) => e.name).toList(),
        [
          'boolValue',
          'intValue',
          'doubleValue',
          'stringValue',
          'nullableStringValue',
          'nullableExampleValue'
        ],
      );
      final instance = kind.newInstance();
      final mirror = InstanceMirror.of(instance, kind: kind);
      for (var fieldMirror in kind.defaultValueMirror.fieldMirrors) {
        final name = fieldMirror.name;
        expect(
          mirror.get(name),
          fieldMirror.defaultValue,
          reason: 'Field "$name"',
        );
        expect(
          mirror.getFieldMirror(name),
          fieldMirror,
          reason: 'Field "$name"',
        );
      }
    });

    test('getField(instance, name)', () {
      final instance = _Example(
        boolValue: true,
        doubleValue: 3.14,
        nullableExampleValue: null,
      );
      final mirror = InstanceMirror.of(instance, kind: kind);
      expect(mirror.get('boolValue'), true);
      expect(mirror.get('doubleValue'), 3.14);
      expect(mirror.get('nullableExampleValue'), null);
      expect(() => mirror.get('OTHER'), throwsArgumentError);
    });

    test('missing kind', () {
      final kind = ImmutableKind<_MissingKindExample>(
        name: 'Example',
        blank: _MissingKindExample(value: null),
        walk: (f, t) {
          return _MissingKindExample(
            value: f(t.value, 'value'),
          );
        },
      );

      try {
        kind.defaultValueMirror;
        fail('Expected an error');
      } catch (error) {
        expect(
          error.toString(),
          contains('Could not find kind for _MissingKindExample?'),
        );
      }
    });

    group('memorySize(...):', () {
      const emptySize = 80;

      test('empty', () {
        final example = _Example();
        expect(_Example.kind.memorySize(example), emptySize);
      });

      test('bool', () {
        final example = _Example(
          boolValue: false,
        );
        expect(_Example.kind.memorySize(example), emptySize);
      });

      test('int', () {
        final example = _Example(
          intValue: 42,
        );
        expect(_Example.kind.memorySize(example), emptySize);
      });

      test('string', () {
        final example = _Example(
          nullableStringValue: 'abc',
        );
        expect(_Example.kind.memorySize(example), 120);
      });

      test('object', () {
        final example = _Example(
          nullableExampleValue: _Example(),
        );
        expect(_Example.kind.memorySize(example), 128);
      });
    });

    group('json:', () {
      test('example', () {
        final value = _Example(
          boolValue: true,
          intValue: 42,
          doubleValue: 3.14,
          stringValue: 'abc',
          nullableStringValue: 'nullable string',
          nullableExampleValue: _Example(),
        );
        final json = {
          'boolValue': true,
          'intValue': 42.0,
          'doubleValue': 3.14,
          'stringValue': 'abc',
          'nullableStringValue': 'nullable string',
          'nullableExampleValue': {
            'boolValue': false,
            'intValue': 0.0,
            'doubleValue': 0.0,
            'stringValue': '',
            'nullableStringValue': null,
            'nullableExampleValue': null,
          },
        };

        // Encode
        expect(kind.encodeJsonTree(value), json);

        // Decode
        final decoded = kind.decodeJsonTree(json);
        expect(decoded.boolValue, value.boolValue);
        expect(decoded.intValue, value.intValue);
        expect(decoded.doubleValue, value.doubleValue);
        expect(decoded.stringValue, value.stringValue);
        expect(decoded.nullableExampleValue?.intValue,
            value.nullableExampleValue?.intValue);
        expect(decoded.nullableExampleValue, value.nullableExampleValue);
        expect(decoded, value);
      });

      test('uses `superKind`', () {
        late Kind<_Example> kind;
        kind = ImmutableKind(
          name: 'Example',
          blank: const _Example(),
          walk: (f, t) {
            return _Example(
              nullableExampleValue: f(
                t.nullableExampleValue,
                'nullableExampleValue',
                superKind: kind,
              ),
            );
          },
        );
        expect(
          kind.decodeJsonTree({
            'nullableExampleValue': {},
          }).nullableExampleValue,
          isNotNull,
        );
      });

      test('custom `fromJson` (Map<String,dynamic>)', () {
        final kind = ImmutableKind(
          name: 'Example',
          blank: const _Example(),
          walk: (f, t) => t,
          fromJson: (Map<String, dynamic> json) =>
              _Example(stringValue: json['stringValue'] as String),
        );
        expect(
          kind.decodeJsonTree({'stringValue': 'abc'}).stringValue,
          'abc',
        );
      });

      test('custom `fromJson` (String)', () {
        final kind = ImmutableKind(
          name: 'Example',
          blank: const _Example(),
          walk: (f, t) => t,
          fromJson: (String json) => _Example(stringValue: json),
        );
        expect(
          kind.decodeJsonTree('abc').stringValue,
          'abc',
        );
      });

      test('custom `fromJson` (Object?)', () {
        final kind = ImmutableKind(
          name: 'Example',
          blank: const _Example(),
          walk: (f, t) => t,
          fromJson: (Object? json) => _Example(stringValue: json as String),
        );
        expect(
          kind.decodeJsonTree('abc').stringValue,
          'abc',
        );
      });

      test('custom `fromJson` (dynamic)', () {
        final kind = ImmutableKind(
          name: 'Example',
          blank: const _Example(),
          walk: (f, t) => t,
          fromJson: (dynamic json) => _Example(stringValue: json as String),
        );
        expect(
          kind.decodeJsonTree('abc').stringValue,
          'abc',
        );
      });

      test('custom `toJson`', () {
        final kind = ImmutableKind(
          name: 'Example',
          blank: const _Example(),
          walk: (f, t) => t,
          toJson: (value) => value.stringValue,
        );
        expect(
          kind.encodeJsonTree(_Example(stringValue: 'abc')),
          'abc',
        );
      });

      test('jsonSerializable(...)', () {
        final kind = ImmutableKind<String>.jsonSerializable(
          name: 'Example',
          fromJson: (Map<String, dynamic> json) => json['string'],
          toJson: (value) => {'string': value},
        );
        expect(
          kind.decodeJsonTree({'string': 'abc'}),
          'abc',
        );
        expect(kind.encodeJsonTree('abc'), {'string': 'abc'});
      });
    });
  });
}

class _Example {
  static const kind = ImmutableKind(
    name: 'Example',
    blank: _Example(),
    walk: _walk,
  );

  final bool boolValue;
  final int intValue;
  final double doubleValue;
  final String stringValue;
  final String? nullableStringValue;
  final _Example? nullableExampleValue;

  const _Example({
    this.boolValue = false,
    this.intValue = 0,
    this.doubleValue = 0.0,
    this.stringValue = '',
    this.nullableStringValue,
    this.nullableExampleValue,
  });

  @override
  int get hashCode => Object.hash(
        boolValue,
        intValue,
        doubleValue,
        stringValue,
        nullableStringValue,
        nullableExampleValue,
      );

  @override
  bool operator ==(other) =>
      other is _Example &&
      boolValue == other.boolValue &&
      intValue == other.intValue &&
      doubleValue == other.doubleValue &&
      stringValue == other.stringValue &&
      nullableExampleValue == other.nullableExampleValue;

  static _Example _walk(Mapper f, _Example t) {
    return _Example(
      boolValue: f(t.boolValue, 'boolValue'),
      intValue: f(t.intValue, 'intValue'),
      doubleValue: f(t.doubleValue, 'doubleValue'),
      stringValue: f(t.stringValue, 'stringValue'),
      nullableStringValue: f(
        t.nullableStringValue,
        'nullableStringValue',
      ),
      nullableExampleValue: f(
        t.nullableExampleValue,
        'nullableExampleValue',
        kind: kind,
      ),
    );
  }
}

class _MissingKindExample {
  final _MissingKindExample? value;

  _MissingKindExample({required this.value});
}
