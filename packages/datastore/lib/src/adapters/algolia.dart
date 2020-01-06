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

import 'package:datastore/adapters_framework.dart';
import 'package:datastore/datastore.dart';
import 'package:meta/meta.dart';
import 'package:universal_io/prefer_universal/io.dart';

/// An adapter for using [Algolia](https://www.algolia.io),
/// a commercial cloud service by Algolia Inc.
///
/// An example:
/// ```dart
/// import 'package:datastore/datastore.dart';
/// import 'package:datastore/adapters.dart';
///
/// void main() {
///   Datastore.freezeDefaultInstance(
///     Algolia(
///       credentials: AlgoliaCredentials(
///         appId: 'APP ID',
///         apiKey: 'API KEY',
///       ),
///     ),
///   );
///
///   // ...
/// }
class Algolia extends DatastoreAdapter {
  /// Default value for [uri].
  static final _defaultUri = Uri(
    scheme: 'https',
    host: 'algolia.com',
  );

  /// Algoalia credentials.
  final AlgoliaCredentials credentials;

  /// URI where the Algolia server is.
  final Uri uri;

  /// HTTP client used for requests.
  final HttpClient httpClient;

  Algolia({
    @required this.credentials,
    Uri uri,
    HttpClient httpClient,
  })  : uri = uri ?? _defaultUri,
        httpClient = httpClient ?? HttpClient() {
    ArgumentError.checkNotNull(credentials, 'credentials');
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    final document = request.document;
    final collection = document.parent;
    final collectionId = _validateCollectionId(collection.collectionId);
    final documentId = _validateDocumentId(document.documentId);

    //
    // Dispatch request
    //
    final apiResponse = await _apiRequest(
      method: 'GET',
      path: '/1/indexes/$collectionId/$documentId',
    );

    //
    // Handle error
    //
    final error = apiResponse.error;
    if (error != null) {
      throw error;
    }

    // Create data
    final data = <String, Object>{};
    data.addAll(apiResponse.json);
    data.remove('objectID');

    // Yield
    yield (Snapshot(
      document: document,
      data: data,
    ));
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
    final urlQueryArguments = <String, String>{};

    // Validate index name
    final collection = request.collection;
    final collectionId = _validateCollectionId(collection.collectionId);

    final query = request.query;

    // Query
    final filter = query.filter;
    if (filter != null) {
      urlQueryArguments['query'] = filter.toString();
    }

    // Skip
    final skip = query.skip;
    if (skip != 0) {
      urlQueryArguments['offset'] = skip.toString();
    }

    // Take
    final take = query.take;
    if (take != null) {
      urlQueryArguments['length'] = skip.toString();
    }

    // Dispatch request
    final apiResponse = await _apiRequest(
      method: 'GET',
      path: '/1/indexes/$collectionId',
      queryParameters: urlQueryArguments,
    );
    final error = apiResponse.error;
    if (error != null) {
      throw error;
    }

    final jsonHitsList = apiResponse.json['hits'] as List<Object>;

    final items =
        List<QueryResultItem>.unmodifiable(jsonHitsList.map((jsonHit) {
      if (jsonHit is Map<String, Object>) {
        //
        // Declare locals
        //
        String documentId;
        final data = <String, Object>{};
        double score;

        //
        // Visit all properties
        //
        for (var entry in jsonHit.entries) {
          switch (entry.key) {
            case 'objectID':
              documentId = entry.value as String;
              break;
            case '_rankingInfo':
              score = ((entry.value as Map<String, Object>)['userScore'] as num)
                  .toDouble();
              break;
            default:
              data[entry.key] = entry.value;
              break;
          }
        }

        //
        // Return snapshot
        //
        return QueryResultItem(
          snapshot: Snapshot(
            document: collection.document(documentId),
            data: data,
          ),
          score: score,
        );
      } else {
        throw ArgumentError.value(jsonHit);
      }
    }));

    yield (QueryResult.withDetails(
      collection: collection,
      query: query,
      items: items,
    ));
  }

  @override
  Future<void> performWrite(WriteRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final collectionId = _validateCollectionId(collection.collectionId);
    final documentId = _validateDocumentId(document.documentId);

    //
    // Dispatch request
    //
    final apiResponse = await _apiRequest(
      method: 'PUT',
      path: '/1/indexes/$collectionId/$documentId',
      bodyJson: request.data,
    );

    //
    // Handle error
    //
    final error = apiResponse.error;
    if (error != null) {
      throw error;
    }
  }

  Future<_Response> _apiRequest({
    @required String method,
    @required String path,
    Map<String, String> queryParameters,
    Map<String, Object> bodyJson,
  }) async {
    //
    // Send HTTP request
    //
    final baseUri = this.uri;
    final uri = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: path,
      queryParameters: queryParameters,
    );
    final httpRequest = await httpClient.openUrl(method, uri);
    final credentials = this.credentials;
    if (credentials != null) {
      httpRequest.headers.set('X-Algolia-Application-Id', credentials.appId);
      httpRequest.headers.set('X-Algolia-API-Key', credentials.apiKey);
    }
    if (bodyJson != null) {
      httpRequest.headers.contentType = ContentType.json;
      httpRequest.write(jsonEncode(bodyJson));
    }
    final httpResponse = await httpRequest.close();

    //
    // Read HTTP response
    //
    final responseString = await utf8.decodeStream(httpResponse);
    final response = _Response();
    response.json = jsonDecode(responseString);

    //
    // Check HTTP status code
    //
    final statusCode = httpResponse.statusCode;
    if (statusCode != HttpStatus.ok) {
      response.error = AlgoliaException(
        method: method,
        uri: uri,
        statusCode: statusCode,
      );
    }
    return response;
  }

  /// Validates that the ID doesn't contain any potentially dangerous
  /// characters.
  String _validateCollectionId(String s) {
    if (s.contains('/') ||
        s.contains('%') ||
        s.contains('?') ||
        s.contains('#')) {
      throw ArgumentError.value(s);
    }
    return s;
  }

  /// Validates that the ID doesn't contain any potentially dangerous
  /// characters.
  String _validateDocumentId(String s) {
    if (s.contains('/') ||
        s.contains('%') ||
        s.contains('?') ||
        s.contains('#')) {
      throw ArgumentError.value(s);
    }
    return s;
  }
}

/// Credentials required by [Algolia].
class AlgoliaCredentials {
  final String appId;
  final String apiKey;

  const AlgoliaCredentials({this.appId, this.apiKey});

  @override
  int get hashCode => appId.hashCode ^ apiKey.hashCode;

  @override
  bool operator ==(other) =>
      other is AlgoliaCredentials &&
      appId == other.appId &&
      apiKey == other.apiKey;
}

/// An exception thrown by [Algolia].
class AlgoliaException implements Exception {
  final String method;
  final Uri uri;
  final int statusCode;

  AlgoliaException({
    @required this.method,
    @required this.uri,
    @required this.statusCode,
  });
}

class _Response {
  AlgoliaException error;
  Map<String, Object> json;
}
