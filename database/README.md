[![Pub Package](https://img.shields.io/pub/v/database.svg)](https://pub.dartlang.org/packages/database)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Introduction
This is __database.dart__, a vendor-agnostic database API for [Flutter](https://flutter.io) and
other [Dart](https://dart.dev) projects.

## Features
  * 👫 __Document & SQL database support__. The API has been designed to support both SQL databases
    and document databases. You - or your customers - can always choose the best database without
    rewriting any code.
  * 🔭 __Full-text search engine support__. The API supports forwarding specific queries to search
    engines that can, for example, handle natural language queries better than transaction databases.
    There are already several search engines already supported (Algolia, ElasticSearch, and a simple
    search engine written in Dart).
  * 🚚 __Used in commercial products__. The authors use the package in enterprise applications. The
    package is also used by open-source projects such as [Dint](https://dint.dev).

## Links
  * [Issue tracker](https://github.com/dint-dev/database/issues).
  * [Github project](https://github.com/dint-dev/database/tree/master/database)
  * [API reference](https://pub.dev/documentation/database/latest/)

## Contributing
  * Just create a pull request [in Github](https://github.com/dint-dev/database).

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

final Database database = MemoryDatabaseAdapter().database();
```

# Reading/writing documents
## Supported primitives
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

## Writing
### Upsert, delete
```dart
// Allocate a document with a random 128-bit identifier
final document = database.collection('example').newDocument();

// Upsert, which means "inserting or updating".
await document.upsert({
  'any property': 'any value',
});

// Delete
await document.delete();
```


### Insert, update, delete
```dart
// Insert
final product = database.collection('product').insert({
  'name: 'Coffee mug',
  'price': 8,
})s;

// Update
await product.update(
  {
    'name': 'Coffee mug',
    'price': 12,
  },
);

// Delete
await document.delete(mustExist:true);
```


## Reading data
### get()

```dart
// Read a snapshot from a regional master database.
// If it's acceptable to have a locally cached version, use Reach.local.
final snapshot = await document.get(reach: Reach.regional);

// Use 'exists' to check whether the document exists
if (snapshot.exists) {
  final price = snapshot.data['price'];
  print('price: $price');
}
```

### watch()
By using `watch` function, you continue to receive updates to the document. Some databases support
this natively. In other databases, watching may be accomplished by polling.

```dart
final stream = await document.watch(
  pollingInterval: Duration(seconds:2),
  reach: Reach.server,
);
```

## Searching
Search products with descriptions containing 'milk' or 'vegetables':
```dart
final result = await database.collection('product').search(
  query: Query.parse('description:(bread OR vegetables)'),
  reach: Reach.server,
);

for (var snapshot in result.snapshots) {
  // ...
}
```

## Available filters
The following logical operations are supported:
  * `AndFilter([ValueFilter('f0'), ValueFilter('f1')])`
  * `OrFilter([ValueFilter('f0'), ValueFilter('f1')])`
  * `NotFilter(ValueFilter('example'))`

The following primitives supported:
  * __List__
    * `ListFilter(items: ValueFilter('value'))`
  * __Map__
    * `MapFilter({'key': ValueFilter('value')})`
  * __Comparisons__
    * `ValueFilter(3.14)`
    * `RangeFilter(min:3, max:4)`
    * `RangeFilter(min:3, max:4, isExclusiveMin:true, isExclusiveMax:true)`
    * `RangeFilter(min:3, max:4, isExclusiveMin:true, isExclusiveMax:true)`
  * __Geospatial__
    * [GeoPointFilter]
      * Example: `GeoPointFilter(near:GeoPoint(1.23, 3.45), maxDistance:1000)`

The following special filter types are also supported:
  * __SQL query__
    * Example: `SqlFilter('SELECT * FROM hotels WHERE breakfast = ?, price < ?', [true, 100])`
    * Should be only in the root level of the query.
  * __Natural language search query__
    * Examples:`KeywordFilter('example')`
    * Keyword queries (`KeyFilter`) do not usually work unless you have configured a search
      engine for your application.

# Using SQL client
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

    // Construct SQL client.
    final sqlClient = database.sqlClient;

    // Select all pizza products with price less than 10.
    final pizzas = await sqlClient.query(
      'SELECT * FROM product WHERE type = ?, price < ?',
      ['pizza', 10],
    ).toMaps();

    for (var pizza in pizzas) {
      print(pizza['name']);
    }
}
```


# Advanced usage
## Parsing search query strings
You can parse search queries from strings. The supported syntax is very similar to other major
search engines such as Lucene.

```dart
final query = Query.parse('New York Times date:>=2020-01-01');
```

Examples of supported queries:
  * `Norwegian Forest cat`
    * Matches keywords "Norwegian", "Forest", and "cat".
  * `"Norwegian Forest cat"`
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

In equality/range expressions, the parser recognizes patterns such as:
  * null, false, true, 3, 3.14
  * 2020-12-31 (Date)
  * 2020-12-31T00:00:00Z (DateTime)
  * Other values are interpreted as strings