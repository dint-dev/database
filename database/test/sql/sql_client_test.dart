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

import 'package:database/database_adapter.dart';
import 'package:database/sql.dart';
import 'package:test/test.dart';

void main() {
  group('SqlClient:', () {
    List<SqlStatement> statements;
    SqlClient sqlClient;

    setUp(() {
      final databaseAdapter = _MockSqlDatabaseAdapter();
      statements = databaseAdapter.statements;
      sqlClient = databaseAdapter.database().sqlClient;
      expect(sqlClient, isNotNull);
    });

    test('createTable(_)', () async {
      await sqlClient.createTable('example');

      expect(
        statements,
        [
          SqlStatement(
            'CREATE TABLE "example"',
          ),
        ],
      );
    });

    test('dropTable(_)', () async {
      await sqlClient.dropTable('example');

      expect(
        statements,
        [
          SqlStatement(
            'DROP TABLE "example"',
          ),
        ],
      );
    });

    test('table(_).addColumn(_)', () async {
      await sqlClient
          .table('example')
          .addColumn('columnName', SqlType.varChar(255));

      expect(
        statements,
        [
          SqlStatement(
            'ALTER TABLE "example" ADD COLUMN "columnName" VARCHAR(255)',
          ),
        ],
      );
    });

    test('table(_).renameColumn(_)', () async {
      await sqlClient.table('example').renameColumn(
            oldName: 'oldName',
            newName: 'newName',
          );

      expect(
        statements,
        [
          SqlStatement(
            'ALTER TABLE "example" RENAME COLUMN "oldName" "newName"',
          ),
        ],
      );
    });

    test('table(_).dropColumn(_)', () async {
      await sqlClient.table('example').dropColumn('columnName');

      expect(
        statements,
        [
          SqlStatement(
            'ALTER TABLE "example" DROP COLUMN "columnName"',
          ),
        ],
      );
    });

    test('table(_).createIndex(_)', () async {
      await sqlClient.table('example').createIndex('indexName', ['a', 'b']);

      expect(
        statements,
        [
          SqlStatement(
            'CREATE INDEX "indexName" ON "example" ("a", "b")',
          ),
        ],
      );
    });

    test('table(_).dropIndex(_)', () async {
      await sqlClient.table('example').dropIndex('indexName');

      expect(
        statements,
        [
          SqlStatement(
            'DROP INDEX "indexName" ON "example"',
          ),
        ],
      );
    });

    test('table(_).addForeignKeyConstraint(_)', () async {
      await sqlClient.table('example').addForeignKeyConstraint(
            constraintName: 'exampleConstraint',
            localColumnNames: ['a', 'b'],
            foreignTableName: 'exampleForeignTable',
            foreignColumnNames: ['c', 'd'],
            onUpdate: SqlReferenceUpdateAction.setNull,
            onDelete: SqlReferenceDeleteAction.setNull,
          );

      expect(
        statements,
        [
          SqlStatement(
            'ALTER TABLE "example" ADD CONSTRAINT "exampleConstraint" FOREIGN KEY ("a", "b") REFERENCES "exampleForeignTable" ("c", "d") ON UPDATE SET NULL ON DELETE SET NULL',
          ),
        ],
      );
    });

    test('table(_).dropConstraint(_)', () async {
      await sqlClient.table('example').dropConstraint('exampleConstraint');

      expect(
        statements,
        [
          SqlStatement(
            'ALTER TABLE "example" DROP CONSTRAINT "exampleConstraint"',
          ),
        ],
      );
    });

    test('runInTransaction(_)', () async {
      await sqlClient.runInTransaction((sqlClient) async {
        await sqlClient.execute('a');
        await sqlClient.execute('b');
      });

      expect(
        statements,
        [
          SqlStatement(
            'BEGIN TRANSACTION',
          ),
          SqlStatement(
            'a',
          ),
          SqlStatement(
            'b',
          ),
          SqlStatement(
            'COMMIT TRANSACTION',
          ),
        ],
      );
    });

    test('runInTransaction(_): rolls back if the function throws', () async {
      try {
        await sqlClient.runInTransaction((sqlClient) async {
          await sqlClient.execute('a');
          await sqlClient.execute('b');
          throw StateError('example');
        });
      } on StateError {
        // ...
      }

      expect(
        statements,
        [
          SqlStatement(
            'BEGIN TRANSACTION',
          ),
          SqlStatement(
            'a',
          ),
          SqlStatement(
            'b',
          ),
          SqlStatement(
            'ROLLBACK TRANSACTION',
          ),
        ],
      );
    });

    test('runInTransaction(_) uses lock', () async {
      final oldSqlClient = sqlClient;

      Future otherTransactionFuture;

      await sqlClient.runInTransaction((newSqlClient) async {
        // First statement
        await sqlClient.execute('a');

        // Start another transaction
        otherTransactionFuture =
            oldSqlClient.runInTransaction((sqlClient) async {
          await sqlClient.execute('c');
        });

        // Wait
        await Future.delayed(const Duration(milliseconds: 2));

        // Last statement
        await sqlClient.execute('b');
      });

      // Wait for the other transaction
      await otherTransactionFuture;

      expect(
        statements,
        [
          SqlStatement(
            'BEGIN TRANSACTION',
          ),
          SqlStatement(
            'a',
          ),
          SqlStatement(
            'b',
          ),
          SqlStatement(
            'COMMIT TRANSACTION',
          ),
          SqlStatement(
            'BEGIN TRANSACTION',
          ),
          SqlStatement(
            'c',
          ),
          SqlStatement(
            'COMMIT TRANSACTION',
          ),
        ],
      );
    });

    test('table(_).deleteAll()', () async {
      await sqlClient.table('product').deleteAll();

      expect(
        statements,
        [
          SqlStatement(
            'DELETE FROM "product"',
            [],
          ),
        ],
      );
    });

    test('table(_).whereColumns(_).deleteAll()', () async {
      await sqlClient.table('product').whereColumns({
        'name': 'nameValue',
        'price': 8,
      }).deleteAll();

      expect(
        statements,
        [
          SqlStatement(
            'DELETE FROM "product" WHERE "name" = ?, "price" = ?',
            ['nameValue', 8],
          ),
        ],
      );
    });

    test('table(_).insert(_): one column', () async {
      await sqlClient.table('product').insert({'name': 'nameValue'});

      expect(
        statements,
        [
          SqlStatement(
            'INSERT INTO "product" ("name") VALUES (?)',
            ['nameValue'],
          ),
        ],
      );
    });

    test('table(_).insert(_): two columns', () async {
      await sqlClient.table('product').insert({
        'name': 'nameValue',
        'price': 8,
      });

      expect(
        statements,
        [
          SqlStatement(
            'INSERT INTO "product" ("name", "price") VALUES (?, ?)',
            ['nameValue', 8],
          )
        ],
      );
    });

    test('table(_).insertAll(_): 0 rows', () async {
      await sqlClient.table('product').insertAll([]);

      expect(
        statements,
        [],
      );
    });

    test('table(_).insertAll(_): 2 rows', () async {
      await sqlClient.table('product').insertAll([
        {'name': 'value0'},
        {'name': 'value1'},
      ]);

      expect(
        statements,
        [
          SqlStatement(
            'INSERT INTO "product" ("name") VALUES (?), (?)',
            ['value0', 'value1'],
          ),
        ],
      );
    });

    test('table(_).select()', () async {
      await sqlClient.table('product').select().getIterator();

      expect(
        statements,
        [
          SqlStatement(
            'SELECT * FROM "product"',
            [],
          ),
        ],
      );
    });

    test('table(_).select(columnNames:_)', () async {
      await sqlClient
          .table('product')
          .select(columnNames: ['name', 'price']).getIterator();

      expect(
        statements,
        [
          SqlStatement(
            'SELECT "name", "price" FROM "product"',
            [],
          ),
        ],
      );
    });

    test('table(_).whereColumns(_).select()', () async {
      await sqlClient
          .table('product')
          .whereColumns({
            'name': 'nameValue',
            'price': 8,
          })
          .select()
          .getIterator();

      expect(
        statements,
        [
          SqlStatement(
            'SELECT * FROM "product" WHERE "name" = ?, "price" = ?',
            ['nameValue', 8],
          ),
        ],
      );
    });

    test('table(_).offset(2).select()', () async {
      await sqlClient.table('product').offset(2).select().getIterator();

      expect(
        statements,
        [
          SqlStatement(
            'SELECT * FROM "product" OFFSET ?',
            [2],
          ),
        ],
      );
    });

    test('table(_).limit(2).select()', () async {
      await sqlClient.table('product').limit(2).select().getIterator();

      expect(
        statements,
        [
          SqlStatement(
            'SELECT * FROM "product" LIMIT ?',
            [2],
          ),
        ],
      );
    });

    test('table(_).ascending(_).select()', () async {
      await sqlClient
          .table('product')
          .ascending('price')
          .select()
          .getIterator();

      expect(
        statements,
        [
          SqlStatement(
            'SELECT * FROM "product" ORDER BY ASC "price"',
            [],
          ),
        ],
      );
    });

    test('table(_).decending(_).select()', () async {
      await sqlClient
          .table('product')
          .descending('price')
          .select()
          .getIterator();

      expect(
        statements,
        [
          SqlStatement(
            'SELECT * FROM "product" ORDER BY DESC "price"',
            [],
          ),
        ],
      );
    });
  });
}

class _MockSqlDatabaseAdapter extends SqlDatabaseAdapter {
  final List<SqlStatement> statements = <SqlStatement>[];

  @override
  Future<SqlIterator> performSqlQuery(SqlQueryRequest request) async {
    statements.add(request.sqlStatement);
    return SqlIterator.fromLists(
      columnDescriptions: [],
      rows: [],
    );
  }

  @override
  Future<SqlStatementResult> performSqlStatement(
      SqlStatementRequest request) async {
    statements.add(request.sqlStatement);
    return SqlStatementResult();
  }
}
