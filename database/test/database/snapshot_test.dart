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

import 'package:database/database.dart';
import 'package:test/test.dart';

void main() {
  group('Snapshot:', () {
    test('"==" / hashCode', () async {
      final database = MemoryDatabaseAdapter().database();
      final document = database.collection('a').document('b');
      final value = Snapshot(
        document: document,
        data: {'k': 'v'},
      );
      final clone = Snapshot(
        document: document,
        data: {'k': 'v'},
      );
      final other0 = Snapshot(
        document: document,
        data: {'k': 'other'},
      );
      final other1 = Snapshot(
        document: database.collection('other').document('b'),
        data: {'k': 'v'},
      );

      expect(value, clone);
      expect(value, isNot(other0));
      expect(value, isNot(other1));

      expect(value.hashCode, clone.hashCode);
      expect(value.hashCode, isNot(other0.hashCode));
      expect(value.hashCode, isNot(other1.hashCode));
    });
  });
}
