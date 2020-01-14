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

/// Contains various database adapters that use browser APIs.
///
/// Import:
/// ```
/// import 'package:database/browser.dart';
/// ```
library database.browser;

import 'dart:convert';

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:universal_html/html.dart' as html;

String _jsonPointerEscape(String s) {
  return s.replaceAll('~', '~0').replaceAll('/', '~1');
}

String _jsonPointerUnescape(String s) {
  return s.replaceAll('~1', '/').replaceAll('~0', '~');
}

/// A database that stores data using some browser API.
///
/// An example:
/// ```dart
/// import 'package:database/browser.dart';
/// import 'package:database/database.dart';
///
/// void main() {
///   Database.freezeDefaultInstance(
///     BrowserDatabase(), // Uses the best API supported by the browser.
///   );
///
///   // ...
/// }
/// ```
abstract class BrowserDatabase implements Database {
  factory BrowserDatabase() {
    return BrowserLocalStorageDatabase();
  }
}

/// A database that stores data using [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API)
/// (`window.localStorage`).
class BrowserLocalStorageDatabase extends DatabaseAdapter
    implements BrowserDatabase {
  final html.Storage impl;
  final String prefix;

  BrowserLocalStorageDatabase() : this._withStorage(html.window.localStorage);

  BrowserLocalStorageDatabase.withSessionStorage()
      : this._withStorage(html.window.sessionStorage);

  BrowserLocalStorageDatabase._withStorage(this.impl, {this.prefix = ''});

  @override
  Stream<Snapshot> performRead(ReadRequest request) {
    final document = request.document;
    final key = _documentKey(document);
    final serialized = impl[key];
    if (serialized == null) {
      return Stream<Snapshot>.value(Snapshot.notFound(document));
    }
    final deserialized = _decode(
      request.document.database,
      serialized,
    ) as Map<String, Object>;
    return Stream<Snapshot>.value(Snapshot(
      document: document,
      data: deserialized,
    ));
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) {
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
      final decoded = _decode(request.collection.database, serialized)
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
  Future<void> performWrite(WriteRequest request) async {
    final document = request.document;
    final key = _documentKey(document);
    final exists = impl.containsKey(key);

    switch (request.type) {
      case WriteType.delete:
        if (!exists) {
          throw DatabaseException.notFound(document);
        }
        impl.remove(key);
        break;

      case WriteType.deleteIfExists:
        impl.remove(key);
        break;

      case WriteType.insert:
        if (exists) {
          throw DatabaseException.notFound(document);
        }
        impl[key] = encode(request.data);
        break;

      case WriteType.update:
        if (!exists) {
          throw DatabaseException.notFound(document);
        }
        impl[key] = encode(request.data);
        break;

      case WriteType.upsert:
        impl[key] = encode(request.data);
        break;

      default:
        throw UnimplementedError();
    }
    return Future.value();
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

  static String encode(Object value) {
    final schema = Schema.fromValue(value);
    return jsonEncode({
      'schema': schema.toJson(),
      'value': schema.encodeLessTyped(value),
    });
  }

  static Object _decode(Database database, String s) {
    // TODO: Use protocol buffers?
    final json = jsonDecode(s) as Map<String, Object>;
    final schema = Schema.fromJson(json['schema']) ?? ArbitraryTreeSchema();
    return schema.decodeLessTyped(
      json['value'],
      context: LessTypedDecodingContext(database: database),
    );
  }
}
