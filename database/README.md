[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Introduction
This package aims to help Dart developers use database and information retrieval products.

We would like to support the following types of products in an unified API:
  * __SQL databases__
  * __Document databases__
  * __Search engines__

Supporting several different database paradigms in one API is somewhat unconventional. It carries a risk of confusing developers. There are also advantages. We try the current approach in the early versions, and if it doesn't seem right, split the unified API into multiple traditional APIs.

Any feedback on the design is appreciated.

The project is licensed under the [Apache License 2.0](LICENSE).

## API reference
  * [pub.dev/documentation/database/latest/](https://pub.dev/documentation/database/latest/)
  * __Warning:__ you should expect many breaking changes before the project freezes the APIs.

## Available adapters
### Built-in adapters
  * __CachingDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/CachingDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/caching_database.dart))
    * Caches data in some other database.
  * __MemoryDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/MemoryDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/memory_database.dart))
    * Stores data in memory.
  * __SchemaUsingDatabase__ ([API](https://pub.dev/documentation/database/latest/database.adapters/SchemaUsingDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/packages/database/lib/src/adapters/schema_using_database.dart))
    * Enforces schemas on reads/writes.

### Adapters in other package
  * __database_adapter_browser__
    * Use adapter `BrowserDatabase` ([API](https://pub.dev/documentation/database_adapter_browser/latest/database_adapter_browser/BrowserDatabase-class.html), [source](https://github.com/dint-dev/database/tree/master/adapters/browser/lib/))
    * By default, uses [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API)
      (`window.localStorage`).
  * __database_adapter_elastic_search__
    * Implements support for ElasticSearch__ ([website](https://www.elastic.co))
      * Use adapter `ElasticSearch` ([API](https://pub.dev/documentation/database_adapter_elastic_search/latest/database_adapter_elastic_search/ElasticSearch-class.html), [source](https://github.com/dint-dev/database/tree/master/adapters/elastic_search/lib/))
  * __search__ ([Pub](https://pub.dev/packages/search))
    * A very simple keyword search engine for Flutter / web applications. Only suitable for small
      text collections.

_Do you have a package? Add it in the list above here by creating an issue!_

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

## Simple usage
```dart
import 'package:database/adapters.dart';
import 'package:database/database.dart';

Future<void> main() async {
  //
  // Use in-memory database
  //
  final database = MemoryDatabase();
  database.addMapper();

  //
  // Insert document
  //
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

# Adapters in the incubator
These are, for most part, not ready for use:
  * __database_adapter_algolia__
    * Implements support for Algolia ([website](https://www.algolia.com))
      * Use adapter `Algolia` ([source](https://github.com/dint-dev/database/tree/master/adapters_incubator/gcloud/lib/))
  * __database_adapter_azure__
    * Implements support for Azure Cosmos DB ([website](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction))
      * `AzureCosmosDB` ([source](https://github.com/dint-dev/database/tree/master/adapters_incubator/azure/lib/))
    * Implements support for Azure Cognitive Search ([website](https://azure.microsoft.com/en-us/services/search))
      * Use adapter `AzureCognitiveSearch` ([source](https://github.com/dint-dev/database/tree/master/adapters_incubator/azure/lib/))
  * __database_adapter_gcloud__
    * Implements support for Google Cloud Database ([website](https://cloud.google.com/database))
      * Use adapter `GoogleCloudDatastore` ([source](https://github.com/dint-dev/database/tree/master/adapters_incubator/gcloud/lib/))
  * __database_adapter_firestore__
    * Implements browser-onyl support for Google Cloud Firestore ([website](https://firebase.google.com/docs/firestore))
    * Use adapter `Firestore` ([source](https://github.com/dint-dev/database/tree/master/adapters_incubator/firestore/lib/))
  * __database_adapter_firestore_flutter__
    * Implements Flutter-only support for Google Cloud Firestore ([website](https://firebase.google.com/docs/firestore))
    * In Flutter, use adapter `FirestoreFlutter` ([source](https://github.com/dint-dev/database/tree/master/adapters_incubator/firestore_flutter/lib/))



