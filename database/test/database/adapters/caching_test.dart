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

import '../../database_adapter_tester.dart';

void main() {
  group('CachingDatabaseAdapter', () {
    DatabaseAdapterTester(
      () => CachingDatabaseAdapter(
        master: MemoryDatabaseAdapter(),
        cache: MemoryDatabaseAdapter(),
      ).database(),

      // This is a cache
      isCache: true,

      // Zero delay
      writeDelay: const Duration(),
    ).run();

    test('A simple caching test', () async {
      final master = MemoryDatabaseAdapter(
        latency: const Duration(milliseconds: 1),
      );
      final cache = MemoryDatabaseAdapter();
      final adapter = CachingDatabaseAdapter(
        master: master,
        cache: cache,
      );
      expect(adapter.master, same(master));
      expect(adapter.cache, same(cache));

      final collection = adapter.database().collection('example');
      expect(collection.database.adapter, same(adapter));
      final doc0 = collection.document('doc0');
      final doc1 = collection.document('doc1');

      //
      // Write
      //
      expect(master.length, 0);
      await doc0.upsert(data: {'k': 'v0'});
      expect(master.length, 1);
      await doc1.upsert(data: {'k': 'v1'});
      expect(master.length, 2);
      expect(cache.length, 0);

      //
      // Read
      //
      {
        expect(master.length, 2);
        expect(cache.length, 0);
        expect(
          await doc0.getIncrementally().toList(),
          [
            Snapshot(document: doc0, data: {'k': 'v0'}),
          ],
        );
        expect(master.length, 2);
        expect(cache.length, 1);
        expect(
          await doc0.getIncrementally().toList(),
          [
            Snapshot(document: doc0, data: {'k': 'v0'}),
            Snapshot(document: doc0, data: {'k': 'v0'}),
          ],
        );
        expect(master.length, 2);
        expect(cache.length, 1);
      }

      //
      // Search
      //
      {
        final actualResponses = await collection.searchIncrementally().toList();

        // We should receive the result twice
        expect(
          actualResponses,
          [
            QueryResult(
              collection: collection,
              query: const Query(),
              snapshots: [
                Snapshot(
                  document: doc0,
                  data: {'k': 'v0'},
                ),
              ],
            ),
            QueryResult(
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
            ),
          ],
        );
      }
    });
  });
}
