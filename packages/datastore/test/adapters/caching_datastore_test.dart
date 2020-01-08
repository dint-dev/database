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

@TestOn('vm')
library _;

import 'package:datastore/adapters.dart';
import 'package:datastore/datastore.dart';
import 'package:test/test.dart';

import '../datastore_test_suite.dart';

void main() {
  group('Standard test suite', () {
    DatastoreTestSuite(
      () => CachingDatastore(
        master: MemoryDatastore(),
        cache: MemoryDatastore(),
      ),
      isCaching: true,
    ).run();
  });
  test('A simple caching test', () async {
    final searchService = CachingDatastore(
      master: MemoryDatastore(latency: const Duration(milliseconds: 1)),
      cache: MemoryDatastore(),
    );

    final collection = searchService.collection('example');
    final doc0 = collection.document('doc0');
    final doc1 = collection.document('doc1');

    //
    // Write
    //
    await doc0.upsert(data: {'k': 'v0'});
    await doc1.upsert(data: {'k': 'v1'});

    //
    // Read
    //
    {
      expect(
        await doc0.getIncrementalStream().toList(),
        [
          Snapshot(document: doc0, data: {'k': 'v0'}),
          Snapshot(document: doc0, data: {'k': 'v0'}),
        ],
      );
    }

    //
    // Search
    //
    {
      final expectedResponse = QueryResult(
        collection: collection,
        query: const Query(),
        snapshots: [
          Snapshot(
            document: doc0,
            data: {'k': 'v0'},
          ),
          Snapshot(
            document: doc1,
            data: {'k': 'v1'},
          ),
        ],
      );

      final actualResponses = await collection.searchIncrementally().toList();

      // We should receive the result twice
      expect(
        actualResponses,
        [
          expectedResponse,
          expectedResponse,
        ],
      );
    }
  });
}
