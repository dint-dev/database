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

import 'package:database/database.dart';
import 'package:database_adapter_algolia/database_adapter_algolia.dart';
import 'package:test/test.dart';
import 'package:test_io/test_io.dart';

void main() {
  setUpAll(() {});
  test('basic usage', () async {
    final env = await getEnvironmentalVariables();
    const idEnv = 'TEST_ALGOLIA_ID';
    const secretEnv = 'TEST_ALGOLIA_SECRET';
    final id = env[idEnv] ?? '';
    final secret = env[secretEnv] ?? '';
    if (id == '' || secret == '') {
      print(
        'SKIPPING: Algolia: environmental variables $idEnv / $secretEnv are undefined.',
      );
      return;
    }
    Database.defaultInstance = Algolia(
      credentials: AlgoliaCredentials(
        appId: id,
        apiKey: secret,
      ),
    );

    final collection = Database.defaultInstance.collection(
      'exampleCollection',
    );
    addTearDown(() async {
      await collection.searchAndDelete();
    });
    final document = collection.document('exampleDocument');

    // Read non-existing
    {
      final snapshot = await document.get();
      expect(snapshot, isNull);
    }

    // Insert
    await document.insert(data: {
      'k0': 'v0',
      'k1': 'v1',
    });

    // Read
    {
      final snapshot = await document.get();
      expect(snapshot.data, {
        'k0': 'v0',
        'k1': 'v1',
      });
    }

    // Search
    {
      final response = await collection.search();
      expect(response.snapshots, hasLength(1));
    }

    // Delete
    await document.deleteIfExists();

    // Read non-existing
    {
      final snapshot = await document.get();
      expect(snapshot, isNull);
    }
  });
}
