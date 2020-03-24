[![Pub Package](https://img.shields.io/pub/v/database.svg)](https://pub.dartlang.org/packages/database)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dint-dev/database)

# Introduction
This is __database.dart__, a vendor-agnostic database access API for [Flutter](https://flutter.io)
and other [Dart](https://dart.dev) projects.

__This version is just an early preview__. Major changes are possible during the early development.
Anyone is welcome to contribute to the development of this package.

Licensed under [the Apache License 2.0](LICENSE).

## Why this package?
  * 👫 __Document & SQL database support__. The API has been designed to support both SQL databases
    and document databases. You - or your customers - can always choose the best database without
    rewriting any code.
  * 🔭 __Full-text search engine support__. The API supports forwarding specific queries to search
    engines that can, for example, handle natural language queries better than transaction databases.
    There are already several search engines already supported (Algolia, ElasticSearch, and a simple
    search engine written in Dart).

## Links
  * [Github project](https://github.com/dint-dev/database)
  * [API reference](https://pub.dev/documentation/database/latest/)
  * [Pub package](https://pub.dev/packages/database)

## Issues?
  * Report issues at the [issue tracker](https://github.com/dint-dev/database/issues).
  * Contributing a fix? Fork the repository, do your changes, and just create a pull request in
    Github. Key contributors will be invited to become project administrators in Github.

## Supported products and APIs
### Document databases
  * __Azure Cosmos DB__ ([website](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction))
    * Package (not ready for use): _database_adapter_azure_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/azure/lib/)
  * __Google Cloud Firestore__ ([website](https://firebase.google.com/docs/firestore))
    * Browser package: [database_adapter_firestore_browser](https://pub.dev/packages/database_adapter_firestore_browser) ([Github](https://github.com/dint-dev/database/tree/master/adapters/firestore_browser/lib/))
    * Flutter (iOS /Android) package: [database_adapter_firestore_flutter](https://pub.dev/packages/database_adapter_firestore_flutter) ([Github](https://github.com/dint-dev/database/tree/master/adapters/firestore_flutter/lib/))
  * _Have a package? Add it here!_

### SQL databases
  * __PostgreSQL__ ([website](https://www.postgresql.org/))
    * Package: [database_adapter_postgre](https://pub.dev/packages/database_adapter_postgre) ([Github](https://github.com/dint-dev/database/tree/master/adapters/postgre/lib/))
  * __SQLite__ ([website](https://www.sqlite.org/))
    * Package: [database_adapter_sqlite](https://pub.dev/packages/database_adapter_sqlite) ([Github](https://github.com/dint-dev/database/tree/master/adapters/sqlite/lib/))
  * _Have a package? Add it here!_

### Search engines
  * __Algolia__ ([website](https://www.algolia.com))
    * Package: [database_adapter_algolia](https://pub.dev/packages/database_adapter_algolia) ([Github](https://github.com/dint-dev/database/tree/master/adapters/algolia/lib/))
  * __Azure Cognitive Search__ ([search](https://azure.microsoft.com/en-us/services/search))
    * Package (not ready for use): _database_adapter_azure_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/azure/lib/)
  * __Elasticsearch__ ([website](https://www.elastic.co)))
    * Package: [database_adapter_elasticsearch](https://pub.dev/packages/database_adapter_elasticsearch) ([Github](https://github.com/dint-dev/database/tree/master/adapters/elasticsearch/lib/))
  * _Have a package? Add it here!_

### Other
  * __Web APIs__
    * [BrowserDatabaseAdapter](https://pub.dev/documentation/database/latest/database.browser/BrowserDatabaseAdapter-class.html) ([Github](https://github.com/dint-dev/database/tree/master/database/browser.dart))
      uses the best available web API.
    * [LocalStorageDatabaseAdapter](https://pub.dev/documentation/database/latest/database.browser/LocalStorageDatabaseAdapter-class.html) ([Github](https://github.com/dint-dev/database/tree/master/database/browser.dart)).
  * __Memory__
    * [MemoryDatabaseAdapter](https://pub.dev/documentation/database/latest/database/MemoryDatabaseAdapter-class.html) ([Github](https://github.com/dint-dev/database/tree/master/database/lib/src/database/adapters/memory.dart))
    keeps data in memory. Good for tests and caching.
  * _Have a package? Add it here!_

### Middleware
  * [CachingDatabaseAdapter](https://pub.dev/documentation/database/latest/database/CachingDatabaseAdapter-class.html) ([Github](https://github.com/dint-dev/database/tree/master/database/lib/src/database/adapters/caching_database.dart))
    * Caches data in another database (such as _MemoryDatabaseAdapter_).
  * [SchemaEnforcingDatabaseAdapter](https://pub.dev/documentation/database/latest/database/SchemaEnforcingDatabaseAdapter-class.html) ([Github](https://github.com/dint-dev/database/tree/master/database/lib/src/database/adapters/schema_using_database.dart))
    * Enforces schemas on reads/writes.
  * [SearchEnginePromotingDatabaseAdapter](https://pub.dev/documentation/database/latest/database/SearchEnginePromotingDatabaseAdapter-class.html) ([Github](https://github.com/dint-dev/database/tree/master/database/lib/src/database/adapters/search_forwarding_database.dart))
    * Forwards cache-accepting search requests to a search engine.
  * _SearchingDatabaseAdapter_ in package [search](https://pub.dev/packages/search) ([Github](https://github.com/dint-dev/database/tree/master/search/lib/))
    provides minimalistic search engine for small collections.
  * _Have a package? Add it here!_


# Getting started
## 1.Add dependency
In `pubspec.yaml`, add:
```yaml
dependencies:
  database: any
```

## 2.Choose adapter

Look at the earlier list of adapters.

For example:

```dart
import 'package:database/database.dart';

final database = MemoryDatabaseAdapter().database();
```


# Document-style API
## Overview
If you have used some other document-oriented API (such as Google Firestore), this API will feel
familiar to you. A database is made of document collections. A document is an arbitrary tree of
values that may contain references to other documents.

See the classes:
  * [Database](https://pub.dev/documentation/database/latest/database/Database-class.html)
  * [Collection](https://pub.dev/documentation/database/latest/database/Collection-class.html)
  * [Document](https://pub.dev/documentation/database/latest/database/Document-class.html)
  * [Query](https://pub.dev/documentation/database/latest/database/Query-class.html)
  * [QueryResult](https://pub.dev/documentation/database/latest/database/QueryResult-class.html)
  * [Snapshot](https://pub.dev/documentation/database/latest/database/Snapshot-class.html)

For example, this is how you would store a recipe using
[MemoryDatabaseAdapter](https://pub.dev/documentation/database/latest/database/MemoryDatabaseAdapter-class.html)
(our in-memory database):

```dart
Future<void> main() async {
  // Use an in-memory database
  final database = MemoryDatabase();

  // Our collection
  final collection = database.collection('pizzas');

  // Our document
  final document = collection.newDocument();

  // Insert a pizza
  await document.insert({
    'name': 'Pizza Margherita',
    'rating': 3.5,
     'ingredients': ['dough', 'tomatoes'],
    'similar': [
      database.collection('recipes').document('pizza_funghi'),
    ],
  });

  // ...
}
```

## Supported data types
  * `null`
  * `bool`
  * `int`
  * [Int64](https://pub.dev/documentation/fixnum/latest/fixnum/Int64-class.html)
  * `double`
  * [Date](https://pub.dev/documentation/database/latest/database/Date-class.html)
  * `DateTime`
  * [Timestamp](https://pub.dev/documentation/database/latest/database/Timestamp-class.html)
  * [GeoPoint](https://pub.dev/documentation/database/latest/database/GeoPoint-class.html)
  * `String`
  * `Uint8List`
  * `List`
  * `Map<String,Object>`
  * [Document](https://pub.dev/documentation/database/latest/database/Document-class.html) (a reference to another document)


## Inserting documents

Use [collection.insert()](https://pub.dev/documentation/database/latest/database/Collection/insert.html),
which automatically generates a document ID for you:
```dart
final document = await database.collection('product').insert({
  'name: 'Coffee mug',
  'price': 8.50,
});
```

If you want to use a specific document identifier, you can use use [collection.document('id').insert(...)](https://pub.dev/documentation/database/latest/database/Document/insert.html):
```dart
await database.collection('product').document('coffeeMugId').insert({
  'name: 'Coffee mug',
  'price': 8.50,
});
```


## Updating documents

Use [document.patch()](https://pub.dev/documentation/database/latest/database/Document/patch.html)
for updating individual properties:
```dart
await product.patch(
  {
    'price': 12.50,
  },
);
```

If you want to update all properties, use [document.update()](https://pub.dev/documentation/database/latest/database/Document/update.html).

If you want to update the document even when it doesn't exist, use [document.upsert()](https://pub.dev/documentation/database/latest/database/Document/upsert.html).


### Deleting documents
Use [document.delete()](https://pub.dev/documentation/database/latest/database/Document/delete.html):
```dart
await document.delete();
```


## Reading documents
You can read a snapshot with [document.get()](https://pub.dev/documentation/database/latest/database/Document/get.html).
In this example, we read a snapshot from a regional master database. If it's acceptable to have a
locally cached version, you should use `Reach.local`.

```dart
final snapshot = await document.get(reach: Reach.regional);

// Use 'exists' to check whether the document exists
if (snapshot.exists) {
  final price = snapshot.data['price'];
  print('price: $price');
}
```

## Watching changes in documents
You can watch document changes with [document.watch()](https://pub.dev/documentation/database/latest/database/Document/watch.html).
Some databases support this natively. In other databases, the implementation may use polling.

```dart
final stream = await document.watch(
  pollingInterval: Duration(seconds:2),
);
```

## Transactions
Use [database.runInTransaction()](https://pub.dev/documentation/database/latest/database/Database/runInTransaction.html):

```dart
await database.runInTransaction((transaction) async {
  final document = database.collection('products').document('coffeeMugId');
  final snapshot = await transaction.get(document);
  final price = snapshot.data['price'] as double;
  await transaction.patch(document, {
    'price': price + 1.50,
  });
), timeout: Duration(seconds:3);
```


## Searching documents
You can search documents with [collection.search()](https://pub.dev/documentation/database/latest/database/Collection/search.html),
which takes a [Query](https://pub.dev/documentation/database/latest/database/Query-class.html).

For example:
```dart
// Define what we are searching
final query = Query(
  filter: MapFilter({
    'category': OrFilter([
      ValueFilter('computer'),
      ValueFilter('tablet'),
    ]),
    'price': RangeFilter(min:0, max:1000),
  }),
  skip: 0, // Start from the first result item
  take: 10, // Return 10 result items
);

// Send query to the database
final result = await database.collection('product').search(
  query: query,
  reach: Reach.server,
);
```


The result is [QueryResult](https://pub.dev/documentation/database/latest/database/QueryResult-class.html),
which contains a [Snapshot](https://pub.dev/documentation/database/latest/database/Snapshot-class.html)
for each item:

```dart
// For each snapshots
for (var snapshot in result.snapshots) {
  // Get price
  final price = snapshot.data['price'] as double;
  print('price: $price');
}
```


### Supported logical filters
  * [AndFilter](https://pub.dev/documentation/database/latest/database.filter/AndFilter-class.html)
    * `AndFilter([ValueFilter('f0'), ValueFilter('f1')])`
  * [OrFilter](https://pub.dev/documentation/database/latest/database.filter/OrFilter-class.html)
    * `OrFilter([ValueFilter('f0'), ValueFilter('f1')])`
  * [NotFilter](https://pub.dev/documentation/database/latest/database.filter/NotFilter-class.html)
    * `NotFilter(ValueFilter('example'))`


### Supported structural filters
  * [MapFilter](https://pub.dev/documentation/database/latest/database.filter/MapFilter-class.html)
    * `MapFilter({'key': ValueFilter('value')})`
  * [ListFilter](https://pub.dev/documentation/database/latest/database.filter/ListFilter-class.html)
    * `ListFilter(items: ValueFilter('value'))`


### Supported primitive filters
  * [ValueFilter](https://pub.dev/documentation/database/latest/database.filter/ValueFilter-class.html)
    * `ValueFilter(3.14)`
  * [RangeFilter](https://pub.dev/documentation/database/latest/database.filter/RangeFilter-class.html)
    * `RangeFilter(min:3)`
    * `RangeFilter(min: Date(2020,01,01), max: Date(2020,06,01))`
    * `RangeFilter(min:0.0, max:1.0, isExclusiveMax:true)`
  * [GeoPointFilter](https://pub.dev/documentation/database/latest/database.filter/GeoPointFilter-class.html)
    * `GeoPointFilter(near:GeoPoint(1.23, 3.45), maxDistanceInMeters:1000)`


# Using SQL
By using [SqlClient](https://pub.dev/documentation/database/latest/database.sql/SqlClient-class.html),
you can interact with the database using SQL:

```dart
import 'package:database/sql.dart';
import 'package:database_adapter_postgre/database_adapter_postgre.dart';

Future main() async {
    // In this example, we use PostgreSQL adapter
    final database = Postgre(
      host:         'localhost',
      user:         'database user',
      password:     'database password',
      databaseName: 'example',
    ).database();

    // Get SQL client.
    final sqlClient = database.sqlClient;

    // Select all pizza products with price less than 10.
    //
    // This will return a value of type:
    //   Iterable<Map<String,Object>>
    final pizzas = await sqlClient.query(
      'SELECT * FROM product WHERE type = ?, price < ?',
      ['pizza', 10],
    ).toMaps();

    for (var pizza in pizzas) {
      print(pizza['name']);
    }
}
```


## Selecting rows
```dart
final pizzas = await sqlClient
  .table('Product')
  .whereColumn('category', 'pizza')
  .descending('price')
  .select(columnNames:['name', 'price'])
  .toMaps();
```

...is just another way to execute:

```dart
final pizzas = await sqlClient.query(
  'SELECT FROM Product (name, price) WHERE category = ? ORDER BY DESCENDING price,
  ['pizza'],
).toMaps();;
```


## Inserting rows
```dart
await sqlClient.table('Product').insert({
  'name': 'Pizza Hawaii',
  'category': 'pizza',
  'price': 8.50,
});
```

...is just another way to execute:

```dart
await sqlClient.execute(
  'INSERT INTO Product (name, price) VALUES (?, ?)',
  ['Pizza Hawaii', 8.50],
);
```


## Deleting rows
```dart
await sqlClient.table('Product').where('price < ?', [5.0]).deleteAll();
```

...is just another way to execute:

```dart
await sqlClient.execute('DELETE FROM Product WHERE price < ?', [5.0]);
```


## Transactions
```dart
await sqlClient.runInTransaction((transaction) async {
  final values = await transaction.query('...').toMaps();
  // ...

  await transaction.execute('...');
  await transaction.execute('...');
  // ...
), timeout: Duration(seconds:3));
```


## Structural statements
```dart
await sqlClient.createTable('TableName');
await sqlClient.dropTable('TableName');

await sqlClient.table('TableName').createColumn('ColumnName', 'TypeName');
await sqlClient.table('TableName').renameColumn(oldName:'OldName', newName:'NewName');
await sqlClient.table('TableName').dropColumn('ColumnName');

await sqlClient.table('TableName').createForeignKeyConstraint(
  constraintName: 'ConstraintName',
  localColumnNames: ['Column0', 'Column1', 'Column2'],
  foreignTable: 'ForeignTableName',
  foreignColumnNames: ['Column0', 'Column1', 'Column2']
);
await sqlClient.table('TableName').dropConstraint('ConstraintName');

await sqlClient.table('TableName').createIndex('IndexName', ['Column0', 'Column1', 'Column2']);
await sqlClient.table('TableName').dropIndex('IndexName');
```


# Parsing natural language queries
[Query.parse](https://pub.dev/documentation/database/latest/database/Query/parse.html)
enables parsing search queries from strings.

The supported syntax is almost identical to syntax used by Apache Lucene, a popular search engine
written in Java. Lucene syntax itself is similar to syntax used by search engines such as Google or
Bing. Keywords are parsed into [KeywordFilter](https://pub.dev/documentation/database/latest/database.filter/KeywordFilter-class.html)
instances. Note that most database adapters do not support keywords. If you use keywords, make sure
you configure a specialized text search engine.


## Example

```dart
final query = Query.parse(
  'Coffee Mug price:<=10',
  skip: 0,
  take: 10,
);
```

...returns the following query:

```dart
final query = Query(
  filter: AndFilter([
    KeywordFilter('Coffee),
    KeywordFilter('Mug'),
    MapFilter({
      'price': RangeFilter(max:10),
    }),
  ]),
  skip: 0,
  take: 10,
);
```


## Supported query syntax
Examples:
  * `norwegian forest cat`
    * Matches keywords "norwegian", "forest", and "cat".
  * `"norwegian forest cat"`
    * A quoted keyword ensures that the words must appear as a sequence.
  * `cat AND dog`
    * Matches keywords "cat" and "dog" (in any order).
  * `cat OR dog`
    * Matches keyword "cat", "dog", or both.
  * `pet -cat`
    * Matches keyword "pet", but excludes documents that match keyword "cat".
  * `color:brown`
    * Color matches keyword "brown".
  * `color:="brown"`
    * Color is equal to "brown".
  * `weight:>=10`
    * Weight is greater than or equal to 10.
  * `weight:[10 TO 20]`
    * Weight is between 10 and 20, inclusive.
  * `weight:{10 TO 20}`
    * Weight is between 10 and 20, exclusive.
  * `(cat OR dog) AND weight:>=10`
    * An example of grouping filters.

In equality and range expressions, the parser recognizes:
  * `null`
  * `false`, `true`
  * `3`
  * `3.14`
  * `2020-12-31` (Date)
  * `2020-12-31T00:00:00Z` (DateTime)

For example:
  * `weight:=10` --> `MapFilter({'weight':ValueFilter(10)})`
  * `weight:="10"` --> `MapFilter({'weight':ValueFilter('10')})`
  * `weight:=10kg` --> `MapFilter({'weight':ValueFilter('10kg')})`
  * `weight:10` --> `MapFilter({'weight':KeywordFilter('10')})`