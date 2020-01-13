[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Introduction
This enables Dart developers to use document databases and information retrieval systems.
The package works in all platforms (Flutter, browser, server).
Licensed under the [Apache License 2.0](LICENSE).

__Warning:__ breaking changes are likely before the project freezes the APIs.

## Contributing
Anyone can help this open-source project!

For the first contribution, create [a pull request at Github](https://github.com/dint-dev/database).

Repeat contributors may be given Github permissions to push directly into the repository. If you
have been granted such permission, code review is not necessary for you (but it's still a good
habit).

## API reference
  * [pub.dev/documentation/database/latest/](https://pub.dev/documentation/database/latest/)

## Available adapters
### General-purpose
  * __BrowserDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/BrowserDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/browser_database.dart))
    * Uses browser APIs such as _window.localStorage_.
  * __CachingDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/CachingDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/caching_database.dart))
    * Caches data in some other database.
  * __GrpcDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/GrpcDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/grpc_database.dart))
    * A [GRPC](https://grpc.io) client. You can also find a server implementation.
  * __MemoryDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/MemoryDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/memory_database.dart))
    * Stores data in memory.
  * __SchemaUsingDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/SchemaUsingDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/schema_using_database.dart))
    * Enforces schemas on reads/writes.
  * __SearchableDatabase__
    * A search engine for Flutter / web applications. Found in the package [search](https://pub.dev/packages/search).

### For using various products
  * __Algolia__ ([website](https://www.algolia.com))
    * Use adapter `Algolia` ([API](https://pub.dev/documentation/database_adapters/latest/database_adapters.algolia/Algolia-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database_adapters/lib/algolia.dart))
    * The adapter does not pass all tests. You can help!
  * __Azure Cosmos DB__ ([website](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction))
    * Use adapter `AzureCosmosDB` ([API](https://pub.dev/documentation/database_adapters/latest/database_adapters.azure_cosmos_db/AzureCosmosDB-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database_adapters/lib/azure_cosmos_db.dart))
    * The adapter does not pass all tests. You can help!
  * __Azure Cognitive Search__ ([website](https://azure.microsoft.com/en-us/services/search))
    * Use adapter `AzureCognitiveSearch` ([API](https://pub.dev/documentation/database_adapters/latest/database_adapters.azure_cognitive_search/AzureCognitiveSearch-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database_adapters/lib/azure_cognitive_search.dart))
    * The adapter does not pass all tests. You can help!
  * __ElasticSearch__ ([website](https://www.elastic.co))
    * Use adapter `ElasticSearch` ([API](https://pub.dev/documentation/ddatabase_adapters/latest/database_adapters.elastic_search/ElasticSearch-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database_adapters/lib/elastic_search.dart))
    * The adapter does not pass all tests. You can help!
  * __Google Cloud Database__ ([website](https://cloud.google.com/database))
    * Use adapter `GoogleCloudDatastore` ([API](https://pub.dev/documentation/database_adapters/latest/database_adapters.google_cloud_database/GoogleCloudDatastore-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database_adapters/lib/google_cloud_database.dart))
    * The adapter does not pass all tests. You can help!
  * __Google Cloud Firestore__ ([website](https://firebase.google.com/docs/firestore))
    * In browser, use adapter `Firestore` ([API](https://pub.dev/documentation/database_adapters/latest/database_adapters.firestore/Firestore-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/google_cloud_firestore_impl_browser.dart))
    * In Flutter, use adapter `FirestoreFlutter` ([source](https://github.com/dint-dev/database/tree/master/packages/database_adapter_cloud_firestore/lib/adapter.dart)) in "package:firestore_adapter_cloud_firestore/adapter.dart".
    * The adapter does not pass all tests. You can help!


# Getting started
## Add dependency
In `pubspec.yaml`, add:
```yaml
dependencies:
  database: any
```

## Simple usage
```dart
import 'package:database/adapters.dart';
import 'package:database/database.dart';

Future<void> main() async {
  //
  // Set default database
  //
  Database.freezeDefaultInstance(
    MemoryDatabase(), // <-- Choose the right database for you
  );

  //
  // Insert documents
  //
  final database = Database.defaultInstance;
  database.collection('employee').newDocument().insert({
    'name': 'Jane',
    'title': 'software developer',
    'skills': ['dart'],
  });
  database.collection('employee').newDocument().insert({
    'name': 'John',
    'title': 'software developer',
    'skills': ['javascript'],
  });

  //
  // Search documents
  //
  final collection = database.collection('employee');
  final response = await collection.search(
    query: Query.parse(
      '"software developer" (dart OR javascript)'
      skip: 0,
      take: 10,
    ),
  );
}
```

# Recipes
## Insert, update, delete
```dart
// Generate a random 128-bit identifier for our document
final document = database.collection('greetings').newDocument();

// Insert
await document.insert(data:{
  'example': 'initial value',
});

// Upsert ("insert or update")
await document.upsert(data:{
  'example': 'upserted value',
});

// Update
await document.update(data:{
  'example': 'updated value',
})

// Delete
await document.delete();
```

## Searching
```dart
final result = await database.collection('employee').search(
  query: Query.parse('name:(John OR Jane)')
);

for (var snapshot in result.snapshots) {
  // ...
}
```


### Possible filters
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
  * Natural language filters
    * `KeywordFilter('example')`


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


## Testing
```dart
import 'package:database/adapters.dart';
import 'package:database/database.dart';

void main() {
  setUp(() {
    Database.defaultInstance = MemoryDatabase();
    addTeardown(() {
      Database.defaultInstance = null;
    });
  });

  test('example #1', () {
    // ...
  });

  test('example #2', () {
    // ...
  });
}
```