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

import 'package:datastore/adapters.dart';
import 'package:datastore/datastore.dart';
import 'package:test/test.dart';

void main() {
  group('Query:', () {
    void useItems(
        List<String> items, Query query, List<String> expected) async {
      final document =
          MemoryDatastore().collection('collectionId').document('documentId');

      final snapshots = items
          .map(
            (item) => Snapshot(document: document, data: {'x': item}),
          )
          .toList();

      //
      //  snapshotListFromIterable()
      //
      {
        final result = query
            .documentListFromIterable(snapshots)
            .map((item) => item.data['x'])
            .toList();
        expect(result, expected);
      }

      //
      // snapshotListFromIterable(), one chunk
      //
      {
        final resultSnapshots = await query
            .documentListStreamFromChunks(
              Stream<List<Snapshot>>.fromIterable([
                snapshots,
              ]),
            )
            .last;
        final result = resultSnapshots.map((s) => s.data['x']).toList();
        expect(result, expected);
      }

      //
      // snapshotListStreamFromChunkStream(), 2 chunks
      //
      {
        final resultSnapshots = await query
            .documentListStreamFromChunks(
              Stream<List<Snapshot>>.fromIterable([
                snapshots.sublist(0, 1),
                snapshots.sublist(1),
              ]),
            )
            .last;
        final result = resultSnapshots.map((s) => s.data['x']).toList();
        expect(result, expected);
      }

      //
      // snapshotListStreamFromChunkStream(), 2 chunks + 3 empty ones
      //
      {
        final resultSnapshots = await query
            .documentListStreamFromChunks(
              Stream<List<Snapshot>>.fromIterable([
                snapshots.sublist(0, 0),
                snapshots.sublist(0, 1),
                snapshots.sublist(0, 0),
                snapshots.sublist(1),
                snapshots.sublist(0, 0),
              ]),
            )
            .last;
        final result = resultSnapshots.map((s) => s.data['x']).toList();
        expect(result, expected);
      }

      //
      // snapshotListStreamFromChunkStream(), 3 chunks + 2 empty ones
      //
      if (snapshots.length >= 3) {
        final resultSnapshots = await query
            .documentListStreamFromChunks(
              Stream<List<Snapshot>>.fromIterable([
                snapshots.sublist(0, 0),
                snapshots.sublist(0, 2),
                snapshots.sublist(2, 3),
                snapshots.sublist(3),
                snapshots.sublist(0, 0),
              ]),
            )
            .last;
        final result = resultSnapshots.map((s) => s.data['x']).toList();
        expect(result, expected);
      }
    }

    test('filter (min)', () async {
      useItems(
        ['0', '1', '2', '3'],
        Query(filter: MapFilter({'x': RangeFilter(min: '1')})),
        ['1', '2', '3'],
      );
    });

    test('filter (min)', () async {
      useItems(
        ['0', '1', '2', '3'],
        Query(filter: MapFilter({'x': RangeFilter(max: '2')})),
        ['0', '1', '2'],
      );
    });

    test('filter (min, max)', () async {
      useItems(
        ['0', '1', '2', '3'],
        Query(
          filter: MapFilter({'x': RangeFilter(min: '1', max: '2')}),
        ),
        ['1', '2'],
      );
    });

    test('filter excludes "0" | no sorting | skip 1 | take 2', () async {
      useItems(
        ['0', '4', '2', '1', '3'],
        Query(
          filter: MapFilter({'x': RangeFilter(min: '1')}),
          skip: 1,
          take: 2,
        ),
        ['2', '1'],
      );
    });

    test('filter excludes "0" | normal order | skip 1 | take 2', () async {
      useItems(
        ['0', '4', '2', '1', '3'],
        Query(
          filter: MapFilter({'x': RangeFilter(min: '1')}),
          sorter: PropertySorter('x'),
          skip: 1,
          take: 2,
        ),
        ['2', '3'],
      );
    });

    test('filter excludes "0" | reverse order | skip 1', () async {
      useItems(
        ['0', '1', '2', '3', '4'],
        Query(
          filter: MapFilter({'x': RangeFilter(min: '1')}),
          sorter: PropertySorter.descending('x'),
          skip: 1,
        ),
        ['3', '2', '1'],
      );
    });

    test('filter excludes "0" | reverse order | skip 1 | take 2', () async {
      useItems(
        ['0', '4', '2', '1', '3'],
        Query(
          filter: MapFilter({'x': RangeFilter(min: '1')}),
          sorter: PropertySorter.descending('x'),
          skip: 1,
          take: 2,
        ),
        ['3', '2'],
      );
    });

    test('filter excludes "0" | reverse order | skip 1 | take 99', () async {
      useItems(
        ['0', '1', '2', '3', '4'],
        Query(
          filter: MapFilter({'x': RangeFilter(min: '1')}),
          sorter: PropertySorter.descending('x'),
          skip: 1,
          take: 99,
        ),
        ['3', '2', '1'],
      );
    });

    test('sort with normal order', () async {
      useItems(
        ['1', '0', '3', '2'],
        Query(sorter: PropertySorter('x')),
        ['0', '1', '2', '3'],
      );
    });

    test('sort with reverse order', () async {
      useItems(
        ['1', '0', '3', '2'],
        Query(sorter: PropertySorter.descending('x')),
        ['3', '2', '1', '0'],
      );
    });

    test('sort with non-existing property', () async {
      useItems(
        ['1', '0', '4', '3'],
        Query(sorter: PropertySorter.descending('other')),
        ['1', '0', '4', '3'],
      );
    });

    test('skip 1 | take 0', () async {
      useItems(
        ['0', '1', '2'],
        Query(skip: 1, take: 0),
        [],
      );
    });

    test('skip 1 | take 1', () async {
      useItems(
        ['0', '1', '2'],
        Query(skip: 1, take: 1),
        ['1'],
      );
    });

    test('skip 1 | take 2', () async {
      useItems(
        ['0', '1', '2'],
        Query(skip: 1, take: 2),
        ['1', '2'],
      );
    });

    test('skip 1 | take 99', () async {
      useItems(
        ['0', '1', '2'],
        Query(skip: 1, take: 99),
        ['1', '2'],
      );
    });

    test('skip 2', () async {
      useItems(
        ['0', '1', '2'],
        Query(skip: 2),
        ['2'],
      );
    });

    test('skip 99 | take 1', () async {
      useItems(
        ['0', '1', '2'],
        Query(skip: 99, take: 1),
        [],
      );
    });

    test('take null', () async {
      useItems(
        ['0', '1'],
        Query(take: null),
        ['0', '1'],
      );
    });

    test('take 0', () async {
      useItems(
        ['0', '1'],
        Query(take: 0),
        [],
      );
    });

    test('take 1', () async {
      useItems(
        ['0', '1'],
        Query(take: 1),
        ['0'],
      );
    });

    test('take 2', () async {
      useItems(
        ['0', '1'],
        Query(take: 2),
        ['0', '1'],
      );
    });

    test('take 99', () async {
      useItems(
        ['0', '1'],
        Query(take: 99),
        ['0', '1'],
      );
    });
  });
}
