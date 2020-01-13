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

import 'dart:async';

import 'package:database/database.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

class DatabaseTestSuite {
  @protected
  final bool isCaching;
  final bool supportsTransactions;
  final Duration writeDelay;
  final FutureOr<Database> Function() database;

  DatabaseTestSuite(
    this.database, {
    this.isCaching = false,
    this.writeDelay = const Duration(),
    this.supportsTransactions = false,
  });

  void run() {
    Database database;
    Collection collection;
    Document document0;
    Document document1;
    Document document2;

    setUpAll(() async {
      database = await this.database();
    });

    setUp(() async {
      if (database == null) {
        return;
      }
      collection = database.collection('exampleCollection');
      document0 = collection.document('example0');
      document1 = collection.document('example1');
      document2 = collection.document('example2');

      await document0.deleteIfExists();
      await document1.deleteIfExists();
      await document2.deleteIfExists();
      await collection.searchAndDelete();
      await _waitAfterWrite();
    });

    tearDown(() async {
      if (database == null) {
        return;
      }
      await document0.deleteIfExists();
      await document1.deleteIfExists();
      await document2.deleteIfExists();
      await _waitAfterWrite();
    });

    group('Collection:', () {
      group('search:', () {
        test('ok (no results)', () async {
          if (database == null) {
            return;
          }

          // Search
          final result = await collection.search();
          expect(result.collection, same(collection));
          expect(result.query, const Query());
          expect(result.snapshots, isEmpty);
          expect(result.items, isEmpty);
          expect(result.count, anyOf(isNull, 0));
        });

        test('ok (3 documents)', () async {
          if (database == null) {
            return;
          }

          final data0 = {'k': 'value0'};
          final data1 = {'k': 'value1'};
          final data2 = {'k': 'value1'};

          // Insert
          await document0.insert(data: data0);
          await document1.insert(data: data1);
          await document2.insert(data: data2);
          await _waitAfterWrite();

          // Search
          final result = await collection.search();

          expect(result.collection, same(collection));
          expect(result.query, const Query());
          expect(result.count, anyOf(isNull, 3));

          //
          // Snapshots
          //
          final snapshots = result.snapshots.toList();
          snapshots.sort(
            (a, b) => a.document.documentId.compareTo(b.document.documentId),
          );
          expect(snapshots, hasLength(3));

          // Document 0
          expect(snapshots[0].document, document0);
          expect(snapshots[0].exists, isTrue);
          expect(snapshots[0].data, data0);

          // Document 1
          expect(snapshots[1].document, document1);
          expect(snapshots[1].exists, isTrue);
          expect(snapshots[1].data, data1);

          // Document 2
          expect(snapshots[2].document, document2);
          expect(snapshots[2].exists, isTrue);
          expect(snapshots[2].data, data2);

          //
          // Detailed items
          //
          final items = result.items.toList();
          items.sort(
            (a, b) => a.document.documentId.compareTo(b.document.documentId),
          );
          expect(items, hasLength(3));

          // Document 0
          expect(items[0].document, document0);
          expect(items[0].snapshot.exists, isTrue);
          expect(items[0].data, data0);

          // Document 1
          expect(items[1].document, document1);
          expect(items[1].snapshot.exists, isTrue);
          expect(items[1].data, data1);

          // Document 2
          expect(items[2].document, document2);
          expect(items[2].snapshot.exists, isTrue);
          expect(items[2].data, data2);
        });
      });

      group('searchIncrementally:', () {
        test('ok (no documents)', () async {
          if (database == null) {
            return;
          }

          final results = await collection.searchIncrementally().toList();
          expect(results, hasLength(greaterThan(0)));
          for (var result in results) {
            expect(result.collection, same(collection));
          }
          expect(results.last.snapshots, isEmpty);
          expect(results.last.items, isEmpty);
          expect(results.last.count, anyOf(isNull, 0));
        });

        test('ok (3 documents)', () async {
          if (database == null) {
            return;
          }

          final data0 = {'k': 'value0'};
          final data1 = {'k': 'value1'};
          final data2 = {'k': 'value1'};

          // Insert
          await document0.insert(data: data0);
          await document1.insert(data: data1);
          await document2.insert(data: data2);
          await _waitAfterWrite();

          // Search
          final result = await collection.searchIncrementally().last;

          expect(result.collection, same(collection));
          expect(result.query, const Query());
          expect(result.count, anyOf(isNull, 3));

          //
          // Snapshots
          //
          final snapshots = result.snapshots.toList();
          snapshots.sort(
            (a, b) => a.document.documentId.compareTo(b.document.documentId),
          );

          // Length
          expect(snapshots, hasLength(3));

          // Document 0
          expect(snapshots[0].document, document0);
          expect(snapshots[0].exists, isTrue);
          expect(snapshots[0].data, data0);

          // Document 1
          expect(snapshots[1].document, document1);
          expect(snapshots[1].exists, isTrue);
          expect(snapshots[1].data, data1);

          // Document 2
          expect(snapshots[2].document, document2);
          expect(snapshots[2].exists, isTrue);
          expect(snapshots[2].data, data2);

          //
          // Detailed items
          //
          final items = result.items.toList();
          items.sort(
            (a, b) => a.document.documentId.compareTo(b.document.documentId),
          );

          // Length
          expect(items, hasLength(3));

          // Document 0
          expect(items[0].document, document0);
          expect(items[0].snapshot.exists, isTrue);
          expect(items[0].data, data0);

          // Document 1
          expect(items[1].document, document1);
          expect(items[1].snapshot.exists, isTrue);
          expect(items[1].data, data1);

          // Document 2
          expect(items[2].document, document2);
          expect(items[2].snapshot.exists, isTrue);
          expect(items[2].data, data2);
        });
      });

      group('searchChunked:', () {
        test('ok (no documents', () async {
          if (database == null) {
            return;
          }

          final chunks = await collection.searchChunked().toList();
          expect(chunks, hasLength(1));
          expect(chunks[0].snapshots, isEmpty);
          expect(chunks[0].items, isEmpty);
          expect(chunks[0].count, anyOf(isNull, 0));
        });

        test('ok (3 documents)', () async {
          if (database == null) {
            return;
          }

          final data0 = {'k': 'value0'};
          final data1 = {'k': 'value1'};
          final data2 = {'k': 'value1'};

          // Insert
          await document0.insert(data: data0);
          await document1.insert(data: data1);
          await document2.insert(data: data2);
          await _waitAfterWrite();

          // Search
          var result = await collection
              .searchChunked()
              .map((q) => q.snapshots)
              .reduce((a, b) => [...a, ...b]);

          // Make mutable list
          result = result.toList();

          // Sort
          result.sort(
            (a, b) => a.document.documentId.compareTo(b.document.documentId),
          );

          // Length
          expect(result, hasLength(3));

          // Document 0
          expect(result[0].document, document0);
          expect(result[0].exists, isTrue);
          expect(result[0].data, data0);

          // Document 1
          expect(result[1].document, document1);
          expect(result[1].exists, isTrue);
          expect(result[1].data, data1);

          // Document 2
          expect(result[2].document, document2);
          expect(result[2].exists, isTrue);
          expect(result[2].data, data2);
        });
      });
    });

    group('Document:', () {
      group('get() / getIncrementally():', () {
        test('ok', () async {
          if (database == null) {
            return;
          }

          // Upsert
          final data = {'k0': 'v0', 'k1': 'v1'};
          await document0.upsert(data: data);
          await _waitAfterWrite();

          // Get
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, data);

          // Get incrementally
          final list = await document0.getIncrementalStream().toList();
          expect(list, isNotEmpty);
          expect(list.last.document, same(document0));
          expect(list.last.exists, isTrue);
          expect(list.last.data, data);
        });

        test('not found', () async {
          if (database == null) {
            return;
          }

          // Get
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);

          // Get incrementally
          final list = await document0.getIncrementalStream().toList();
          expect(list, isNotEmpty);
          expect(list.last.document, same(document0));
          expect(list.last.exists, isFalse);
          expect(list.last.data, isNull);
        });
      });

      group('insert():', () {
        test('ok', () async {
          if (database == null) {
            return;
          }

          // Insert
          await document0.insert(data: {'k0': 'v0', 'k1': 'v1'});
          await _waitAfterWrite();

          // Get
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'k0': 'v0', 'k1': 'v1'});
        });

        test('document exists, throws DatabaseException', () async {
          if (database == null) {
            return;
          }

          // Insert
          await document0.insert(data: {'k0': 'v0', 'k1': 'v1'});
          await _waitAfterWrite();

          // Insert again
          await expectLater(
            document0.insert(data: {}),
            throwsA(isA<DatabaseException>()),
          );
        });

        group('different values:', () {
          test('null', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': null,
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value': null,
            });
          });

