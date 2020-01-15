[![Pub Package](https://img.shields.io/pub/v/database_adapter_elasticsearch.svg)](https://pub.dartlang.org/packages/database_adapter_elasticsearch)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)

# Overview
This package enables you to use the package [database](https://pub.dev/packages/database) with
[Elasticsearch](https://www.elastic.co), a search engine product.

## Links
  * [API documentation](https://pub.dev/documentation/database_adapter_elasticsearch/latest/database_adapter_elasticsearch/ElasticSearch-class.html)
  * [Issue tracker in Github](https://github.com/dint-dev/database/issues)
  * [Source code in Github](https://github.com/dint-dev/database/tree/master/adapters/elasticsearch/lib/)

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