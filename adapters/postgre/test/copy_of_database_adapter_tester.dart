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

import 'dart:async';

import 'package:database/database.dart';
import 'package:database/schema.dart';
import 'package:test/test.dart';

void runCollectionAndDocumentTests() {
  Database database;
  Collection collection;
  final inserted = <Document>[];

  Future<Document> insert({Map<String, Object> data}) async {
    final document = await collection.insert(data: data);
    inserted.add(document);
    return document;
  }

  setUpAll(() async {
    database = await DatabaseAdapterTester.current.databaseBuilder();
  });

  setUp(() async {
    if (database == null) {
      return;
    }
    collection = database.collection('exampleCollection');
    await collection.searchAndDelete();
    await _waitAfterWrite();

    addTearDown(() async {
      for (var document in inserted) {
        await document.delete();
      }
      inserted.clear();
      await _waitAfterWrite();
    });
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

        final data0 = {'string': 'value0'};
        final data1 = {'string': 'value1'};
        final data2 = {'string': 'value1'};

        // Insert
        final document0 = await insert(data: data0);
        final document1 = await insert(data: data1);
        final document2 = await insert(data: data2);
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
        expect(snapshots, hasLength(3));

        // Sort documents
        final documents = <Document, Object>{
          document0: data0,
          document1: data1,
          document2: data2,
        }.entries.toList();
        documents.sort((a, b) => a.key.documentId.compareTo(b.key.documentId));

        // Sort snapshots
        snapshots.sort(
          (a, b) => a.document.documentId.compareTo(b.document.documentId),
        );

        // Document 0
        expect(snapshots[0].document, documents[0].key);
        expect(snapshots[0].exists, isTrue);
        expect(snapshots[0].data, documents[0].value);

        // Document 1
        expect(snapshots[1].document, documents[1].key);
        expect(snapshots[1].exists, isTrue);
        expect(snapshots[1].data, documents[1].value);

        // Document 2
        expect(snapshots[2].document, documents[2].key);
        expect(snapshots[2].exists, isTrue);
        expect(snapshots[2].data, documents[2].value);

        //
        // Detailed items
        //
        final items = result.items.toList();
        items.sort(
          (a, b) => a.document.documentId.compareTo(b.document.documentId),
        );
        expect(items, hasLength(3));

        // Document 0
        expect(items[0].document, documents[0].key);
        expect(items[0].snapshot.exists, isTrue);
        expect(items[0].data, documents[0].value);

        // Document 1
        expect(items[1].document, documents[1].key);
        expect(items[1].snapshot.exists, isTrue);
        expect(items[1].data, documents[1].value);

        // Document 2
        expect(items[2].document, documents[2].key);
        expect(items[2].snapshot.exists, isTrue);
        expect(items[2].data, documents[2].value);
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

        final data0 = {'string': 'value0'};
        final data1 = {'string': 'value1'};
        final data2 = {'string': 'value1'};

        // Insert
        final document0 = await insert(data: data0);
        final document1 = await insert(data: data1);
        final document2 = await insert(data: data2);
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

        // Length
        expect(snapshots, hasLength(3));

        // Sort documents
        final documents = <Document, Object>{
          document0: data0,
          document1: data1,
          document2: data2,
        }.entries.toList();
        documents.sort((a, b) => a.key.documentId.compareTo(b.key.documentId));

        // Sort snapshots
        snapshots.sort(
          (a, b) => a.document.documentId.compareTo(b.document.documentId),
        );

        // Document 0
        expect(snapshots[0].document, documents[0].key);
        expect(snapshots[0].exists, isTrue);
        expect(snapshots[0].data, documents[0].value);

        // Document 1
        expect(snapshots[1].document, documents[1].key);
        expect(snapshots[1].exists, isTrue);
        expect(snapshots[1].data, documents[1].value);

        // Document 2
        expect(snapshots[2].document, documents[2].key);
        expect(snapshots[2].exists, isTrue);
        expect(snapshots[2].data, documents[2].value);

        //
        // Detailed items
        //
        final items = result.items.toList();
        items.sort(
          (a, b) => a.document.documentId.compareTo(b.document.documentId),
        );
        expect(items, hasLength(3));

        // Document 0
        expect(items[0].document, documents[0].key);
        expect(items[0].snapshot.exists, isTrue);
        expect(items[0].data, documents[0].value);

        // Document 1
        expect(items[1].document, documents[1].key);
        expect(items[1].snapshot.exists, isTrue);
        expect(items[1].data, documents[1].value);

        // Document 2
        expect(items[2].document, documents[2].key);
        expect(items[2].snapshot.exists, isTrue);
        expect(items[2].data, documents[2].value);
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

        final data0 = {'string': 'value0'};
        final data1 = {'string': 'value1'};
        final data2 = {'string': 'value1'};

        // Insert
        final document0 = await insert(data: data0);
        final document1 = await insert(data: data1);
        final document2 = await insert(data: data2);
        await _waitAfterWrite();

        // Search
        var snapshots = await collection
            .searchChunked()
            .map((q) => q.snapshots)
            .reduce((a, b) => [...a, ...b]);

        // Make mutable list
        snapshots = snapshots.toList();

        // Length
        expect(snapshots, hasLength(3));

        // Sort documents
        final documents = <Document, Object>{
          document0: data0,
          document1: data1,
          document2: data2,
        }.entries.toList();
        documents.sort((a, b) => a.key.documentId.compareTo(b.key.documentId));

        // Sort snapshots
        snapshots.sort(
          (a, b) => a.document.documentId.compareTo(b.document.documentId),
        );

        // Document 0
        expect(snapshots[0].document, documents[0].key);
        expect(snapshots[0].exists, isTrue);
        expect(snapshots[0].data, documents[0].value);

        // Document 1
        expect(snapshots[1].document, documents[1].key);
        expect(snapshots[1].exists, isTrue);
        expect(snapshots[1].data, documents[1].value);

        // Document 2
        expect(snapshots[2].document, documents[2].key);
        expect(snapshots[2].exists, isTrue);
        expect(snapshots[2].data, documents[2].value);
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
        final data = {
          'k0-string': 'v0',
          'k1-string': 'v1',
        };
        final document = await insert(data: data);
        await _waitAfterWrite();

        // Get
        final snapshot = await document.get();
        expect(snapshot.document, same(document));
        expect(snapshot.exists, isTrue);
        expect(snapshot.data, data);

        // Get incrementally
        final list = await document.getIncrementally().toList();
        expect(list, isNotEmpty);
        expect(list.last.document, same(document));
        expect(list.last.exists, isTrue);
        expect(list.last.data, data);
      });

      test('not found', () async {
        if (database == null) {
          return;
        }

        // Get
        final document = collection.document('not-found');
        final snapshot = await document.get();
        expect(snapshot.document, same(document));
        expect(snapshot.exists, isFalse);
        expect(snapshot.data, isNull);

        // Get incrementally
        final list = await document.getIncrementally().toList();
        expect(list, isNotEmpty);
        expect(list.last.document, same(document));
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
        final data = {
          'k0-string': 'v0',
          'k1-string': 'v1',
        };
        final document = await insert(data: data);
        await _waitAfterWrite();

        // Get
        final snapshot = await document.get();
        expect(snapshot.document, same(document));
        expect(snapshot.exists, isTrue);
        expect(snapshot.data, data);
      });

      test('document exists, throws DatabaseException', () async {
        if (database == null) {
          return;
        }

        // Insert
        final data = {
          'k0-string': 'v0',
          'k1-string': 'v1',
        };
        final document = await insert(data: data);
        await _waitAfterWrite();

        // Insert again
        await expectLater(
          document.insert(data: {}),
          throwsA(isA<DatabaseException>()),
        );
      });

      group('different values:', () {
        Schema schema;
        setUp(() {
          schema = MapSchema({
            'null': ArbitraryTreeSchema(),
            'bool-0': BoolSchema(),
            'bool-1': BoolSchema(),
            'int': IntSchema(),
            'int64-0': Int64Schema(),
            'int64-1': Int64Schema(),
            'int64-2': Int64Schema(),
            'double-0': DoubleSchema(),
            'double-1': DoubleSchema(),
            'double-2': DoubleSchema(),
            'double-3': DoubleSchema(),
            'dateTime': DateTimeSchema(),
            'geoPoint': GeoPointSchema(),
            'string': StringSchema(),
            'document': DocumentSchema(),
          });
        });
        test('null', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: {
            'null': null,
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, {
            'null': null,
          });
        });

        test('bool', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'bool-0': false,
            'bool-1': true,
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          expect(snapshot.data, <String, Object>{
            'bool-0': false,
            'bool-1': true,
          });
        });

        test('Int64', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'int64-0': Int64(-2),
            'int64-1': Int64(0),
            'int64-2': Int64(2),
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'int64-0': Int64(-2),
            'int64-1': Int64(0),
            'int64-2': Int64(2),
          });
        });

        test('int', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'int': 3,
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'int': 3,
          });
        });

        test('double', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'double-0': 3.14,
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          final data = snapshot.data;
          expect(data['double-0'], 3.14);
        });

        test('double: nan', () async {
          if (database == null) {
            return;
          }

          await expectLater(
            insert(data: <String, Object>{
              'double-0': double.nan,
            }),
            throwsArgumentError,
          );
        });

        test('double: negative infinity', () async {
          if (database == null) {
            return;
          }

          await expectLater(
            insert(data: <String, Object>{
              'double-0': double.negativeInfinity,
            }),
            throwsArgumentError,
          );
        });

        test('double: positive infinity', () async {
          if (database == null) {
            return;
          }

          await expectLater(
            insert(data: <String, Object>{
              'double-0': double.infinity,
            }),
            throwsArgumentError,
          );
        });

        test('DateTime', () async {
          if (database == null) {
            return;
          }

          // Insert
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
            0,
            isUtc: true,
          );
          final dateTimeAsString =
              dateTime.toIso8601String().replaceAll(' ', 'T');

          final document = await insert(data: <String, Object>{
            'dateTime': dateTime,
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'dateTime': anyOf(dateTime, dateTimeAsString),
          });
        });

        test('GeoPoint', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'geoPoint': GeoPoint(1.0, 2.0),
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'geoPoint': GeoPoint(1.0, 2.0),
          });
        });

        test('String', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'string': '',
            'string': 'abc',
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'string': '',
            'string': 'abc',
          });
        });

        test('List', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'list': ['a', 'b', 'c']
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'list': ['a', 'b', 'c']
          });
        });

        test('Map', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = await insert(data: <String, Object>{
            'map': {
              'k0-string': 'v0',
              'k1-string': 'v1',
            },
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'map': {
              'k0-string': 'v0',
              'k1-string': 'v1',
            },
          });
        });

        test('Document', () async {
          if (database == null) {
            return;
          }

          // Insert
          final document = collection.newDocument();
          await document.insert(data: <String, Object>{
            'document': document,
          });
          await _waitAfterWrite();

          // Get
          final snapshot = await document.get(
            schema: schema,
          );
          ;
          expect(snapshot.data, <String, Object>{
            'document': document,
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
        final document = collection.newDocument();
        await document.upsert(data: {
          'k0-string': 'old value',
        });
        await _waitAfterWrite();

        // Upsert again
        await document.upsert(data: {
          'k1-string': 'new value',
        });
        await _waitAfterWrite();

        // Get
        final snapshot = await document.get();
        expect(snapshot.document, same(document));
        expect(snapshot.exists, isTrue);
        expect(snapshot.data, {
          'k1-string': 'new value',
        });
      });

      test('ok (does not exist)', () async {
        if (database == null) {
          return;
        }

        // Upsert
        final document = collection.newDocument();
        await document.upsert(data: {
          'k0-string': 'new value',
        });
        await _waitAfterWrite();

        // Get
        final snapshot = await document.get();
        expect(snapshot.document, same(document));
        expect(snapshot.exists, isTrue);
        expect(snapshot.data, {
          'k0-string': 'new value',
        });
      });
    });

    group('update():', () {
      test('ok', () async {
        if (database == null) {
          return;
        }

        // Upsert an existing document
        final document = await insert(data: {
          'string': 'old value',
        });
        await _waitAfterWrite();
        expect((await document.get()).data, {
          'string': 'old value',
        });

        // Update
        await document.update(data: {
          'string': 'new value',
        });
        await _waitAfterWrite();

        // Get
        final snapshot = await document.get();
        expect(snapshot.document, same(document));
        expect(snapshot.exists, isTrue);
        expect(snapshot.data, {
          'string': 'new value',
        });
      });

      test('document does not exist, throws DatabaseException', () async {
        if (database == null) {
          return;
        }

        // Update
        final document = collection.newDocument();
        await expectLater(
          document.update(data: {
            'string': 'value',
          }),
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
        final document = await insert(data: {
          'k0-string': 'value',
        });
        await _waitAfterWrite();

        // Delete
        await document.delete(mustExist: true);
        await _waitAfterWrite();

        // Get
        final snapshot = await document.get();
        expect(snapshot.document, same(document));
        expect(snapshot.exists, isFalse);
        expect(snapshot.data, isNull);
      });

      test('non-existing, throws DatabaseException', () async {
        if (database == null) {
          return;
        }

        // Delete
        final document = collection.newDocument();
        await expectLater(
          document.delete(mustExist: true),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('repeat twice, throws DatabaseException', () async {
        if (database == null) {
          return;
        }

        // Insert
        final document = collection.newDocument();
        await document.insert(data: {
          'k0-string': 'value',
        });
        await _waitAfterWrite();

        // Delete
        await document.delete(mustExist: true);
        await _waitAfterWrite();

        // Delete again
        await expectLater(
          document.delete(mustExist: true),
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
        final document0 = collection.newDocument();
        await document0.delete();
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
        final document0 = collection.newDocument();
        await document0.delete();
        await _waitAfterWrite();

        // Delete
        await document0.delete();
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

        final document0 = collection.newDocument();
        final document1 = collection.newDocument();

        final batch = database.newWriteBatch();
        batch.upsert(document0, data: {
          'k0-string': 'old value',
        });
        batch.upsert(document1, data: {
          'k0-string': 'new value',
        });

        // Wait
        await _waitAfterWrite();

        // Check that the writes are not committed
        expect((await document0.get()).exists, isFalse);
        expect((await document1.get()).exists, isFalse);

        // Commit
        await batch.commit();

        // Wait
        await _waitAfterWrite();

        // Check that the commit succeeded
        expect((await document0.get()).exists, isTrue);
        expect((await document1.get()).exists, isTrue);
      });
    });

    if (DatabaseAdapterTester.current.supportsTransactions) {
      group('transactions:', () {
        test('simple', () async {
          if (database == null) {
            return;
          }
          final document0 = collection.newDocument();
          final document1 = collection.newDocument();
          final document2 = collection.newDocument();

          await database.runInTransaction(
              reach: Reach.global,
              timeout: Duration(seconds: 1),
              callback: (transaction) async {
                // Read
                {
                  final snapshot = await transaction.get(document0);
                  expect(snapshot.exists, isFalse);
                }

                // Write
                await transaction.insert(document0, data: {
                  'k0-string': 'old value',
                });
                await transaction.upsert(document1, data: {
                  'k0-string': 'new value',
                });
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

void runSqlTests() {
  Database database;

  setUpAll(() async {
    database = await DatabaseAdapterTester.current.databaseBuilder();
  });

  tearDownAll(() async {
    await database?.adapter?.close();
  });

  test('a simple example', () async {
    if (database == null) {
      return;
    }

    final sqlClient = await database.sqlClient;

    //
    // Create table
    //
    try {
      await sqlClient.execute(
        'DROP TABLE test_employee',
      );
    } on DatabaseException {
      // Ignore
    }
    await sqlClient.execute('''CREATE TABLE test_employee (
  id int PRIMARY KEY,
  role varchar(255),
  name varchar(255)
);
''');

    // Drop the table later
    addTearDown(() async {
      await sqlClient.execute(
        'DROP TABLE test_employee',
      );
    });

    //
    // Write
    //
    {
      await sqlClient.execute(
        '''INSERT INTO test_employee (id, role, name) VALUES (0, 'developer', 'Miss Smith')''',
      );
      await sqlClient.execute(
        'INSERT INTO test_employee (id, role, name) VALUES (1, ?, ?)',
        ['developer', 'Mr Smith'],
      );
    }

    //
    // Read
    //
    {
      final result = await sqlClient
          .query(
            'SELECT id, role, name FROM test_employee;',
          )
          .getIterator();
      final rows = await result.toMaps();
      expect(
        rows,
        [
          {
            'id': 0,
            'role': 'developer',
            'name': 'Miss Smith',
          },
          {
            'id': 1,
            'role': 'developer',
            'name': 'Mr Smith',
          },
        ],
      );

      final columnDescriptions = result.columnDescriptions.toList()..sort();
      expect(columnDescriptions, hasLength(3));
      expect(columnDescriptions[0].columnName, 'id');
      expect(columnDescriptions[1].columnName, 'name');
      expect(columnDescriptions[2].columnName, 'role');
    }
  });
}

Future<void> _waitAfterWrite() {
  return Future<void>.delayed(DatabaseAdapterTester.current.writeDelay);
}

/// IMPORTANT:
/// This is a huge file in 'database/test/database_adapter_tester.dart'.
///
/// If you modify the file, copy it with the script:
///
///     ./tool/copy_database_adapter_test.sh
///
class DatabaseAdapterTester {
  static DatabaseAdapterTester current;

  /// Is it a cache?
  final bool isCache;

  /// Is it a SQL database?
  final bool isSqlDatabase;

  /// Does the database support transactions?
  final bool supportsTransactions;

  /// How long we have to wait until the write is visible?
  final Duration writeDelay;

  final FutureOr<Database> Function() databaseBuilder;

  DatabaseAdapterTester(
    this.databaseBuilder, {
    this.isCache = false,
    this.isSqlDatabase = false,
    this.writeDelay = const Duration(milliseconds: 100),
    this.supportsTransactions = false,
  });

  void run() {
    current = this;

    group('Document database tests:', () {
      if (isSqlDatabase) {
        return;
      }
      runCollectionAndDocumentTests();
    });

    // SQL database?
    if (isSqlDatabase) {
      group('SQL tests:', () {
        runSqlTests();
      });
    }
  }
}

class SqlDatabaseAdapterTester extends DatabaseAdapterTester {
  SqlDatabaseAdapterTester(Database Function() databaseBuilder)
      : super(databaseBuilder, isSqlDatabase: true);
}
