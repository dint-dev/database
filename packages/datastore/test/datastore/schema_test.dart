// Copyright 2019 terrier989@gmail.com.
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

import 'package:datastore/datastore.dart';
import 'package:test/test.dart';

void main() {
  group('BoolSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = BoolSchema();
      final clone = BoolSchema();
      final other = StringSchema();
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = BoolSchema();
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree(false), isTrue);
      expect(schema.isValidTree(true), isTrue);
    });
  });

  group('IntSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = IntSchema();
      final clone = IntSchema();
      final other = DoubleSchema();
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = IntSchema();
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(3.14), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree(3), isTrue);
    });
  });

  group('IntSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = DoubleSchema();
      final clone = DoubleSchema();
      final other = IntSchema();
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = DoubleSchema();
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree(3.14), isTrue);
    });
  });

  group('DateTimeSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = DateTimeSchema();
      final clone = DateTimeSchema();
      final other = DoubleSchema();
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = DateTimeSchema();
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(3.14), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree(DateTime(2020, 1, 1)), isTrue);
    });

    test('decodeJson', () {
      final schema = DateTimeSchema();
      expect(
        schema.decodeJson('1970-01-01T00:00:00.000Z'),
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    });

    test('encodeJson', () {
      final schema = DateTimeSchema();
      expect(
        schema.encodeJson(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        '1970-01-01T00:00:00.000Z',
      );
    });
  });

  group('StringSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = StringSchema();
      final clone = StringSchema();
      final other = DoubleSchema();
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = StringSchema();
      expect(schema.isValidTree(3.14), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree('abc'), isTrue);
    });
  });

  group('BytesSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = BytesSchema();
      final clone = BytesSchema();
      final other = StringSchema();
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = BytesSchema();
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree(Uint8List(0)), isTrue);
    });

    test('encodeJson', () {
      final schema = BytesSchema();
      expect(schema.encodeJson(null), isNull);
      expect(schema.encodeJson(Uint8List(0)), '');
      expect(schema.encodeJson(Uint8List.fromList([1, 2, 3])), 'AQID');
    });

    test('decodeJson', () {
      final schema = BytesSchema();
      expect(schema.decodeJson(null), isNull);
      expect(schema.decodeJson(''), Uint8List(0));
      expect(schema.decodeJson('AQID'), Uint8List.fromList([1, 2, 3]));
    });
  });

  group('ListSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = ListSchema(maxLength: 2);
      final clone = ListSchema(maxLength: 2);
      final other = ListSchema(maxLength: 16);
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = ListSchema();
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree([]), isTrue);
    });

    test('isValid (cyclic)', () {
      final schema = ListSchema(
        items: MapSchema(
          properties: {
            'k': ListSchema(),
          },
        ),
      );

      // Non-cyclic input
      expect(
        schema.isValidTree([
          {'k': []}
        ]),
        isTrue,
      );

      // Cyclic input
      final x = [];
      x.add({'k': x});
      expect(schema.isValidTree(x), isFalse);
    });

    test('select: "items" has a schema', () {
      final schema = ListSchema(
        items: MapSchema(
          properties: {
            'k0': StringSchema(),
          },
        ),
      );
      expect(
        schema.selectTree(null),
        isNull,
      );
      expect(
        schema.selectTree([]),
        [],
      );
      expect(
        () => schema.selectTree(['abc']),
        throwsArgumentError,
      );
      expect(
        schema.selectTree([
          {'other': 'v0'}
        ]),
        [{}],
      );
      expect(
        schema.selectTree([
          {'k0': 'v0'}
        ]),
        [
          {'k0': 'v0'}
        ],
      );

      // Test that the result is immutable
      final result = schema.selectTree([]);
      expect(() => result.add(1), throwsUnsupportedError);
    });

    test('encodeJson: "items" is null', () {
      final schema = ListSchema();

      // OK
      expect(
        schema.encodeJson(null),
        isNull,
      );

      // OK
      expect(
        schema.encodeJson([]),
        [],
      );

      // OK
      expect(
        schema.encodeJson(
          [
            Uint8List.fromList([1, 2, 3])
          ],
        ),
        [
          [1, 2, 3]
        ],
      );

      // Test that the returned value is immutable
      final value = schema.encodeJson([[]]);
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('encodeJson: "items" has a schema', () {
      final schema = ListSchema(items: BytesSchema());

      // OK
      expect(
        schema.encodeJson(null),
        isNull,
      );

      // OK
      expect(
        schema.encodeJson([]),
        [],
      );

      // OK
      expect(
        schema.encodeJson(
          [
            Uint8List.fromList([1, 2, 3])
          ],
        ),
        ['AQID'],
      );

      // Throws: invalid value
      expect(
        () => schema.encodeJson([DateTime(2020, 1, 1)]),
        throwsArgumentError,
      );

      // Test that the returned value is immutable
      final value = schema.encodeJson([null]);
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('decodeJson: "items" is null', () {
      final schema = ListSchema();

      // OK
      expect(
        schema.decodeJson(null),
        isNull,
      );

      // OK
      expect(
        schema.decodeJson([]),
        [],
      );

      // OK
      expect(schema.decodeJson([1, 2, 3]), [1, 2, 3]);

      // Test that the returned value is immutable
      final value = schema.decodeJson([null]);
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('decodeJson: "items" has a schema', () {
      final schema = ListSchema(items: BytesSchema());

      // OK
      expect(
        schema.decodeJson(null),
        isNull,
      );

      // OK
      expect(
        schema.decodeJson([]),
        [],
      );

      // OK
      expect(
        schema.decodeJson(['AQID']),
        [
          Uint8List.fromList([1, 2, 3])
        ],
      );

      // Test that the value is immutable
      final value = schema.decodeJson(['']);
      expect(() => value.add(1), throwsUnsupportedError);
    });
  });

  group('MapSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = MapSchema(
        properties: {'k': StringSchema()},
      );
      final clone = MapSchema(
        properties: {'k': StringSchema()},
      );
      final other0 = MapSchema(
        properties: {},
      );
      final other1 = MapSchema(
        properties: {
          'k': BoolSchema(),
        },
      );
      final other2 = MapSchema(
        properties: {
          'k': StringSchema(),
          'other': StringSchema(),
        },
      );
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other0.hashCode));
      expect(schema.hashCode, isNot(other1.hashCode));
      expect(schema.hashCode, isNot(other2.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other0));
      expect(schema, isNot(other1));
      expect(schema, isNot(other2));
    });

    test('isValid', () {
      final schema = MapSchema();
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree({}), isTrue);
      expect(schema.isValidTree({'k': 'v'}), isTrue);
    });

    test('isValid (cyclic)', () {
      final schema = MapSchema(properties: {
        'k': ListSchema(
          items: MapSchema(),
        ),
      });

      // Non-cyclic input
      expect(
        schema.isValidTree({
          'k': [{}]
        }),
        isTrue,
      );

      // Cyclic input
      final x = {};
      x['k'] = [x];
      expect(schema.isValidTree(x), isFalse);
    });

    test('select: "properties" has a schema', () {
      final schema = MapSchema(
        properties: {
          'k0': MapSchema(
            properties: {
              'k1': StringSchema(),
            },
          )
        },
      );
      expect(
        schema.selectTree(null),
        isNull,
      );
      expect(
        schema.selectTree({}),
        {},
      );
      expect(
        schema.selectTree({'other': 'v'}),
        {},
      );
      expect(
        () => schema.selectTree({'k0': 'v'}),
        throwsArgumentError,
      );
      expect(
        schema.selectTree({'k0': {}}),
        {'k0': {}},
      );
      expect(
        schema.selectTree({
          'k0': {'other': 'v'}
        }),
        {'k0': {}},
      );
      expect(
        schema.selectTree({
          'k0': {'k1': 'v1'}
        }),
        {
          'k0': {'k1': 'v1'}
        },
      );

      // Test that the result is immutable
      final result = schema.selectTree({});
      expect(() => result['k'] = 'v', throwsUnsupportedError);
    });

    test('decodeJson: "properties" has a schema', () {
      final schema = MapSchema(properties: {'k': BytesSchema()});

      // OK
      expect(
        schema.decodeJson(null),
        isNull,
      );

      // OK
      expect(
        schema.decodeJson({}),
        {},
      );

      // OK
      expect(
        schema.decodeJson(
          {
            'k': 'AQID',
          },
        ),
        {
          'k': Uint8List.fromList([1, 2, 3]),
        },
      );

      // Throws: invalid value
      expect(
        () => schema.decodeJson({'k': DateTime(2020, 1, 1)}),
        throwsArgumentError,
      );

      // The returned value should be immutable
      final value = schema.encodeJson({'k': null});
      expect(() => value['k'] = null, throwsUnsupportedError);
    });

    test('encodeJson: "properties" has a schema', () {
      final schema = MapSchema(properties: {'k': BytesSchema()});

      // OK
      expect(
        schema.encodeJson(null),
        isNull,
      );

      // OK
      expect(
        schema.encodeJson({}),
        {},
      );

      // OK
      expect(
        schema.encodeJson(
          {
            'k': Uint8List.fromList([1, 2, 3])
          },
        ),
        {'k': 'AQID'},
      );

      // Throws: invalid value
      expect(
        () => schema.encodeJson(DateTime(2020, 1, 1)),
        throwsArgumentError,
      );

      // The returned value should be immutable
      final value = schema.encodeJson({'k': null});
      expect(() => value['k'] = null, throwsUnsupportedError);
    });
  });
}
