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

/// Connects the package [database](https://pub.dev/packages/database) to
/// [Algolia](https://www.algolia.io).
library database_adapter_algolia;

import 'dart:convert';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';
import 'package:universal_io/io.dart';

/// An adapter for using [Algolia](https://www.algolia.io).
///
/// ```dart
/// import 'package:database/database.dart';
/// import 'package:database_adapter_algolia/database_adapter_algolia.dart';
///
/// Database getSearchEngine() {
///   return Algolia(
///     appId: 'Your application ID',
///     apiKey: 'Your API key',
///   );
/// }
/// ```
class Algolia extends DocumentDatabaseAdapter {
  final String appId;
  final String apiKey;

  /// Disables throwing of [UnsupportedError] if query contains sorters.
  final bool allowSortersByIgnoring;

  /// HTTP client used for requests.
  final HttpClient httpClient;

  Algolia({
    @required this.apiKey,
    @required this.appId,
    this.allowSortersByIgnoring = false,
    Uri uri,
    HttpClient httpClient,
  }) : httpClient = httpClient ?? HttpClient() {
    ArgumentError.checkNotNull(apiKey, 'apiKey');
    ArgumentError.checkNotNull(appId, 'appId');
    if (apiKey.isEmpty || apiKey.contains('\n')) {
      throw ArgumentError.value(apiKey, 'apiKey');
    }
    if (appId.isEmpty || appId.contains('.') || appId.contains('\n')) {
      throw ArgumentError.value(appId, 'appId');
    }
  }

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final collectionId = _validateCollectionId(collection.collectionId);
    final documentId = _validateDocumentId(document.documentId);

    if (request.mustExist) {
      //
      // Check existence
      //
      final resp = await _apiRequest(
        method: 'GET',
        path: '/1/indexes/$collectionId/$documentId',
      );
      if (resp.statusCode == HttpStatus.notFound) {
        throw DatabaseException.notFound(document);
      }
    }

    //
    // Dispatch request
    //
    final apiResponse = await _apiRequest(
      method: 'DELETE',
      path: '/1/indexes/$collectionId/$documentId',
      isWrite: true,
    );

    //
    // Handle error
    //
    final error = apiResponse.error;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final collectionId = _validateCollectionId(collection.collectionId);
    final documentId = _validateDocumentId(document.documentId);

    //
    // Check existence
    //
    final resp = await _apiRequest(
      method: 'GET',
      path: '/1/indexes/$collectionId/$documentId',
    );
    if (resp.statusCode == HttpStatus.ok) {
      throw DatabaseException.found(document);
    }

    //
    // Dispatch request
    //
    final apiResponse = await _apiRequest(
      method: 'PUT',
      path: '/1/indexes/$collectionId/$documentId',
      bodyJson: request.data,
      isWrite: true,
    );

    //
    // Handle error
    //
    final error = apiResponse.error;
    if (error != null) {
      throw error;
    }
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) async* {
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

    if (apiResponse.statusCode == HttpStatus.notFound) {
      yield (Snapshot.notFound(document));
      return;
    }

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
      vendorData: apiResponse.json,
      document: document,
      data: data,
    ));
  }

  @override
  Stream<QueryResult> performDocumentSearch(
      DocumentSearchRequest request) async* {
    final queryArguments = <String, String>{};

    // Validate index name
    final collection = request.collection;
    final collectionId = _validateCollectionId(collection.collectionId);

    final query = request.query ?? const Query();

    // Query string
    {
      final filter = query.filter;
      if (filter != null) {
        queryArguments['query'] = filter.toString();
      }
    }

    if (query.sorter != null && allowSortersByIgnoring == false) {
      // Sorting order is not supported by Algolia.
      // Each index can have only one sorting order.
      throw UnsupportedError('Sorting is not supported by Algolia');
    }

    // Skip
    var hasSkipOrTake = false;
    {
      final skip = query.skip;
      if (skip != 0) {
        hasSkipOrTake = true;
        queryArguments['offset'] = skip.toString();
      }
    }

    // Take
    {
      final take = query.take;
      if (take != null && take != 0) {
        hasSkipOrTake = true;
        queryArguments['length'] = take.toString();
      }
    }

    // Algolia requires both to be present if one is present
    if (hasSkipOrTake) {
      queryArguments['offset'] ??= '0';
      queryArguments['length'] ??= '10';
    }

    // Dispatch request
    final apiResponse = await _apiRequest(
      method: 'GET',
      path: '/1/indexes/$collectionId',
      queryParameters: queryArguments,
    );

    if (apiResponse.statusCode == HttpStatus.notFound) {
      //
      // No such collection
      //
      yield (QueryResult(
        collection: collection,
        query: query,
        snapshots: const <Snapshot>[],
      ));
      return;
    }

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
        jsonHit.forEach((name, value) {
          switch (name) {
            case 'objectID':
              documentId = value as String;
              break;
            case '_rankingInfo':
              if (value is Map) {
                score = (value['userScore'] as num).toDouble();
              }
              break;
            default:
              data[name] = value;
              break;
          }
        });

        //
        // Return snapshot
        //
        return QueryResultItem(
          vendorData: jsonHit,
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
      vendorData: apiResponse.json,
      collection: collection,
      query: query,
      items: items,
    ));
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final collectionId = _validateCollectionId(collection.collectionId);
    final documentId = _validateDocumentId(document.documentId);

    //
    // Check existence
    //
    final resp = await _apiRequest(
      method: 'GET',
      path: '/1/indexes/$collectionId/$documentId',
    );
    if (resp.statusCode == HttpStatus.notFound) {
      throw DatabaseException.notFound(document);
    }

    //
    // Dispatch request
    //
    final apiResponse = await _apiRequest(
      method: 'PUT',
      path: '/1/indexes/$collectionId/$documentId',
      bodyJson: request.data,
      isWrite: true,
    );

    //
    // Handle error
    //
    final error = apiResponse.error;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) async {
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
      isWrite: true,
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
    bool isWrite = false,
  }) async {
    //
    // Send HTTP request
    //
    var host = '$appId-dsn.algolia.net';
    if (isWrite) {
      host = '$appId.algolia.net';
    }
    final uri = Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: queryParameters,
    );
    final httpRequest = await httpClient.openUrl(method, uri);
    httpRequest.headers.set('X-Algolia-Application-Id', appId);
    httpRequest.headers.set('X-Algolia-API-Key', apiKey);
    if (bodyJson != null) {
      httpRequest.headers.contentType = ContentType.json;
      httpRequest.write(jsonEncode(bodyJson));
    }
    final httpResponse = await httpRequest.close();
    final statusCode = httpResponse.statusCode;
    final reasonPhrase = httpResponse.reasonPhrase;

    // Read body
    final responseString = await utf8.decodeStream(httpResponse);

    // Check MIME
    final mime = httpResponse.headers.contentType?.mimeType;
    if (mime != ContentType.json.mimeType) {
      throw DatabaseException.internal(
        message:
            '$method $uri --> HTTP $statusCode ($reasonPhrase): invalid mime: "$mime"',
      );
    }

    // Decode JSON
    final responseJson = jsonDecode(responseString);
    DatabaseException error;
    if (statusCode != HttpStatus.ok) {
      final message = responseJson['message'];
      error = DatabaseException.internal(
        message: '$method $uri --> HTTP $statusCode ($reasonPhrase): $message',
      );
    }

    return _Response(statusCode, responseJson, error);
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

class _Response {
  final int statusCode;
  final Map<String, Object> json;
  final DatabaseException error;
  _Response(this.statusCode, this.json, this.error);
}
