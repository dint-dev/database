[![Pub Package](https://img.shields.io/pub/v/database.svg)](https://pub.dartlang.org/packages/database)
[![Github Actions CI](https://github.com/dint-dev/database/workflows/Dart%20CI/badge.svg)](https://github.com/dint-dev/database/actions?query=workflow%3A%22Dart+CI%22)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dint-dev/database)

# Introduction
This is __database.dart__, a vendor-agnostic database access API for [Flutter](https://flutter.io)
and other [Dart](https://dart.dev) projects.

__This version is just an early preview__. The API may undergo many changes until we freeze it.
Anyone is welcome to contribute to the development of this package.

Copyright 2019-2020 Gohilla Ltd. Licensed under [the Apache License 2.0](LICENSE).

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

## Pub packages in this repository
  * [database](database) ([Pub](https://pub.dev/packages/database))
  * [database_adapter_algolia](adapters/algolia) ([Pub](https://pub.dev/packages/database_adapter_algolia))
  * [database_adapter_elasticsearch](adapters/elasticsearch) ([Pub](https://pub.dev/packages/database_adapter_elasticsearch))
  * [database_adapter_firestore_browser](adapters/firestore_browser) ([Pub](https://pub.dev/packages/database_adapter_firestore_browser))
  * [database_adapter_firestore_flutter](adapters/firestore_flutter) ([Pub](https://pub.dev/packages/database_adapter_firestore_flutter))
  * [database_adapter_postgre](adapters/postgre) ([Pub](https://pub.dev/packages/database_adapter_postgre))
  * [database_adapter_sqlite](adapters/sqlite) ([Pub](https://pub.dev/packages/database_adapter_sqlite))
  * [search](search) ([Pub](https://pub.dev/packages/search))

# Getting started

Go to the [main package](database).