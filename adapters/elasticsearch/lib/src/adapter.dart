// Copyright 2019 Gohilla Ltd.
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
import 'package:database/schema.dart';
import 'package:database_adapter_elasticsearch/database_adapter_elasticsearch.dart';
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
class ElasticSearch extends DocumentDatabaseAdapter {
  static final _idRegExp = RegExp(r'[^\/*?"<>| ,#]{1,64}');
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
  Future<void> performCheckConnection({Duration timeout}) async {
    await _httpRequest(
      'GET',
      '/',
      timeout: timeout ?? const Duration(seconds: 1),
    );
  }

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) async {
    final document = request.document;
    final collection = document.parent;

    //
    // Validate IDs
    //
    final documentId = _validateDocumentId(document.documentId);
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Send HTTP request
    //
    final response = await _httpRequest(
      'DELETE',
      '/$collectionId/_doc/$documentId',
    );

    switch (response.status) {
      case HttpStatus.found:
        return;
      case HttpStatus.notFound:
        if (request.mustExist) {
          throw DatabaseException.notFound(request.document);
        }
        return;
      default:
        throw response.error;
    }
  }

  @override
  Future<void> performDocumentInsert(
    DocumentInsertRequest request, {
    bool autoCreateIndex = true,
  }) async {
    final document = request.document;
    final collection = document.parent;
    final schema = request.inputSchema ?? const ArbitraryTreeSchema();

    //
    // Validate IDs
    //
    final documentId = _validateDocumentId(document.documentId);
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Send HTTP request
    //
    final json = schema.encodeWith(JsonEncoder(), request.data);
    final response = await _httpRequest(
      'PUT',
      '/$collectionId/_create/$documentId',
      queryParameters: {
        'op_type': 'create',
      },
      json: json,
    );

    final error = response.error;
    if (error != null) {
      switch (error.type) {
        case 'index_not_found_exception':
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
            return performDocumentInsert(request, autoCreateIndex: false);
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
      case HttpStatus.created:
        return;
      default:
        throw response.error;
    }
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) async* {
    final document = request.document;
    final collection = document.parent;
    final schema = request.outputSchema ?? const ArbitraryTreeSchema();

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
    final decoder = JsonDecoder(database: collection.database);
    yield (Snapshot(
      document: request.document,
      versionId: response.body['_seq_no']?.toString(),
      data: schema.decodeWith(decoder, data),
    ));
  }

  @override
  Stream<QueryResult> performDocumentSearch(DocumentSearchRequest request,
      {bool autoCreateIndex}) async* {
    final collection = request.collection;
    final schema = request.outputSchema ?? const ArbitraryTreeSchema();

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
        final decoder = JsonDecoder(database: collection.database);
        return QueryResultItem(
          snapshot: Snapshot(
            document: collection.document(documentId),
            versionId: h['_seq_no']?.toString(),
            data: schema.decodeWith(decoder, data),
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
  Future<void> performDocumentTransaction(DocumentTransactionRequest request) {
    throw DatabaseException.transactionUnsupported();
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final schema = request.inputSchema ?? const ArbitraryTreeSchema();

    //
    // Validate IDs
    //
    final documentId = _validateDocumentId(document.documentId);
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Check existence
    //
    final existsResponse = await _httpRequest(
      'HEAD',
      '/$collectionId/_doc/$documentId',
    );
    if (existsResponse.status != HttpStatus.ok) {
      throw DatabaseException.notFound(
        document,
        message: "can't update non-existing document",
        error: existsResponse.error,
      );
    }

    //
    // Send HTTP request
    //
    final json = schema.encodeWith(JsonEncoder(), request.data);
    final response = await _httpRequest(
      'PUT',
      '/$collectionId/_update/$documentId',
      queryParameters: {
        'if_primary_term': existsResponse.body['_primary_term'].toString(),
        'if_seq_no': existsResponse.body['_seq_no'].toString(),
      },
      json: json,
    );

    switch (response.status) {
      case HttpStatus.ok:
        return;
      default:
        throw response.error;
    }
  }

  @override
  Future<void> performDocumentUpsert(
    DocumentUpsertRequest request, {
    bool autoCreateIndex = true,
  }) async {
    final document = request.document;
    final collection = document.parent;
    final schema = request.inputSchema ?? const ArbitraryTreeSchema();

    //
    // Validate IDs
    //
    final documentId = _validateDocumentId(document.documentId);
    final collectionId = _validateCollectionId(collection.collectionId);

    //
    // Send HTTP request
    //
    final json = schema.encodeWith(JsonEncoder(), request.data);
    final response = await _httpRequest(
      'PUT',
      '/$collectionId/_doc/$documentId',
      json: json,
    );

    final error = response.error;
    if (error != null) {
      switch (error.type) {
        case 'index_not_found_exception':
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
            return performDocumentUpsert(
              request,
              autoCreateIndex: false,
            );
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
      case HttpStatus.created:
        return;
      case HttpStatus.ok:
        return;
      default:
        throw response.error;
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
