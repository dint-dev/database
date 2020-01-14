// Copyright 2019 terrier989@gmail.com.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// An adapter for using [ElasticSearch](https://www.elastic.co),
/// a software product by Elastic NV.
library database_adapter_elastic_search;

import 'dart:convert';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';
import 'package:universal_io/io.dart';

/// An adapter for using [ElasticSearch](https://www.elastic.co),
/// a software product by Elastic NV.
///
/// An example:
/// ```dart
/// import 'package:database/adapters.dart';
/// import 'package:database/database.dart';
///
/// void main() {
///   final database = ElasticSearch(
///     host: 'localhost',
///   );
///
///   // ...
/// }
/// ```
class ElasticSearch extends DatabaseAdapter {
  final Uri uri;
  final HttpClient httpClient;
  final ElasticSearchCredentials _credentials;

  ElasticSearch({
    @required String host,
    int port = 9200,
    String scheme = 'http',
    ElasticSearchCredentials credentials,
    HttpClient httpClient,
  }) : this._withUri(
          Uri(
            scheme: scheme,
            host: host,
            port: port,
            path: '/',
          ),
          credentials: credentials,
          httpClient: httpClient,
        );

  ElasticSearch._withUri(
    this.uri, {
    ElasticSearchCredentials credentials,
    HttpClient httpClient,
  })  : _credentials = credentials,
        httpClient = httpClient ?? HttpClient() {
    if (credentials != null) {
      credentials.prepareHttpClient(this, httpClient);
    }
  }

  @override
  Future<void> checkHealth({Duration timeout}) async {
    await _httpRequest('GET', '', timeout: timeout);
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    final document = request.document;
    final collection = document.parent;
    final database = collection.database;
    final schema = request.schema ?? const ArbitraryTreeSchema();

    //
    // Validate IDs
    //
    final documentId = _validateDocumentId(document.documentId);
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Send HTTP request
    //
    final response = await _httpRequest(
      'GET',
      '${collectionId.toLowerCase()}/_doc/$documentId',
    );

    //
    // Handle error
    //
    final error = response.error;
    if (error != null) {
      switch (error.type) {
        case 'index_not_found_exception':
          yield (null);
          return;
      }
      throw error;
    }

    //
    // Handle not found
    //
    final found = response.body['found'] as bool;
    if (!found) {
      yield (Snapshot.notFound(request.document));
      return;
    }
    final data = response.body['_source'];

    //
    // Return snapshot
    //
    yield (Snapshot(
      document: request.document,
      data: schema.decodeLessTyped(data,
          context: LessTypedDecodingContext(
            database: database,
          )),
    ));
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
    final collection = request.collection;
    final database = collection.database;
    final schema = request.schema ?? const ArbitraryTreeSchema();

    //
    // Validate collection ID
    //
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Construct request
    //
    final jsonRequest = <String, Object>{};

    // Filter
    final query = request.query;
    final filter = query.filter;
    if (filter != null) {
      jsonRequest['query'] = {
        'query_string': {
          'query': filter.toString(),
        },
      };
    }

    // TODO: Sorting
    if (query.sorter != null) {
      // jsonRequest['sort'] = ['_score'];
      throw UnimplementedError('Sorting is not supported at the moment');
    }

    // Skip
    {
      final skip = query.skip;
      if (skip != null && skip != 0) {
        jsonRequest['from'] = skip;
      }
    }

    // Take
    {
      final take = query.take;
      if (take != null) {
        jsonRequest['size'] = take;
      }
    }

    //
    // Send HTTP request
    //
    final httpResponse = await _httpRequest(
      'POST',
      '/${collectionId.toLowerCase()}/_search',
      json: jsonRequest,
    );

    //
    // Handle error
    //
    final error = httpResponse.error;
    if (error != null) {
      switch (error.type) {
        case 'index_not_found_exception':
          yield (QueryResult(
            collection: collection,
            query: query,
            snapshots: const <Snapshot>[],
            count: 0,
          ));
          return;
      }
      throw error;
    }

    var items = const <QueryResultItem>[];
    final jsonHitsMap = httpResponse.body['hits'];
    if (jsonHitsMap is Map) {
      // This map contains information about hits

      // The following list contains actual hits
      final jsonHitsList = jsonHitsMap['hits'] as List;
      items = jsonHitsList.map((h) {
        final documentId = h['_id'] as String;
        final score = h['_score'] as double;
        final data = h['_source'] as Map<String, Object>;
        return QueryResultItem(
          snapshot: Snapshot(
            document: collection.document(documentId),
            data: schema.decodeLessTyped(
              data,
              context: LessTypedDecodingContext(database: database),
            ),
          ),
          score: score,
        );
      }).toList();
    }

    yield (QueryResult.withDetails(
      collection: collection,
      query: query,
      items: items,
    ));
  }

