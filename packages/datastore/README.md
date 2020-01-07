[![Github Actions CI](https://github.com/terrier989/datastore/workflows/Dart%20CI/badge.svg)](https://github.com/terrier989/datastore/actions?query=workflow%3A%22Dart+CI%22)

# Introduction
This enables Dart developers to use document databases and information retrieval systems.
The package works in all platforms (Flutter, browser, server).
Licensed under the [Apache License 2.0](LICENSE).

__Warning:__ breaking changes are likely before the project freezes the APIs.

## Contributing
Anyone can help this open-source project!

For the first contribution, create a pull request [at Github](https://github.com/terrier989/datastore).

Repeat contributors may be given permission to push directly to the repository. If you have been
granted such permission, code review is not necessary for you.

## General-purpose adapters
  * __BrowserDatastore__ ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/browser_datastore.dart))
    * Uses browser APIs such as _window.localStorage_.
  * __CachingDatastore__ ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/caching_datastore.dart))
    * Caches data in some other datastore.
  * __GrpcDatastore__ ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/grpc_datastore.dart))
    * A [GRPC](https://grpc.io) client. You can also find a server implementation.
  * __MemoryDatastore__ ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/memory_datastore.dart))
    * Stores data in memory.
  * __SchemaUsingDatastore__ ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/schema_using_datastore.dart))
    * Enforces schemas on reads/writes.
  * __SearchableDatastore__
    * A search engine for Flutter / web applications. Found in the package [search](https://pub.dev/packages/search)).

## Adapters for various products
  * __Algolia__ ([website](https://www.algolia.com))
    * Use adapter `Algolia` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/algolia.dart))
    * The adapter is not ready and needs help.
  * __Azure Cosmos DB__ ([website](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction))
    * Use adapter `AzureCosmosDB` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/azure_cosmos_db.dart))
    * The adapter is not ready and needs help.
  * __Azure Cognitive Search__ ([website](https://azure.microsoft.com/en-us/services/search))
    * Use adapter `AzureCognitiveSearch` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/azure_cognitive_search.dart))
    * The adapter is not ready and needs help.
  * __ElasticSearch__ ([website](https://www.elastic.co))
    * Use adapter `ElasticSearch` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/elastic_search.dart))
    * The adapter is not ready and needs help.
  * __Google Cloud Datastore__ ([website](https://cloud.google.com/datastore))
    * Use adapter `GoogleCloudDatastore` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/google_cloud_datastore.dart))
    * The adapter is not ready and needs help.
  * __Google Cloud Firestore__ ([website](https://firebase.google.com/docs/firestore))
    * In browser, use adapter `Firestore` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/google_cloud_firestore_impl_browser.dart))
    * In Flutter, use adapter `FirestoreFlutter` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore_adapter_cloud_firestore/lib/adapter.dart)) in "package:firestore_adapter_cloud_firestore/adapter.dart".
    * The adapter is not ready and needs help.


# Getting started
## Add dependency
In `pubspec.yaml`, add:
```yaml
dependencies:
  datastore: any
```

## Simple usage
```dart
import 'package:datastore/adapters.dart';
import 'package:datastore/datastore.dart';

Future<void> main() async {
  //
  // Set default datastore
  //
  Datastore.freezeDefaultInstance(
    MemoryDatastore(), // <-- Choose the right datastore for you
  );

  //
  // Insert documents
  //
  final datastore = Datastore.defaultInstance;
  datastore.collection('employee').newDocument().insert({
    'name': 'Jane',
    'title': 'software developer',
    'skills': ['dart'],
  });
  datastore.collection('employee').newDocument().insert({
    'name': 'John',
    'title': 'software developer',
    'skills': ['javascript'],
  });

  //
  // Search documents
  //
  final collection = datastore.collection('employee');
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
final document = datastore.collection('greetings').newDocument();

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
final result = await datastore.collection('employee').search(
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
import 'package:datastore_test/datastore_test.dart';

void main() {
  setUp(() {
    Datastore.defaultInstance = MemoryDatastore();
    addTeardown(() {
      Datastore.defaultInstance = null;
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