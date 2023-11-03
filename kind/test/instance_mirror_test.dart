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
  group('$InstanceMirror:', () {
    test('when instance implements Walkable', () {
      final instance = _WalkableExample(
        string: 'abc',
        nullableString: null,
      );
      final mirror = InstanceMirror.of(
        instance,
        kind: null,
      );

      expect(
        mirror.get('string'),
        'abc',
      );
      expect(
        mirror.getFieldMirror('string').kind,
        StringKind(),
      );

      expect(
        mirror.get('nullableString'),
        null,
      );
      expect(
        mirror.getFieldMirror('nullableString').kind,
        StringKind().toNullable(),
      );

      expect(
        () => mirror.get('NON-EXISTING FIELD'),
        throwsArgumentError,
      );
      expect(
        () => mirror.getFieldMirror('NON-EXISTING FIELD').kind,
        throwsArgumentError,
      );
    });
  });
}

class _WalkableExample extends Walkable {
  final String string;
  final String? nullableString;

  _WalkableExample({
    required this.string,
    required this.nullableString,
  });

  @override
  Object walk(Mapper f) {
    return _WalkableExample(
      string: f(string, 'string'),
      nullableString: f(nullableString, 'nullableString'),
    );
  }
}
