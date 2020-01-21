// Copyright 2019 Gohilla Ltd.
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:database/database.dart';
import 'package:database/schema.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

void main() {
  final jsonEncoder = JsonEncoder();
  final jsonDecoder = JsonDecoder(database: null);

  group('ArbitaryTreeSchema:', () {
    test('"==" / "hashCode"', () {
      final schema = ArbitraryTreeSchema();
      final clone = ArbitraryTreeSchema();
      final other = ArbitraryTreeSchema(
        doubleSchema: DoubleSchema(supportSpecialValues: true),
      );
      expect(schema.hashCode, clone.hashCode);
      expect(schema.hashCode, isNot(other.hashCode));
      expect(schema, clone);
      expect(schema, isNot(other));
    });

    test('isValid', () {
      final schema = ArbitraryTreeSchema();
      expect(schema.isValidTree(null), isTrue);
      expect(schema.isValidTree(false), isTrue);
      expect(schema.isValidTree(true), isTrue);
      expect(schema.isValidTree(3), isTrue);
      expect(schema.isValidTree(Int64(3)), isTrue);
      expect(schema.isValidTree(3.14), isTrue);
      expect(schema.isValidTree(double.nan), isFalse);
      expect(schema.isValidTree(double.infinity), isFalse);
      expect(schema.isValidTree(double.negativeInfinity), isFalse);
      expect(schema.isValidTree(Date(2020, 12, 31)), isTrue);
      expect(schema.isValidTree(DateTime(2020, 12, 31)), isTrue);
      expect(schema.isValidTree('abc'), isTrue);
      expect(schema.isValidTree([]), isTrue);
      expect(schema.isValidTree(['item']), isTrue);
      expect(schema.isValidTree({}), isTrue);
      expect(schema.isValidTree({'key': 'value'}), isTrue);

      expect(schema.isValidTree(double.nan), isFalse);
      expect(schema.isValidTree([double.nan]), isFalse);
      expect(schema.isValidTree({'key': double.nan}), isFalse);
      expect(schema.isValidTree(double.negativeInfinity), isFalse);
      expect(schema.isValidTree(double.infinity), isFalse);
    });
  });

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

  group('DoubleSchema:', () {
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
      expect(schema.isValidTree(double.nan), isFalse);
      expect(schema.isValidTree(double.negativeInfinity), isFalse);
      expect(schema.isValidTree(double.infinity), isFalse);
    });

    test('isValid: special values enabled', () {
      final schema = DoubleSchema(supportSpecialValues: true);
      expect(schema.isValidTree(double.nan), isTrue);
      expect(schema.isValidTree(double.negativeInfinity), isTrue);
      expect(schema.isValidTree(double.infinity), isTrue);
    });

    test('decode JSON: special strings: disabled', () {
      final schema = DoubleSchema();
      expect(
        schema.decodeWith(jsonDecoder, 3.14),
        3.14,
      );
      expect(
        () => schema.decodeWith(jsonDecoder, 'nan'),
        throwsArgumentError,
      );
      expect(
        () => schema.decodeWith(jsonDecoder, '-inf'),
        throwsArgumentError,
      );
      expect(
        () => schema.decodeWith(jsonDecoder, '+inf'),
        throwsArgumentError,
      );
    });

    test('decode JSON: special strings: enabled', () {
      final schema = DoubleSchema();
      final jsonDecoder = JsonDecoder(
        database: null,
        supportSpecialDoubleValues: true,
      );
      expect(
        schema.decodeWith(jsonDecoder, 3.14),
        3.14,
      );
      expect(
        schema.decodeWith(jsonDecoder, 'nan'),
        isNaN,
      );
      expect(
        schema.decodeWith(jsonDecoder, '-inf'),
        double.negativeInfinity,
      );
      expect(
        schema.decodeWith(jsonDecoder, '+inf'),
        double.infinity,
      );
    });

    test('encode JSON: special strings: disabled', () {
      final schema = DoubleSchema();
      expect(
        () => schema.encodeWith(jsonEncoder, double.nan),
        throwsArgumentError,
      );
      expect(
        () => schema.encodeWith(jsonEncoder, double.infinity),
        throwsArgumentError,
      );
      expect(
        () => schema.encodeWith(jsonEncoder, double.negativeInfinity),
        throwsArgumentError,
      );
    });

    test('encode JSON: special strings: enabled', () {
      final schema = DoubleSchema();
      final jsonEncoder = JsonEncoder(
        supportSpecialDoubleValues: true,
      );
      expect(
        schema.encodeWith(jsonEncoder, 3.14),
        3.14,
      );
      expect(
        schema.encodeWith(jsonEncoder, double.nan),
        'nan',
      );
      expect(
        schema.encodeWith(jsonEncoder, double.negativeInfinity),
        '-inf',
      );
      expect(
        schema.encodeWith(jsonEncoder, double.infinity),
        '+inf',
      );
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

    test('decode JSON', () {
      final schema = DateTimeSchema();
      expect(
        schema.decodeWith(jsonDecoder, '1970-01-01T00:00:00.000Z'),
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    });

    test('encode JSON', () {
      final schema = DateTimeSchema();
      expect(
        schema.encodeWith(
          jsonEncoder,
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        ),
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
          Schema.fromValue(
            MemoryDatabaseAdapter().database().collection('a').document('b'),
          ),
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

    test('encode JSON', () {
      final schema = BytesSchema();
      expect(schema.encodeWith(jsonEncoder, null), isNull);
      expect(schema.encodeWith(jsonEncoder, Uint8List(0)), '');
      expect(schema.encodeWith(jsonEncoder, Uint8List.fromList([1, 2, 3])),
          'AQID');
    });

    test('decode JSON', () {
      final schema = BytesSchema();
      expect(schema.decodeWith(jsonDecoder, null), isNull);
      expect(schema.decodeWith(jsonDecoder, ''), Uint8List(0));
      expect(schema.decodeWith(jsonDecoder, 'AQID'),
          Uint8List.fromList([1, 2, 3]));
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

    test('encode JSON: "items" is null', () {
      final schema = ListSchema();

      // OK
      expect(
        schema.encodeWith(jsonEncoder, null),
        isNull,
      );

      // OK
      expect(
        schema.encodeWith(jsonEncoder, []),
        [],
      );

      // OK
      expect(
        schema.acceptVisitor(
          jsonEncoder,
          [
            Uint8List.fromList([1, 2, 3])
          ],
        ),
        [
          [1, 2, 3]
        ],
      );
    });

    test('encode JSON: "items" has a schema', () {
      final schema = ListSchema(items: BytesSchema());

      // OK
      expect(
        schema.encodeWith(jsonEncoder, null),
        isNull,
      );

      // OK
      expect(
        schema.encodeWith(jsonEncoder, []),
        [],
      );

      // OK
      expect(
        schema.acceptVisitor(
          jsonEncoder,
          [
            Uint8List.fromList([1, 2, 3])
          ],
        ),
        ['AQID'],
      );

      // Throws: invalid value
      expect(
        () => schema.encodeWith(jsonEncoder, [DateTime(2020, 1, 1)]),
        throwsArgumentError,
      );
    });

    test('encode JSON: returns an immutable list', () {
      final schema = ListSchema(items: BytesSchema());
      final value = schema.encodeWith(jsonEncoder, [null]) as List;
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('decode JSON: "items" is null', () {
      final schema = ListSchema();

      // OK
      expect(
        schema.decodeWith(jsonDecoder, null),
        isNull,
      );

      // OK
      expect(
        schema.decodeWith(jsonDecoder, []),
        [],
      );

      // OK
      expect(schema.decodeWith(jsonDecoder, [1, 2, 3]), [1, 2, 3]);

      // Test that the returned value is immutable
      final value = schema.decodeWith(jsonDecoder, [null]);
      expect(() => value.add(1), throwsUnsupportedError);
    });

    test('decode JSON: "items" has a schema', () {
      final schema = ListSchema(items: BytesSchema());

      // OK
      expect(
        schema.decodeWith(jsonDecoder, null),
        isNull,
      );

      // OK
      expect(
        schema.decodeWith(jsonDecoder, []),
        [],
      );

      // OK
      expect(
        schema.decodeWith(jsonDecoder, ['AQID']),
        [
          Uint8List.fromList([1, 2, 3])
        ],
      );
    });

    test('decode JSON: returns an immutable list', () {
      final schema = ListSchema(items: BytesSchema());
      final value = schema.decodeWith(jsonDecoder, ['']);
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
    });

    test('select: returns an immutable map', () {
      final schema = MapSchema({
        'k0': MapSchema({
          'k1': StringSchema(),
        })
      });
      final result = schema.selectTree({});
      expect(() => result['k'] = 'v', throwsUnsupportedError);
    });

    test('decode JSON: "properties" has a schema', () {
      final schema = MapSchema({
        'k': BytesSchema(),
      });

      // OK
      expect(
        schema.decodeWith(jsonDecoder, null),
        isNull,
      );

      // OK
      expect(
        schema.decodeWith(jsonDecoder, {}),
        {},
      );

      // OK
      expect(
        schema.acceptVisitor(
          jsonDecoder,
          {
            'k': 'AQID',
          },
        ),
        {
          'k': Uint8List.fromList([1, 2, 3]),
        },
      );
    });

    test('decode JSON: returns immutable map', () {
      final schema = MapSchema({
        'k': BytesSchema(),
      });
      final value = schema.encodeWith(jsonEncoder, {'k': null}) as Map;
      expect(() => value['k'] = null, throwsUnsupportedError);
    });

    test('encode JSON: "properties" has a schema', () {
      final schema = MapSchema({
        'k': BytesSchema(),
      });

      // OK
      expect(
        schema.encodeWith(jsonEncoder, null),
        isNull,
      );

      // OK
      expect(
        schema.encodeWith(jsonEncoder, {}),
        {},
      );

      // OK
      expect(
        schema.acceptVisitor(
          jsonEncoder,
          {
            'k': Uint8List.fromList([1, 2, 3])
          },
        ),
        {'k': 'AQID'},
      );
    });

    test('encode JSON: returns an immutable map', () {
      final schema = MapSchema({
        'k': BytesSchema(),
      });
      final value = schema.encodeWith(jsonEncoder, {'k': null}) as Map;
      expect(() => value['k'] = null, throwsUnsupportedError);
    });
  });
}
