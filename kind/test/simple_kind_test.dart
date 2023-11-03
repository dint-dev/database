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
  group('$SimpleKind:', () {
    test('== / hashCode', () {
      final intKind = IntKind();
      final object = SimpleKind(kind: intKind);
      final clone = SimpleKind(kind: intKind);
      final other0 = const SimpleKind(kind: StringKind());
      final other1 = intKind;
      expect(object, clone);
      expect(object, isNot(other0));
      expect(object, isNot(other1));

      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other0.hashCode));
      expect(object.hashCode, isNot(other1.hashCode));
    });
    test('toString', () {
      final intKind = IntKind(min: 0, max: 100);
      final kind = SimpleKind(kind: intKind);
      expect(kind.toString(), intKind.toString());
    });
    test('name', () {
      final kind = SimpleKind(
        kind: IntKind(),
        name: 'MyInt',
      );
      expect(kind.name, 'MyInt');
    });
    test('jsonName', () {
      final kind = SimpleKind(
        kind: IntKind(),
        jsonName: 'MyInt',
      );
      expect(kind.jsonName, 'MyInt');
    });
    test('fromJson', () {
      final kind = SimpleKind(
        kind: IntKind(),
        fromJson: (json) => 123,
      );
      expect(kind.decodeJsonTree(0), 123);
    });
    test('toJson', () {
      final kind = SimpleKind(
        kind: IntKind(),
        toJson: (value) => 123,
      );
      expect(kind.encodeJsonTree(0), 123);
    });
  });
}
