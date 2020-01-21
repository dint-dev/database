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
import 'package:database/schema.dart';
import 'package:test/test.dart';

void main() {
  test('SchemaEnforcingDatabaseAdapter', () async {
    final adapter = SchemaEnforcingDatabaseAdapter(
      adapter: MemoryDatabaseAdapter(),
      databaseSchema: DatabaseSchema(
        schemasByCollection: {
          'product': MapSchema({
            'name': StringSchema(),
          }),
        },
      ),
    );
    final collection = adapter.database().collection('product');
    await collection.insert(data: {
      'name': 'example',
    });
    await expectLater(
      collection.insert(data: {
        'name': 3.14,
      }),
      throwsArgumentError,
    );
  });
}
