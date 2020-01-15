[![Pub Package](https://img.shields.io/pub/v/database_adapter_elasticsearch.svg)](https://pub.dartlang.org/packages/database_adapter_elasticsearch)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Overview
This is an adapter between [database](https://pub.dev/packages/database) and [ElasticSearch](https://www.elastic.co).

## Links
  * [API documentation](https://pub.dev/documentation/database_adapter_elasticsearch/latest/database_adapter_elasticsearch/ElasticSearch-class.html)
  * [Github source code](https://github.com/dint-dev/database/tree/master/adapters/elasticsearch/lib/database_adapter_elasticsearch.dart)

# Getting started
```dart
// Set up
final database = ElasticSearch(
  credentials: ElasticSearchPasswordCredentials(
    user: 'example user',
    password: 'example password'
  ),
);

// Insert a document
final document = await database.collection('example').insert({
  'greeting': 'Hello world!'
});

// Search documents
final results = await database.collection('example').search(
  query: Query.parse(
    'world hello',
    skip: 0,
    take: 10,
  )',
});
```