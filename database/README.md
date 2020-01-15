[![Pub Package](https://img.shields.io/pub/v/database.svg)](https://pub.dartlang.org/packages/database)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Introduction
 __Warning:__ this package isn't ready for use!

The package aims to be usable with:
  * __SQL databases__
  * __Document databases__ (like Google Cloud Firestore)
  * __Search engines__ (like ElasticSearch/Lucene)

The current iteration of the API has a single API for all three database paradigms. This is somewhat
unconventional and carries a risk of confusion when developers read documentation or make
assumptions about behavior. We evaluate the current approach, and if it doesn't seem right, split
the unified API into two or three libraries.

Any feedback on the design is appreciated. The project is licensed under the
[Apache License 2.0](LICENSE). If this project interests you, please consider becoming a
developer/maintainer.


## Links
  * [API documentation](https://pub.dev/documentation/database/latest/)
  * [Issue tracker](https://github.com/dint-dev/database/issues)
  * [Github source code](https://github.com/dint-dev/database/tree/master/database)


## Available adapters
### In this package
  * [BrowserDatabase](https://pub.dev/documentation/database/latest/database.browser/BrowserDatabase-class.html) ([Github](https://github.com/dint-dev/database/tree/master/browser.dart))
    * Stores data using browser APIs.
  * [MemoryDatabase](https://pub.dev/documentation/database/latest/database/MemoryDatabase-class.html) ([Github](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/database/adapters/memory_database.dart))
    * Stores data in memory.

### In other packages
  * [database_adapter_elasticsearch](https://pub.dev/packages/database_adapter_elasticsearch) ([Github](https://github.com/dint-dev/database/tree/master/adapters/elasticsearch/lib/))
    * For using [Elasticsearch](https://www.elastic.co).
  * [database_adapter_postgre](https://pub.dev/packages/database_adapter_postgre) ([Github](https://github.com/dint-dev/database/tree/master/adapters/postgre/lib/))
    * For using [PostgreSQL](https://www.postgresql.org/).
  * _Have a package? Add it here!_

The following packages are currently far from passing our shared test suite:
  * _database_adapter_algolia_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/algolia/lib/))
    * For using [Algolia](https://www.algolia.com).
  * _database_adapter_azure_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/azure/lib/))
    * For using [Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction).
    * For using [Azure Cognitive Search](https://azure.microsoft.com/en-us/services/search).
  * _database_adapter_gcloud_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/gcloud/lib/))
    * For using [Google Cloud Database](https://cloud.google.com/database).
  * _database_adapter_grpc_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/grpc/lib/))
    * For communicating with a server over a [GRPC](https://grpc.io) channel.
  * _database_adapter_firestore_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/firestore/lib/))
    * For using [Google Cloud Firestore](https://firebase.google.com/docs/firestore).
  * _database_adapter_firestore_flutter_ ([Github](https://github.com/dint-dev/database/tree/master/adapters_incubator/firestore_flutter/lib/))
    * For using [Google Cloud Firestore](https://firebase.google.com/docs/firestore).


## Available middleware classes
### In this package
  * [CachingDatabase](https://pub.dev/documentation/database/latest/database/CachingDatabase-class.html) ([Github](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/database/adapters/caching_database.dart))
    * Caches data in another database (such as _MemoryDatabase_).
  * [SchemaUsingDatabase](https://pub.dev/documentation/database/latest/database/SchemaUsingDatabase-class.html) ([Github](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/database/adapters/schema_using_database.dart))
    * Enforces schemas on reads/writes.

### Other packages
  * [search](https://pub.dev/packages/search) ([Github](https://github.com/dint-dev/database/tree/master/search/lib/))
    * An minimalistic search engine for small collections.
  * _Have a package? Add it here!_


## Contributing
This is an open-source community project. Anyone, even beginners, can contribute.

This is how you contribute:
  1. Fork [github.com/dint-dev/dint](https://github.com/dint-dev/database) by pressing fork button.
  2. Clone your fork to your computer: `git clone github.com/your_username/database`
  3. Run `./tool/pub_get.sh` to get dependencies for all packages.
  4. Do your changes.
  5. When you are done, commit changes with `git add -A` and `git commit`.
  6. Push changes to your personal repository: `git push origin`
  7. Go to [github.com/dint-dev/dint](https://github.com/dint-dev/dint) and create a pull request.

Contributors may be added to the Github organization team so they can save time by pushing
directly to the repository.

# Getting started
## Add dependency
In `pubspec.yaml`, add:
```yaml
dependencies:
  database: any
```

## Construct instance
```dart
import 'package:database/database.dart';

Future<void> main() async {
  //
  // Use in-memory database
  //
  final database = MemoryDatabase();

  // ...
}
```


## Write and read documents
```dart
// Insert
final document = await database.collection('employee').insert({
  'name': 'Jane',
  'title': 'software developer',
  'skills': ['dart'],
});

// Update
await document.update({
  // ...
});

// Read
await snapshot = document.get();

// DElete
await document.delete();
```


### Query documents
```dart
final result = await database.collection('employee').search(
  query: Query.parse('name:(John OR Jane)')
);

for (var snapshot in result.snapshots) {
  // ...
}
```


### Introduction to filters
  * Logical
    * `AndFilter([ValueFilter('f0'), ValueFilter('f1')])`
    * `OrFilter([ValueFilter('f0'), ValueFilter('f1')])`
    * `NotFilter(ValueFilter('example'))`
  * Structural
    * `ListFilter(items: ValueFilter('value'))`
    * `MapFilter({'key': ValueFilter('value')})`
  * Primitive
    * `ValueFilter(3.14)`
    * `RangeFilter(min:3, max:4)`
    * `RangeFilter(min:3, max:4, isExclusiveMin:true, isExclusiveMax:true)`
    * `RangeFilter(min:3, max:4, isExclusiveMin:true, isExclusiveMax:true)`
    * `GeoPointFilter(near:GeoPoint(1.23, 3.45)`
  * SQL filters
    * `SqlFilter('SELECT * FROM table WHERE x ', 3.14)`
  * Natural language filters
    * `KeywordFilter('example')`
      * Keyword queries (`KeyFilter`) are very expensive unless you have configured a search engine such
        as ElasticSearch/Lucene. The default implementation visits every document in the collection
        and does a substring search.
      * To prevent unintentional visit to every document, remote databases should throw
        `UnsuportedError` unless they support keyword search.

### Parsing filters
The package supports parsing query strings. The syntax is inspired by Lucene and Google Search.

```dart
final query = Query.parse('New York Times date:>=2020-01-01');
```

Examples of supported queries:
  * `New York Times`
    * Matches keywords "New", "York", and "Times". The underlying search engine may decide to focus
      on the three words separately, sequence "New York", or sequence "New York Times".
  * `"New York Times"`
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
