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
import 'package:universal_io/io.dart';

/// An adapter for using [Azure Cognitive Search](https://azure.microsoft.com/en-us/services/search),
/// a commercial cloud service by Microsoft.
///
/// An example:
/// ```dart
/// import 'package:datastore/adapters.dart';
/// import 'package:datastore/datastore.dart';
///
/// void main() {
///   Datastore.freezeDefaultInstance(
///     AzureCosmosDB(
///       credentials: AzureCognitiveSearchCredentials(
///         apiKey: 'API KEY',
///       ),
///     ),
///   );
///
///   // ...
/// }
class AzureCognitiveSearch extends DatastoreAdapter {
  final AzureCognitiveSearchCredentials _credentials;
  final HttpClient httpClient;

  AzureCognitiveSearch({
    @required AzureCognitiveSearchCredentials credentials,
    HttpClient httpClient,
  })  : assert(credentials != null),
        _credentials = credentials,
        httpClient = httpClient ??= HttpClient() {
    ArgumentError.checkNotNull(credentials, 'credentials');
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    final document = request.document;
    final collection = document.parent;
    final collectionId = collection.collectionId;
    final documentId = document.documentId;
    final response = await _apiRequest(
      method: 'GET',
      path: '/indexes/$collectionId/docs/$documentId',
    );
    yield (Snapshot(
      document: document,
      data: response.json,
    ));
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
    final query = request.query;
    final collection = request.collection;
    final collectionId = collection.collectionId;
    final queryParameters = <String, String>{};

    // filter
    {
      final filter = query.filter;
      if (filter != null) {
        queryParameters['querytype'] = 'full';
        queryParameters['search'] = filter.toString();
        queryParameters['searchmode'] = 'all';
      }
    }

    // orderBy
    {
      final sorter = query.sorter;
      if (sorter != null) {
        if (sorter is MultiSorter) {
          queryParameters['orderby'] = sorter.sorters
              .whereType<PropertySorter>()
              .map((s) => s.name)
              .join(',');
        } else if (sorter is PropertySorter) {
          queryParameters['orderby'] = sorter.name;
        }
      }
    }

    // skip
    {
      final skip = query.skip ?? 0;
      if (skip != 0) {
        queryParameters[r'$skip'] = skip.toString();
      }
    }

    // take
    {
      final take = query.take;
      if (take != null) {
        queryParameters[r'$top'] = take.toString();
      }
    }

    // Dispatch request
    final response = await _apiRequest(
      method: 'GET',
      path: '/indexes/$collectionId/docs',
      queryParameters: queryParameters,
    );

    // Return response
    final hitsJson = response.json['hits'] as Map<String, Object>;
    final hitsListJson = hitsJson['hit'] as List;
    yield (QueryResult(
      collection: collection,
      query: query,
      snapshots: List<Snapshot>.unmodifiable(hitsListJson.map((json) {
        final documentId = json['_id'] as String;
        final document = collection.document(documentId);
        final data = <String, Object>{};
        data.addAll(json);
        return Snapshot(
          document: document,
          data: data,
        );
      })),
    ));
  }

  @override
  Future<void> performWrite(WriteRequest request) async {
    final document = request.document;
    final collection = document.parent;
    final collectionId = collection.collectionId;
    final documentId = document.documentId;
    final json = <String, Object>{};
    json.addAll(request.data);
    json['@search.action'] = 'update';
    json['_id'] = documentId;
    await _apiRequest(
      method: 'POST',
      path: '/indexes/$collectionId/docs/index',
      json: json,
    );
  }

  Future<_Response> _apiRequest({
    @required String method,
    @required String path,
    Map<String, String> queryParameters,
    Map<String, Object> json,
  }) async {
    final serviceName = _credentials.serviceId;

    // Query parameters
    queryParameters ??= <String, String>{};
    queryParameters['api-version'] = '2019-05-06';

    // ?URI
    final uri = Uri(
      scheme: 'https',
      host: '$serviceName.search.windows.net',
      path: path,
      queryParameters: queryParameters,
    );

    // Dispatch HTTP request
    final httpRequest = await httpClient.openUrl(method, uri);
    httpRequest.headers.set('api-key', _credentials.apiKey);
    if (json != null) {
      httpRequest.headers.contentType = ContentType.json;
      httpRequest.write(jsonEncode(json));
    }
    final httpResponse = await httpRequest.close();

    // Read HTTP response body
    final httpResponseBody = await utf8.decodeStream(httpResponse);

    // Handle error
    final statusCode = httpResponse.statusCode;
    if (statusCode != HttpStatus.ok) {
      throw AzureCognitiveSearchException(
        method: method,
        uri: uri,
        statusCode: statusCode,
      );
    }

    // Return response
    final response = _Response();
    response.json = jsonDecode(httpResponseBody);
    return response;
  }
}

class AzureCognitiveSearchCredentials {
  final String serviceId;
  final String apiKey;

  const AzureCognitiveSearchCredentials({
    @required this.serviceId,
    @required this.apiKey,
  })  : assert(serviceId != null),
        assert(apiKey != null);

  @override
  int get hashCode => serviceId.hashCode ^ apiKey.hashCode;

  @override
  bool operator ==(other) =>
      other is AzureCognitiveSearchCredentials &&
      serviceId == other.serviceId &&
      apiKey == other.apiKey;
}

/// An exception thrown by [AzureCognitiveSearch].
class AzureCognitiveSearchException {
  final String method;
  final Uri uri;
  final int statusCode;

  AzureCognitiveSearchException({
    this.method,
    this.uri,
    this.statusCode,
  });

  @override
  String toString() => '$method $uri --> HTTP status $statusCode';
}

class _Response {
  Map<String, Object> json;
}
