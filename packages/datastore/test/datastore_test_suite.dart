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

import 'package:datastore/datastore.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

class DatastoreTestSuite {
  @protected
  final bool isCaching;

  Datastore datastore;

  DatastoreTestSuite(this.datastore, {this.isCaching = false});

  void run() {
    Collection collection;
    Document document;
    setUp(() async {
      assert(datastore != null);
      collection = datastore.collection('exampleCollection');
      document = collection.document('exampleDocument');
    });

    group('Collection:', () {
      group('search:', () {
        test('ok', () async {
          // Delete existing documents
          await collection.searchAndDelete();

          // Insert
          await document.insert(data: {'k0': 'v0', 'k1': 'v1'});

          // Get
          final snapshot = await document.get();
          expect(snapshot, isNotNull);

          // Search
          final result = await collection.search();
          expect(result.collection, same(collection));
          expect(result.query, isNotNull);
          expect(result.snapshots, [snapshot]);
        });
      });

      group('searchIncrementally:', () {
        test('ok', () async {
          // Delete existing documents
          await collection.searchAndDelete();

          // Insert
          await document.insert(data: {'k0': 'v0', 'k1': 'v1'});

          // Get
          final snapshot = await document.get();
          expect(snapshot, isNotNull);

          // Search
          final results = await collection.searchIncrementally().toList();
          expect(results, hasLength(1));
          final result = results.single;
          expect(result.collection, same(collection));
          expect(result.query, isNotNull);
          expect(result.snapshots, [snapshot]);
        });
      });

      group('searchChunked:', () {
        test('ok', () async {
          // Delete existing documents
          await collection.searchAndDelete();

          // Insert
          await document.insert(data: {'k0': 'v0', 'k1': 'v1'});

          // Get
          final snapshot = await document.get();
          expect(snapshot, isNotNull);

          // Search
          final results = await collection.searchChunked().toList();
          expect(results, hasLength(1));
          final result = results.single;
          expect(result.collection, same(collection));
          expect(result.query, isNotNull);
          expect(result.snapshots, [snapshot]);
        });
      });
    });

    group('Document:', () {
      group('get() / getIncrementally():', () {
        test('ok', () async {
          // Upsert
          final data = {'k0': 'v0', 'k1': 'v1'};
          await document.upsert(data: data);

          // Get
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, data);

          // Get incrementally
          final list = await document.getIncrementalStream().toList();
          expect(list, isNotEmpty);
          expect(list.last.document, same(document));
          expect(list.last.exists, isTrue);
          expect(list.last.data, data);
        });

        test('not found', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Get
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);

          // Get incrementally
          final list = await document.getIncrementalStream().toList();
          expect(list, isNotEmpty);
          expect(list.last.document, same(document));
          expect(list.last.exists, isFalse);
          expect(list.last.data, isNull);
        });
      });

      group('insert():', () {
        test('ok', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Insert
          await document.insert(data: {'k0': 'v0', 'k1': 'v1'});

          // Get
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'k0': 'v0', 'k1': 'v1'});
        });

        test('document exists, throws DatastoreException', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Insert
          await document.insert(data: {'k0': 'v0', 'k1': 'v1'});

          // Insert again
          await expectLater(
            document.insert(data: {}),
            throwsA(isA<DatastoreException>()),
          );
        });

        group('different values:', () {
          setUp(() async {
            // Delete possible existing document
            await document.deleteIfExists();
            expect((await document.get()).exists, isFalse);
          });

          test('null', () async {
            // Insert
            await document.insert(data: {
              'value': null,
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value': null,
            });
          });

          test('bool', () async {
            // Insert
            await document.insert(data: {
              'value0': false,
              'value1': true,
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value0': false,
              'value1': true,
            });
          });

          test('Int64', () async {
            // Insert
            await document.insert(data: {
              'value0': Int64(-2),
              'value1': Int64(2),
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value0': Int64(-2),
              'value1': Int64(2),
            });
          });

          test('int', () async {
            // Insert
            await document.insert(data: {
              'value': 3,
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value': 3,
            });
          });

          test('double', () async {
            // Insert
            await document.insert(data: {
              'value': 3.14,
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value': 3.14,
            });
          });

          test('DateTime', () async {
            // Insert
            await document.insert(data: {
              'value': DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value': DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            });
          });

          test('GeoPoint', () async {
            // Insert
            await document.insert(data: {
              'value': GeoPoint(1.0, 2.0),
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {'value': GeoPoint(1.0, 2.0)});
          });

          test('String', () async {
            // Insert
            await document.insert(data: {
              'value0': '',
              'value1': 'abc',
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value0': '',
              'value1': 'abc',
            });
          });

          test('List', () async {
            // Insert
            await document.insert(data: {
              'value': ['a', 'b', 'c']
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value': ['a', 'b', 'c']
            });
          });

          test('Map', () async {
            // Insert
            await document.insert(data: {
              'value': {'k0': 'v0', 'k1': 'v1'},
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value': {'k0': 'v0', 'k1': 'v1'},
            });
          });

          test('Document', () async {
            // Insert
            await document.insert(data: {
              'value': document,
            });

            // Get
            final snapshot = await document.get();
            expect(snapshot.data, {
              'value': document,
            });
          });
        });
      });

      group('upsert():', () {
        test('ok (exists)', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Upsert
          await document.upsert(data: {
            'old': 'value',
          });

          // Upsert again
          await document.upsert(data: {
            'new': 'value',
          });

          // Get
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'new': 'value'});
        });

        test('ok (does not exist)', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Upsert
          await document.upsert(data: {
            'new': 'value',
          });

          // Get
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'new': 'value'});
        });
      });

      group('update():', () {
        test('ok', () async {
          // Upsert an existing document
          await document.upsert(data: {'old': 'value'});
          expect((await document.get()).data, {'old': 'value'});

          // Update
          await document.update(data: {'new': 'value'});

          // Get
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'new': 'value'});
        });

        test('document does not exist, throws DatastoreException', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Update
          await expectLater(
            document.update(data: {'new': 'value'}),
            throwsA(isA<DatastoreException>()),
          );
        });
      });

      group('delete():', () {
        test('ok', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Insert
          await document.insert(data: {'old': 'value'});

          // Delete
          await document.delete();

          // Get
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);
        });

        test('non-existing, throws DatastoreException', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Delete
          await expectLater(
            document.delete(),
            throwsA(isA<DatastoreException>()),
          );
        });

        test('repeat twice, throws DatastoreException', () async {
          // Delete possible existing document
          await document.deleteIfExists();
          expect((await document.get()).exists, isFalse);

          // Insert
          await document.insert(data: {'old': 'value'});

          // Delete
          await document.delete();

          // Delete again
          await expectLater(
            document.delete(),
            throwsA(isA<DatastoreException>()),
          );
        });
      });

      group('deleteIfExists():', () {
        test('existing', () async {
          // Delete
          await document.deleteIfExists();

          // Read
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);
        });

        test('non-existing', () async {
          // Delete
          await document.deleteIfExists();

          // Delete
          await document.deleteIfExists();

          // Read
          final snapshot = await document.get();
          expect(snapshot.document, same(document));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);
        });
      });
    });
  }
}
