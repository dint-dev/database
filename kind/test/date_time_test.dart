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
import 'package:os/os.dart';
import 'package:test/test.dart';

void main() {
  group('$DateTimeKind:', () {
    final kind = Kind.forDateTime;

    test('== / hashCode', () {
      final object = kind;
      final clone = DateTimeKind.utc();
      final other = Kind.forInt;

      // a == b
      expect(object, clone);
      expect(object, isNot(other));

      // a.hashCode
      expect(object.hashCode, clone.hashCode);
      expect(object.hashCode, isNot(other.hashCode));
    });

    test('name', () {
      expect(kind.name, 'DateTime');
    });

    test('debugString(instance)', () {
      expect(
        const DateTimeKind.local().debugString(DateTimeKind.epoch),
        startsWith('DateTime('),
      );
      expect(
        kind.debugString(DateTimeKind.epoch),
        'DateTime.utc(1970, 1, 1)',
      );
      expect(
        kind.debugString(
          DateTimeKind.epoch.add(const Duration(seconds: 1)),
        ),
        'DateTime.utc(1970, 1, 1, 0, 0, 1)',
      );
      expect(
        kind.debugString(
          DateTimeKind.epoch.add(const Duration(milliseconds: 1)),
        ),
        'DateTime.utc(1970, 1, 1, 0, 0, 0, 1)',
      );
      if (isRunningInJs) {
        expect(
          kind.debugString(
            DateTimeKind.epoch.add(const Duration(microseconds: 1)),
          ),
          'DateTime.utc(1970, 1, 1)',
        );
      } else {
        expect(
          kind.debugString(
            DateTimeKind.epoch.add(const Duration(microseconds: 1)),
          ),
          'DateTime.utc(1970, 1, 1, 0, 0, 0, 0, 1)',
        );
      }
    });

    test('newInstance()', () {
      expect(kind.newInstance(), DateTimeKind.epoch);
    });

    group('json:', () {
      test('epoch', () {
        final value = DateTimeKind.epoch;
        final json = '1970-01-01T00:00:00.000Z';
        // Encode
        expect(kind.encodeJsonTree(value), json);
        // Decode
        expect(kind.decodeJsonTree(json), value);
      });

      test('epoch (local)', () {
        final kind = DateTimeKind.local(encodeUtc: false);
        final value = DateTimeKind.epoch.toLocal();
        final jsonWhenUtc = '1970-01-01T00:00:00.000Z';

        // Encode
        expect(
          kind.encodeJsonTree(value.toLocal()),
          kind.encodeJsonTree(value.toUtc()),
        );
        if (value.toUtc() == value) {
          expect(kind.encodeJsonTree(value), jsonWhenUtc);
        } else {
          expect(kind.encodeJsonTree(value), isNot(jsonWhenUtc));
        }

        // Decode
        expect(kind.decodeJsonTree(kind.encodeJsonTree(value)), value);
      });
    });
  });
}
