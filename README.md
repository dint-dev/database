[![Github Actions CI](https://github.com/terrier989/datastore/workflows/Dart%20CI/badge.svg)](https://github.com/terrier989/datastore/actions?query=workflow%3A%22Dart+CI%22)

# Overview
This projects aims to help Dart developers use database and information retrieval products.

__Warning:__ breaking changes are likely before the project freezes the APIs.

## Contributing
Anyone can help this open-source project!

For the first contribution, create [a pull request at Github](https://github.com/terrier989/datastore).

Repeat contributors may be given Github permissions to push directly into the repository. If you
have been granted such permission, code review is not necessary for you (but it's still a good
habit).

## Dart packages in this repository
### "datastore"
  * The main package.
  * [Pub package](https://pub.dev/packages/datastore)
  * [API reference](https://pub.dev/documentation/datastore/latest/)

### "search"
  * A search engine for applications that want search to work offline.
  * [Pub package](https://pub.dev/packages/search)
  * [API reference](https://pub.dev/documentation/search/latest/)

### Other
  * [datastore_adapter_cloud_firestore](packages/datastore_adapter_cloud_firestore)

## Available adapters
### General-purpose
  * __BrowserDatastore__ ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/BrowserDatastore-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/browser_datastore.dart))
    * Uses browser APIs such as _window.localStorage_.
  * __CachingDatastore__ ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/CachingDatastore-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/caching_datastore.dart))
    * Caches data in some other datastore.
  * __GrpcDatastore__ ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/GrpcDatastore-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/grpc_datastore.dart))
    * A [GRPC](https://grpc.io) client. You can also find a server implementation.
  * __MemoryDatastore__ ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/MemoryDatastore-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/memory_datastore.dart))
    * Stores data in memory.
  * __SchemaUsingDatastore__ ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/SchemaUsingDatastore-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/schema_using_datastore.dart))
    * Enforces schemas on reads/writes.
  * __SearchableDatastore__
    * A search engine for Flutter / web applications. Found in the package [search](https://pub.dev/packages/search).

### For using various products
  * __Algolia__ ([website](https://www.algolia.com))
    * Use adapter `Algolia` ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/Algolia-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/algolia.dart))
    * The adapter does not pass all tests. You can help!
  * __Azure Cosmos DB__ ([website](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction))
    * Use adapter `AzureCosmosDB` ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/AzureCosmosDB-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/azure_cosmos_db.dart))
    * The adapter does not pass all tests. You can help!
  * __Azure Cognitive Search__ ([website](https://azure.microsoft.com/en-us/services/search))
    * Use adapter `AzureCognitiveSearch` ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/AzureCognitiveSearch-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/azure_cognitive_search.dart))
    * The adapter does not pass all tests. You can help!
  * __ElasticSearch__ ([website](https://www.elastic.co))
    * Use adapter `ElasticSearch` ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/ElasticSearch-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/elastic_search.dart))
    * The adapter does not pass all tests. You can help!
  * __Google Cloud Datastore__ ([website](https://cloud.google.com/datastore))
    * Use adapter `GoogleCloudDatastore` ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/GoogleCloudDatastore-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/google_cloud_datastore.dart))
    * The adapter does not pass all tests. You can help!
  * __Google Cloud Firestore__ ([website](https://firebase.google.com/docs/firestore))
    * In browser, use adapter `Firestore` ([API](https://pub.dev/documentation/datastore/latest/datastore.adapters/Firestore-class.html), [source](https://github.com/terrier989/datastore/tree/master/packages/datastore/lib/src/adapters/google_cloud_firestore_impl_browser.dart))
    * In Flutter, use adapter `FirestoreFlutter` ([source](https://github.com/terrier989/datastore/tree/master/packages/datastore_adapter_cloud_firestore/lib/adapter.dart)) in "package:firestore_adapter_cloud_firestore/adapter.dart".
    * The adapter does not pass all tests. You can help!

# Getting started
Go to [documentation](packages/datastore).