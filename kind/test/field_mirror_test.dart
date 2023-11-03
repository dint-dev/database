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
  group('$FieldMirror:', () {
    test('== / hashCode', () {
      final object = FieldMirror(
        name: 'name',
        jsonName: 'jsonName',
        kind: const IntKind(),
        defaultValue: 42,
      );
      final clone = FieldMirror(
        name: 'name',
        jsonName: 'jsonName',
        kind: const IntKind(),
        defaultValue: 42,
      );
      final other0 = FieldMirror(
        name: 'OTHER',
        jsonName: object.jsonName,
        kind: object.kind,
        defaultValue: object.defaultValue,
      );
      final other1 = FieldMirror(
        name: object.name,
        jsonName: 'OTHER',
        kind: object.kind,
        defaultValue: object.defaultValue,
      );
      final other2 = FieldMirror(
        name: object.name,
        jsonName: object.jsonName,
        kind: const StringKind(),
        defaultValue: object.defaultValue,
      );
      final other3 = FieldMirror(
        name: object.name,
        jsonName: object.jsonName,
        kind: object.kind,
        defaultValue: 99999,
      );

      expect(object, clone);
      expect(object, isNot(other0));
      expect(object, isNot(other1));
      expect(object, isNot(other2));
      expect(object, isNot(other3));

      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other0.hashCode));
      expect(object.hashCode, isNot(other1.hashCode));
      expect(object.hashCode, isNot(other2.hashCode));
      expect(object.hashCode, isNot(other3.hashCode));
    });

    test('toString()', () {
      expect(
        const FieldMirror(
          name: 'name',
          jsonName: 'jsonName',
          kind: IntKind(),
          defaultValue: 42,
        ).toString(),
        'FieldMirror<int>(\n'
        '  name: "name",\n'
        '  jsonName: "jsonName",\n'
        '  kind: IntKind(),\n'
        '  defaultValue: 42,\n'
        ')',
      );
    });
  });
}
