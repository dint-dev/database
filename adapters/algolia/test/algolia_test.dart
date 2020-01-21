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
import 'package:database_adapter_algolia/database_adapter_algolia.dart';
import 'package:test/test.dart';
import 'package:test_io/test_io.dart';

// Instructions for running this test:
//
//   1.Create Algolia account
//
//   2.Create collection 'example'
//
//   3.Add indexed keys 'k0' and 'k1'
//
//   4.Create SECRETS.env with content:
//
//       export TEST_ALGOLIA_ID=your application ID
//       export TEST_ALGOLIA_SECRET=your admin key
//
void main() {
  test('basic usage', () async {
    final env = await getEnvironmentalVariables(
      includeFiles: ['../../SECRETS.env'],
    );
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
    final database = Algolia(
      appId: id,
      apiKey: secret,
    ).database();

    final collection = database.collection(
      'example',
    );

    final data0 = {
      'k0': 'v0-doc0',
      'k1': 'v1-doc0',
    };
    final data1 = {
      'k0': 'v0-doc1',
      'k1': 'v1-doc1',
    };
    final data2 = {
      'k0': 'v0-doc2',
      'k1': 'v1-doc2',
    };

    final doc0 = collection.document('doc0');
    final doc1 = collection.document('doc1');
    final doc2 = collection.document('doc2');

    await doc0.delete();
    await doc1.delete();
    await doc2.delete();

    // Wait for Algolia task to finish
    // 5 seconds should be enough
    await Future.delayed(const Duration(seconds: 5));

    addTearDown(() async {
      await doc0.delete();
      await doc1.delete();
      await doc2.delete();
    });

    //
    // Read non-existing
    //
    {
      final snapshot = await doc0.get();
      expect(snapshot.exists, false);
    }
    {
      final snapshot = await doc1.get();
      expect(snapshot.exists, false);
    }

    //
    // Updating non-existing should fail
    //
    await expectLater(
      doc0.update(data: {}),
      throwsA(isA<DatabaseException>()),
    );

    //
    // Insert
    //
    await doc0.insert(data: data0);

    //
    // Upsert
    //
    await doc1.upsert(data: data1);
    await doc2.upsert(data: data2);

    // Wait for Algolia task to finish
    // 5 seconds should be enough
    await Future.delayed(const Duration(seconds: 5));

    //
    // Read
    //
    {
      final snapshot = await doc0.get();
      expect(snapshot.document, doc0);
      expect(snapshot.exists, true);
      expect(snapshot.data, data0);
    }
    {
      final snapshot = await doc1.get();
      expect(snapshot.document, doc1);
      expect(snapshot.exists, true);
      expect(snapshot.data, data1);
    }

    //
    // Inserting existing should fail
    //
    await expectLater(
      doc0.insert(data: {}),
      throwsA(isA<DatabaseException>()),
    );

    //
    // Search
    //
    {
      final response = await collection.search();
      expect(response.snapshots, hasLength(3));
    }

    //
    // Search, skip 1
    //
    {
      final response = await collection.search(
        query: Query(
          skip: 1,
        ),
      );
      expect(response.snapshots, hasLength(2));
    }

    //
    // Search, skip 1, take 1
    //
    {
      final response = await collection.search(
        query: Query(
          skip: 1,
          take: 1,
        ),
      );
      expect(response.snapshots, hasLength(1));
    }

    //
    // Search, take 1
    //
    {
      final response = await collection.search(
        query: Query(
          take: 1,
        ),
      );
      expect(response.snapshots, hasLength(1));
    }

    // Delete
    await doc0.delete(mustExist: true);

    // Wait for Algolia task to finish
    // 5 seconds should be enough
    await Future.delayed(const Duration(seconds: 5));

    // Read non-existing
    {
      final snapshot = await doc0.get();
      expect(snapshot.exists, false);
    }

    // Read existing
    {
      final snapshot = await doc1.get();
      expect(snapshot.exists, true);
    }
  });
}