  @override
  Future<void> performWrite(
    WriteRequest request, {
    bool createIndex = true,
  }) async {
    final document = request.document;
    final collection = document.parent;
    final schema = request.schema ?? const ArbitraryTreeSchema();

    //
    // Validate IDs
    //
    final documentId = _validateDocumentId(document.documentId);
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Determine method and body
    //
    var method = 'PUT';
    Map<String, Object> json;
    switch (request.type) {
      case WriteType.delete:
        method = 'DELETE';
        break;

      case WriteType.deleteIfExists:
        method = 'DELETE';
        break;

      case WriteType.insert:
        method = 'PUT';
        json = schema.encodeLessTyped(request.data);
        break;

      case WriteType.update:
        method = 'PUT';
        json = schema.encodeLessTyped(request.data);
        break;

      case WriteType.upsert:
        method = 'PUT';
        json = schema.encodeLessTyped(request.data);
        break;

      default:
        throw UnimplementedError();
    }

    //
    // Send HTTP request
    //
    final response = await _httpRequest(
      method,
      '/${collectionId.toLowerCase()}/_doc/$documentId',
      json: json,
    );

    //
    // Handle error
    //
    final error = response.error;
    if (error != null) {
      switch (request.type) {
        case WriteType.delete:
          switch (error.type) {
            case 'index_not_found_exception':
              return;
          }
          break;

        case WriteType.deleteIfExists:
          switch (error.type) {
            case 'index_not_found_exception':
              return;
          }
          break;

        default:
          break;
      }
      throw error;
    }
  }

  @protected
  Object valueToJson(Object value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    throw ArgumentError.value(value);
  }

  Future<_Response> _httpRequest(
    String method,
    String path, {
    Map<String, Object> json,
    Duration timeout,
  }) async {
    // Open HTTP request
    final httpRequest = await httpClient.openUrl(
      method,
      uri.resolve(path),
    );

    // Set HTTP headers
    _credentials?.prepareHttpClientRequest(this, httpRequest);

    // Write HTTP request body
    if (json != null) {
      httpRequest.headers.contentType = ContentType.json;
      httpRequest.write(jsonEncode(
        json,
        toEncodable: valueToJson,
      ));
    }

    // Close HTTP request
    final httpResponse = await httpRequest.close();

    // Read HTTP response body
    timeout ??= const Duration(seconds: 5);
    final httpResponseBody = await utf8.decodeStream(
      httpResponse.timeout(timeout),
    );

    // Decode JSON
    final jsonResponse = jsonDecode(httpResponseBody) as Map<String, Object>;

    // Handle error
    final jsonError = jsonResponse['error'];
    ElasticSearchError error;
    if (jsonError != null) {
      error = ElasticSearchError.fromJson(
        jsonError,
      );
    }

    // Return response
    return _Response(
      status: httpResponse.statusCode,
      body: jsonDecode(httpResponseBody),
      error: error,
    );
  }

  static String _validateCollectionId(String id) {
    if (id.startsWith('_') ||
        id.contains('/') ||
        id.contains('%') ||
        id.contains('?') ||
        id.contains('#')) {
      throw ArgumentError.value(id, 'id', 'Invalid collection ID');
    }
    return id;
  }

  static String _validateDocumentId(String id) {
    if (id.startsWith('_') ||
        id.contains('/') ||
        id.contains('%') ||
        id.contains('?') ||
        id.contains('#')) {
      throw ArgumentError.value(id, 'id', 'Invalid collection ID');
    }
    return id;
  }
}

/// Superclass for [ElasticSearch] credentials. Currently the only subclass is
/// [ElasticSearchPasswordCredentials].
abstract class ElasticSearchCredentials {
  const ElasticSearchCredentials();

  void prepareHttpClient(
    ElasticSearch engine,
    HttpClient httpClient,
  ) {}

  void prepareHttpClientRequest(
    ElasticSearch engine,
    HttpClientRequest httpClientRequest,
  ) {}
}

class ElasticSearchError {
  final Map<String, Object> detailsJson;

  ElasticSearchError.fromJson(this.detailsJson);

  String get reason => detailsJson['reason'] as String;

  String get type => detailsJson['type'] as String;

  @override
  String toString() {
    final details = const JsonEncoder.withIndent('  ')
        .convert(detailsJson)
        .replaceAll('\n', '\n  ');
    return 'ElasticSearch returned an error of type "$type".\n\nDetails:\n  $details';
  }
}

class ElasticSearchPasswordCredentials extends ElasticSearchCredentials {
  final String user;
  final String password;
  const ElasticSearchPasswordCredentials({this.user, this.password});

  @override
  void prepareHttpClient(
    ElasticSearch database,
    HttpClient httpClient,
  ) {
    httpClient.addCredentials(
      database.uri.resolve('/'),
      null,
      HttpClientBasicCredentials(
        user,
        password,
      ),
    );
  }
}

class _Response {
  final int status;
  final Map<String, Object> body;
  final ElasticSearchError error;

  _Response({
    @required this.status,
    @required this.body,
    @required this.error,
  });

  void checkError() {
    final error = this.error;
    if (error != null) {
      throw error;
    }
  }
}
