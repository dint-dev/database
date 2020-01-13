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

import 'package:database/database.dart';
import 'package:fixnum/fixnum.dart';
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

    test('decodeLessTyped', () {
      final schema = DateTimeSchema();
      expect(
        schema.decodeLessTyped('1970-01-01T00:00:00.000Z'),
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    });

    test('encodeLessTyped', () {
      final schema = DateTimeSchema();
      expect(
        schema.encodeLessTyped(
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        '1970-01-01T00:00:00.000Z',
      );
    });
  });

  group('Schema:', () {
    group('fromJson:', () {
      test('null', () {
        expect(
          Schema.fromJson(null),
          isNull,
        );
      });
      test('bool', () {
        expect(
          Schema.fromJson(BoolSchema.nameForJson),
          const BoolSchema(),
        );
      });
      test('int', () {
        expect(
          Schema.fromJson(IntSchema.nameForJson),
          const IntSchema(),
        );
      });
      test('Int64', () {
        expect(
          Schema.fromJson(Int64Schema.nameForJson),
          const Int64Schema(),
        );
      });
      test('double', () {
        expect(
          Schema.fromJson(DoubleSchema.nameForJson),
          const DoubleSchema(),
        );
      });
      test('Datetime', () {
        expect(
          Schema.fromJson(DateTimeSchema.nameForJson),
          const DateTimeSchema(),
        );
      });
      test('GeoPoint', () {
        expect(
          Schema.fromJson(GeoPointSchema.nameForJson),
          const GeoPointSchema(),
        );
      });
      test('Document', () {
        expect(
          Schema.fromJson(DocumentSchema.nameForJson),
          const DocumentSchema(),
        );
      });

      test('List: []', () {
        expect(
          Schema.fromJson([]),
          const ListSchema(itemsByIndex: []),
        );
      });

      test('List: ["string"]', () {
        expect(
          Schema.fromJson(['string']),
          const ListSchema(itemsByIndex: [
            StringSchema(),
          ]),
        );
      });

      test('List: [null, "double", "string"]', () {
        expect(
          Schema.fromJson([null, 'double', 'string']),
          const ListSchema(itemsByIndex: [
            null,
            DoubleSchema(),
            StringSchema(),
          ]),
        );
      });

      test('List: {"@type": "list", ...}', () {
        expect(
          Schema.fromJson({'@type': 'list', '@items': 'string'}),
          const ListSchema(
            items: StringSchema(),
          ),
        );
      });
      test('Map', () {
        expect(
          Schema.fromJson({}),
          const MapSchema({}),
        );
        expect(
          Schema.fromJson({
            'k0': 'double',
            'k1': 'string',
          }),
          const MapSchema({
            'k0': DoubleSchema(),
            'k1': StringSchema(),
          }),
        );
      });
    });
    group('fromValue:', () {
      test('null', () {
        expect(
          Schema.fromValue(null),
          isNull,
        );
      });
      test('bool', () {
        expect(
          Schema.fromValue(false),
          const BoolSchema(),
        );
        expect(
          Schema.fromValue(true),
          const BoolSchema(),
        );
      });
      test('int (VM)', () {
        expect(
          Schema.fromValue(3),
          const IntSchema(),
        );
      }, testOn: 'vm');
      test('int (not VM)', () {
        expect(
          Schema.fromValue(3),
          const DoubleSchema(),
        );
      }, testOn: '!vm');
      test('double', () {
        expect(
          Schema.fromValue(3.14),
          const DoubleSchema(),
        );
      });
      test('Int64', () {
        expect(
          Schema.fromValue(Int64(3)),
          const Int64Schema(),
        );
      });
      test('DateTime', () {
        expect(
          Schema.fromValue(DateTime.fromMillisecondsSinceEpoch(0)),
          const DateTimeSchema(),
        );
      });
      test('GeoPoint', () {
        expect(
          Schema.fromValue(GeoPoint.zero),
          const GeoPointSchema(),
        );
      });
      test('String', () {
        expect(
          Schema.fromValue('abc'),
          const StringSchema(),
        );
      });
      test('Document', () {
        expect(
          Schema.fromValue(MemoryDatabase().collection('a').document('b')),
          const DocumentSchema(),
        );
      });
      test('List', () {
        expect(
          Schema.fromValue([null, 'a', 3.14]),
          const ListSchema(
            itemsByIndex: [null, StringSchema(), DoubleSchema()],
          ),
        );
      });
      test('Map', () {
        expect(
          Schema.fromValue({
            'string': 'value',
            'pi': 3.14,
          }),
          const MapSchema({
            'string': StringSchema(),
            'pi': DoubleSchema(),
          }),
        );
      });
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

    test('encodeLessTyped', () {
      final schema = BytesSchema();
      expect(schema.encodeLessTyped(null), isNull);
      expect(schema.encodeLessTyped(Uint8List(0)), '');
      expect(schema.encodeLessTyped(Uint8List.fromList([1, 2, 3])), 'AQID');
    });

    test('decodeLessTyped', () {
      final schema = BytesSchema();
      expect(schema.decodeLessTyped(null), isNull);
      expect(schema.decodeLessTyped(''), Uint8List(0));
      expect(schema.decodeLessTyped('AQID'), Uint8List.fromList([1, 2, 3]));
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
        items: MapSchema({
          'k': ListSchema(),
        }),
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
        items: MapSchema({
          'k0': StringSchema(),
        }),
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

    test('encodeLessTyped: "items" is null', () {
      final schema = ListSchema();

      // OK
      expect(
        schema.encodeLessTyped(null),
        isNull,
      );

      // OK
      expect(
        schema.encodeLessTyped([]),
        [],
      );

      // OK
      expect(
        schema.encodeLessTyped(
          [
            Uint8List.fromList([1, 2, 3])
          ],
        ),
        [
          [1, 2, 3]
        ],
      );

      // Test that the returned value is immutable
      final value = schema.encodeLessTyped([[]]);
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('encodeLessTyped: "items" has a schema', () {
      final schema = ListSchema(items: BytesSchema());

      // OK
      expect(
        schema.encodeLessTyped(null),
        isNull,
      );

      // OK
      expect(
        schema.encodeLessTyped([]),
        [],
      );

      // OK
      expect(
        schema.encodeLessTyped(
          [
            Uint8List.fromList([1, 2, 3])
          ],
        ),
        ['AQID'],
      );

      // Throws: invalid value
      expect(
        () => schema.encodeLessTyped([DateTime(2020, 1, 1)]),
        throwsArgumentError,
      );

      // Test that the returned value is immutable
      final value = schema.encodeLessTyped([null]);
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('decodeJson: "items" is null', () {
      final schema = ListSchema();

      // OK
      expect(
        schema.decodeLessTyped(null),
        isNull,
      );

      // OK
      expect(
        schema.decodeLessTyped([]),
        [],
      );

      // OK
      expect(schema.decodeLessTyped([1, 2, 3]), [1, 2, 3]);

      // Test that the returned value is immutable
      final value = schema.decodeLessTyped([null]);
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('decodeJson: "items" has a schema', () {
      final schema = ListSchema(items: BytesSchema());

      // OK
      expect(
        schema.decodeLessTyped(null),
        isNull,
      );

      // OK
      expect(
        schema.decodeLessTyped([]),
        [],
      );

      // OK
      expect(
        schema.decodeLessTyped(['AQID']),
        [
          Uint8List.fromList([1, 2, 3])
        ],
      );

      // Test that the value is immutable
      final value = schema.decodeLessTyped(['']);
      expect(() => value.add(1), throwsUnsupportedError);
    });
  });

  group('MapSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = MapSchema({
        'k': StringSchema(),
      });
      final clone = MapSchema({
        'k': StringSchema(),
      });
      final other0 = MapSchema({});
      final other1 = MapSchema({
        'k': BoolSchema(),
      });
      final other2 = MapSchema({
        'k': StringSchema(),
        'other': StringSchema(),
      });
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
      const schema = MapSchema({});
      expect(schema.isValidTree('abc'), isFalse);
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree({}), isTrue);
      expect(schema.isValidTree({'k': 'v'}), isTrue);
    });

    test('isValid (cyclic)', () {
      const schema = MapSchema({
        'k': ListSchema(
          items: MapSchema({}),
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
      final schema = MapSchema({
        'k0': MapSchema({
          'k1': StringSchema(),
        })
      });
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
      final schema = MapSchema({
        'k': BytesSchema(),
      });

      // OK
      expect(
        schema.decodeLessTyped(null),
        isNull,
      );

      // OK
      expect(
        schema.decodeLessTyped({}),
        {},
      );

      // OK
      expect(
        schema.decodeLessTyped(
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
        () => schema.decodeLessTyped({'k': DateTime(2020, 1, 1)}),
        throwsArgumentError,
      );

      // The returned value should be immutable
      final value = schema.encodeLessTyped({'k': null});
      expect(() => value['k'] = null, throwsUnsupportedError);
    });

    test('encodeLessTyped: "properties" has a schema', () {
      final schema = MapSchema({
        'k': BytesSchema(),
      });

      // OK
      expect(
        schema.encodeLessTyped(null),
        isNull,
      );

      // OK
      expect(
        schema.encodeLessTyped({}),
        {},
      );

      // OK
      expect(
        schema.encodeLessTyped(
          {
            'k': Uint8List.fromList([1, 2, 3])
          },
        ),
        {'k': 'AQID'},
      );

      // Throws: invalid value
      expect(
        () => schema.encodeLessTyped(DateTime(2020, 1, 1)),
        throwsArgumentError,
      );

      // The returned value should be immutable
      final value = schema.encodeLessTyped({'k': null});
      expect(() => value['k'] = null, throwsUnsupportedError);
    });
  });
}
