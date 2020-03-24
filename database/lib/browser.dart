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

/// Contains various database adapters that use browser APIs.
///
/// ```dart
/// import 'package:database/browser.dart';
///
/// void main() {
///   final database = BrowserDatabaseAdapter(),
///   // ...
/// }
/// ```
library database.browser;

import 'dart:convert';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/schema.dart';
import 'package:universal_html/html.dart' as html;

String _jsonPointerEscape(String s) {
  return s.replaceAll('~', '~0').replaceAll('/', '~1');
}

String _jsonPointerUnescape(String s) {
  return s.replaceAll('~1', '/').replaceAll('~0', '~');
}

/// A database adapter that stores data using some browser API. The default
/// factory returns an instance of [BrowserLocalStorageDatabase].
///
/// ```dart
/// import 'package:database/browser.dart';
///
/// void main() {
///   final database = BrowserDatabaseAdapter(),
///   // ...
/// }
/// ```
abstract class BrowserDatabaseAdapter implements DatabaseAdapter {
  factory BrowserDatabaseAdapter() {
    return BrowserLocalStorageDatabase();
  }
}

/// A database adapter that stores data using [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API)
/// (`window.localStorage`).
class BrowserLocalStorageDatabase extends DocumentDatabaseAdapter
    implements BrowserDatabaseAdapter {
  final html.Storage impl;
  final String prefix;

  BrowserLocalStorageDatabase() : this._withStorage(html.window.localStorage);

  BrowserLocalStorageDatabase.withSessionStorage()
      : this._withStorage(html.window.sessionStorage);

  BrowserLocalStorageDatabase._withStorage(this.impl, {this.prefix = ''});

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) async {
    final key = _documentKey(request.document);
    if (request.mustExist && !impl.containsKey(key)) {
      throw DatabaseException.notFound(request.document);
    }
    impl.remove(key);
  }

  @override
  Future<void> performDocumentInsert(DocumentInsertRequest request) async {
    final document = request.document ?? request.collection.newDocument();
    if (request.onDocument != null) {
      request.onDocument(document);
    }
    final key = _documentKey(document);
    if (impl.containsKey(key)) {
      throw DatabaseException.found(document);
    }
    impl[key] = encode(request.inputSchema, request.data);
  }

  @override
  Stream<Snapshot> performDocumentRead(DocumentReadRequest request) {
    final document = request.document;
    final key = _documentKey(document);
    final serialized = impl[key];
    if (serialized == null) {
      return Stream<Snapshot>.value(Snapshot.notFound(document));
    }
    final deserialized = _decode(
      request.outputSchema,
      request.document.database,
      serialized,
    ) as Map<String, Object>;
    return Stream<Snapshot>.value(Snapshot(
      document: document,
      data: deserialized,
    ));
  }

  @override
  Stream<QueryResult> performDocumentSearch(DocumentSearchRequest request) {
    final collection = request.collection;

    // Construct prefix
    final prefix = _collectionPrefix(collection);

    // Select matching keys
    final keys = impl.keys.where((key) => key.startsWith(prefix));

    // Construct snapshots
    final snapshots = keys.map((key) {
      final documentId = _jsonPointerUnescape(key.substring(prefix.length));
      final document = collection.document(documentId);
      final serialized = impl[key];
      if (serialized == null) {
        return null;
      }
      final decoded =
          _decode(request.outputSchema, request.collection.database, serialized)
              as Map<String, Object>;
      return Snapshot(
        document: document,
        data: decoded,
      );
    });

    List<Snapshot> result;
    final query = request.query ?? const Query();
    if (query == null) {
      result = List<Snapshot>.unmodifiable(snapshots);
    } else {
      result = query.documentListFromIterable(snapshots);
    }

    // Return stream
    return Stream<QueryResult>.value(QueryResult(
      collection: collection,
      query: query,
      snapshots: result,
    ));
  }

  @override
  Future<void> performDocumentTransaction(DocumentTransactionRequest request) {
    throw DatabaseException.transactionUnsupported();
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) async {
    final key = _documentKey(request.document);
    if (!impl.containsKey(key)) {
      throw DatabaseException.notFound(request.document);
    }
    impl[key] = encode(request.inputSchema, request.data);
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) async {
    final key = _documentKey(request.document);
    impl[key] = encode(request.inputSchema, request.data);
  }

  String _collectionPrefix(Collection collection) {
    final sb = StringBuffer();
    sb.write(prefix);
    sb.write('/');
    sb.write(_jsonPointerEscape(collection.collectionId));
    sb.write('/');
    return sb.toString();
  }

  String _documentKey(Document document) {
    final sb = StringBuffer();
    sb.write(prefix);
    sb.write('/');
    sb.write(_jsonPointerEscape(document.parent.collectionId));
    sb.write('/');
    sb.write(_jsonPointerEscape(document.documentId));
    return sb.toString();
  }

  static String encode(Schema schema, Object value) {
    schema ??= Schema.fromValue(value);
    final converted = schema.encodeWith(
      const JsonEncoder(),
      {
        'schema': schema.toJson(),
        'value': schema.acceptVisitor(JsonEncoder(), value),
      },
    );
    return jsonEncode(converted);
  }

  static Object _decode(Schema schema, Database database, String s) {
    final json = jsonDecode(s) as Map<String, Object>;
    schema ??= Schema.fromJson(json['schema']) ?? ArbitraryTreeSchema();
    return schema.decodeWith(
      JsonDecoder(database: database),
      json['value'],
    );
  }
}
