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

import 'dart:convert';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';
import 'package:universal_io/io.dart';
import 'package:database_adapter_elasticsearch/database_adapter_elasticsearch.dart';

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
  final bool autoCreateIndex;

  ElasticSearch({
    @required String host,
    int port = 9200,
    String scheme = 'http',
    ElasticSearchCredentials credentials,
    HttpClient httpClient,
    bool autoCreateIndex = true,
  }) : this.withUri(
          Uri(
            scheme: scheme,
            host: host,
            port: port,
            path: '/',
          ),
          credentials: credentials,
          httpClient: httpClient,
          autoCreateIndex: autoCreateIndex,
        );

  ElasticSearch.withUri(
    this.uri, {
    ElasticSearchCredentials credentials,
    HttpClient httpClient,
    this.autoCreateIndex = true,
  })  : _credentials = credentials,
        httpClient = httpClient ?? HttpClient() {
    if (credentials != null) {
      credentials.prepareHttpClient(this, httpClient);
    }
    ArgumentError.checkNotNull(autoCreateIndex, 'autoCreateIndex');
  }

  @override
  Future<void> checkHealth({Duration timeout}) async {
    await _httpRequest(
      'GET',
      '/',
      timeout: timeout,
    );
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
      '/$collectionId/_doc/$documentId',
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

    switch (response.status) {
      case HttpStatus.ok:
        break;

      case HttpStatus.notFound:
        yield (Snapshot.notFound(request.document));
        return;

      default:
        throw DatabaseException.internal(
          message: 'Got HTTP status: ${response.status}',
        );
    }

    //
    // Return snapshot
    //
    final data = response.body['_source'];
    yield (Snapshot(
      document: request.document,
      versionId: response.body['_seq_no']?.toString(),
      data: schema.decodeLessTyped(data,
          context: LessTypedDecodingContext(
            database: database,
          )),
    ));
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request,
      {bool autoCreateIndex}) async* {
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

    //
    // Filter
    //
    final query = request.query;
    final filter = query.filter;
    if (filter != null) {
      jsonRequest['query'] = {
        'query_string': {
          'query': filter.toString(),
        },
      };
    }

    //
    // Sort
    //

    final sorter = query.sorter;
    if (sorter != null) {
      final jsonSorters = [];
      if (sorter is PropertySorter) {
        jsonSorters.add({sorter.name: sorter.isDescending ? 'desc' : 'asc'});
      } else if (sorter is MultiSorter) {
        for (var item in sorter.sorters) {
          if (item is PropertySorter) {
            jsonSorters.add({item.name: item.isDescending ? 'desc' : 'asc'});
          } else {
            throw UnsupportedError('Unsupported sorter: $item');
          }
        }
      } else {
        throw UnsupportedError('Unsupported sorter: $sorter');
      }
      jsonRequest['sort'] = jsonSorters;
    }

    //
    // Skip
    //
    {
      final skip = query.skip;
      if (skip != null && skip != 0) {
        jsonRequest['from'] = skip;
      }
    }

    //
    // Take
    //
    {
      final take = query.take;
      if (take != null) {
        jsonRequest['size'] = take;
      }
    }

    //
    // Send HTTP request
    //
    final response = await _httpRequest(
      'POST',
      '/$collectionId/_search',
      json: jsonRequest,
    );

    //
    // Handle error
    //
    final error = response.error;
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

    switch (response.status) {
      case HttpStatus.ok:
        break;

      default:
        throw DatabaseException.internal(
          message: 'Got HTTP status: ${response.status}',
        );
    }

    var items = const <QueryResultItem>[];
    final jsonHitsMap = response.body['hits'];
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
            versionId: h['_seq_no']?.toString(),
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
    bool autoCreateIndex,
  }) async {
    final document = request.document;
    final collection = document.parent;
    final schema = request.schema ?? const ArbitraryTreeSchema();
    autoCreateIndex ??= this.autoCreateIndex;

    //
    // Validate IDs
    //
    final documentId = _validateDocumentId(document.documentId);
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Determine method and body
    //
    var method = 'PUT';
    var path = '/$collectionId/_doc/$documentId';
    final queryParameters = {
      'refresh': 'true',
    };
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
        path = '/$collectionId/_create/$documentId';
        queryParameters['op_type'] = 'create';
        json = schema.encodeLessTyped(request.data);
        break;

      case WriteType.update:
        final response = await _httpRequest(
          'GET',
          '/$collectionId/_doc/$documentId',
        );
        if (response.status != HttpStatus.ok) {
          throw DatabaseException.notFound(
            document,
            message: "can't update non-existing document",
            error: response.error,
          );
        }
        queryParameters['if_primary_term'] =
            response.body['_primary_term'].toString();
        queryParameters['if_seq_no'] = response.body['_seq_no'].toString();
        method = 'POST';
        path = '/$collectionId/_update/$documentId';
        json = <String, Object>{
          'doc': schema.encodeLessTyped(request.data),
        };
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
      path,
      queryParameters: queryParameters,
      json: json,
    );

    //
    // Handle error
    //
    final error = response.error;
    if (error != null) {
      switch (error.type) {
        case 'index_not_found_exception':
          if (request.type == WriteType.deleteIfExists) {
            return;
          }
          if (request.type == WriteType.delete) {
            throw DatabaseException.notFound(request.document);
          }
          if (autoCreateIndex) {
            //
            // Create index
            //
            final response = await _httpRequest('PUT', '/$collectionId');
            final responseError = response.error;
            if (responseError != null) {
              throw responseError;
            }

            //
            // Try again
            //
            return performWrite(request, autoCreateIndex: false);
          }

          //
          // We are not allowed to create an index
          //
          throw DatabaseException.internal(
            document: request.document,
            message: 'ElasticSearch index was not found',
          );
      }
    }
    switch (response.status) {
      case HttpStatus.ok:
        if (request.type == WriteType.delete) {
          final result = response.body['result'];
          if (result != 'deleted') {
            throw DatabaseException.notFound(
              document,
              error: ElasticSearchError.fromJson(response.body),
            );
          }
        }
        break;

      case HttpStatus.conflict:
        if (request.type == WriteType.delete) {
          throw DatabaseException.notFound(
            document,
            error: ElasticSearchError.fromJson(response.body),
          );
        }
        break;

      case HttpStatus.created:
        break;

      case HttpStatus.found:
        if (request.type == WriteType.delete) {
          throw DatabaseException.found(
            document,
            error: ElasticSearchError.fromJson(response.body),
          );
        }
        if (request.type == WriteType.insert) {
          throw DatabaseException.found(
            request.document,
            error: ElasticSearchError.fromJson(response.body),
          );
        }
        break;

      case HttpStatus.notFound:
        if (request.type == WriteType.deleteIfExists) {
          return;
        }
        throw DatabaseException.notFound(
          request.document,
          error: ElasticSearchError.fromJson(response.body),
        );

      default:
        throw DatabaseException.internal(
          message:
              'ElasticSearch URI $path, got HTTP status: ${response.status}',
          error: ElasticSearchError.fromJson(response.body),
        );
    }
    if (request.type == WriteType.insert &&
        response.status != HttpStatus.created) {
      throw DatabaseException.found(
        request.document,
        error: ElasticSearchError.fromJson(response.body),
      );
    }
  }

  @protected
  Object valueToJson(Object value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      if (value.isNaN) {
        return 'nan';
      }
      if (value == double.negativeInfinity) {
        return '-inf';
      }
      if (value == double.infinity) {
        return '+inf';
      }
    }
    if (value is DateTime) {
      return value.toIso8601String().replaceAll(' ', 'T');
    }
    throw ArgumentError.value(value);
  }

  Future<_Response> _httpRequest(
    String method,
    String path, {
    Map<String, String> queryParameters = const {},
    Map<String, Object> json,
    Duration timeout,
  }) async {
    // Open HTTP request
    final uri =
        this.uri.resolve(path).replace(queryParameters: queryParameters);
    final httpRequest = await httpClient.openUrl(
      method,
      uri,
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
    final response = await httpRequest.close();

    // Read HTTP response body
    timeout ??= const Duration(seconds: 5);
    final responseBody = await utf8.decodeStream(
      response.timeout(timeout),
    );

    // Decode JSON
    final jsonResponse = jsonDecode(responseBody) as Map<String, Object>;

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
      status: response.statusCode,
      body: jsonDecode(responseBody),
      error: error,
    );
  }

  static final _idRegExp = RegExp(r'[^\/*?"<>| ,#]{1,64}');

  static String _validateCollectionId(String id) {
    if (!_idRegExp.hasMatch(id)) {
      throw ArgumentError.value(id);
    }
    return id.toLowerCase();
  }

  static String _validateDocumentId(String id) {
    if (!_idRegExp.hasMatch(id)) {
      throw ArgumentError.value(id);
    }
    return id;
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