          test('bool', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value0': false,
              'value1': true,
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value0': false,
              'value1': true,
            });
          });

          test('Int64', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value0': Int64(-2),
              'value1': Int64(2),
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value0': Int64(-2),
              'value1': Int64(2),
            });
          });

          test('int', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': 3,
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value': 3,
            });
          });

          test('double', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': 3.14,
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value': 3.14,
            });
          });

          test('DateTime', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value': DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            });
          });

          test('GeoPoint', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': GeoPoint(1.0, 2.0),
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {'value': GeoPoint(1.0, 2.0)});
          });

          test('String', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value0': '',
              'value1': 'abc',
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value0': '',
              'value1': 'abc',
            });
          });

          test('List', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': ['a', 'b', 'c']
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value': ['a', 'b', 'c']
            });
          });

          test('Map', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': {'k0': 'v0', 'k1': 'v1'},
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value': {'k0': 'v0', 'k1': 'v1'},
            });
          });

          test('Document', () async {
            if (database == null) {
              return;
            }

            // Insert
            await document0.insert(data: {
              'value': document0,
            });
            await _waitAfterWrite();

            // Get
            final snapshot = await document0.get();
            expect(snapshot.data, {
              'value': document0,
            });
          });
        });
      });

      group('upsert():', () {
        test('ok (exists)', () async {
          if (database == null) {
            return;
          }

          // Upsert
          await document0.upsert(data: {
            'old': 'value',
          });
          await _waitAfterWrite();

          // Upsert again
          await document0.upsert(data: {
            'new': 'value',
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'new': 'value'});
        });

        test('ok (does not exist)', () async {
          if (database == null) {
            return;
          }

          // Upsert
          await document0.upsert(data: {
            'new': 'value',
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'new': 'value'});
        });
      });

      group('update():', () {
        test('ok', () async {
          if (database == null) {
            return;
          }

          // Upsert an existing document
          await document0.upsert(data: {'old': 'value'});
          expect((await document0.get()).data, {'old': 'value'});
          await _waitAfterWrite();

          // Update
          await document0.update(data: {'new': 'value'});
          await _waitAfterWrite();

          // Get
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isTrue);
          expect(snapshot.data, {'new': 'value'});
        });

        test('document does not exist, throws DatabaseException', () async {
          if (database == null) {
            return;
          }

          // Update
          await expectLater(
            document0.update(data: {'new': 'value'}),
            throwsA(isA<DatabaseException>()),
          );
        });
      });

      group('delete():', () {
        test('ok', () async {
          if (database == null) {
            return;
          }

          // Insert
          await document0.insert(data: {'old': 'value'});
          await _waitAfterWrite();

          // Delete
          await document0.delete();
          await _waitAfterWrite();

          // Get
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);
        });

        test('non-existing, throws DatabaseException', () async {
          if (database == null) {
            return;
          }

          // Delete
          await expectLater(
            document0.delete(),
            throwsA(isA<DatabaseException>()),
          );
        });

        test('repeat twice, throws DatabaseException', () async {
          if (database == null) {
            return;
          }

          // Insert
          await document0.insert(data: {'old': 'value'});
          await _waitAfterWrite();

          // Delete
          await document0.delete();
          await _waitAfterWrite();

          // Delete again
          await expectLater(
            document0.delete(),
            throwsA(isA<DatabaseException>()),
          );
        });
      });

      group('deleteIfExists():', () {
        test('existing', () async {
          if (database == null) {
            return;
          }

          // Delete
          await document0.deleteIfExists();
          await _waitAfterWrite();

          // Read
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);
        });

        test('non-existing', () async {
          if (database == null) {
            return;
          }

          // Delete
          await document0.deleteIfExists();
          await _waitAfterWrite();

          // Delete
          await document0.deleteIfExists();
          await _waitAfterWrite();

          // Read
          final snapshot = await document0.get();
          expect(snapshot.document, same(document0));
          expect(snapshot.exists, isFalse);
          expect(snapshot.data, isNull);
        });
      });

      group('newWriteBatch', () {
        test('upsert', () async {
          if (database == null) {
            return;
          }

          final batch = database.newWriteBatch();
          batch.upsert(document0, data: {'k': 'value0'});
          batch.upsert(document1, data: {'k': 'value1'});
          await _waitAfterWrite();

          // Check that the writes are not committed
          expect((await document0.get()).exists, isFalse);
          expect((await document1.get()).exists, isFalse);

          // Commit
          await batch.commit();
          await _waitAfterWrite();

          // Check that the commit succeeded
          expect((await document0.get()).exists, isTrue);
          expect((await document1.get()).exists, isTrue);
        });
      });

      if (supportsTransactions) {
        group('transactions:', () {
          test('simple', () async {
            if (database == null) {
              return;
            }

            await database.runInTransaction(callback: (transaction) async {
              // Read
              {
                final snapshot = await transaction.get(document0);
                expect(snapshot.exists, isFalse);
              }

              // Write
              await transaction.insert(document0, data: {'k': 'value0'});
              await transaction.upsert(document1, data: {'k': 'value1'});
              await transaction.deleteIfExists(document2);
              await _waitAfterWrite();

              // May be visible to the transaction
              {
                final snapshot = await transaction.get(document0);
                expect(snapshot.exists, anyOf(isFalse, isTrue));
              }

              // Check that the writes are not committed
              expect((await document0.get()).exists, isFalse);
              expect((await document1.get()).exists, isFalse);
            });

            // Check that the commit succeeded
            expect((await document0.get()).exists, isTrue);
            expect((await document1.get()).exists, isTrue);
            expect((await document2.get()).exists, isFalse);
          });
        });
      }
    });
  }

  Future<void> _waitAfterWrite() {
    return Future<void>.delayed(writeDelay);
  }
}
