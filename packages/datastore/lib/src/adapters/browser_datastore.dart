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
import 'package:universal_html/html.dart' as html;

String _jsonPointerEscape(String s) {
  return s.replaceAll('~', '~0').replaceAll('/', '~1');
}

String _jsonPointerUnescape(String s) {
  return s.replaceAll('~1', '/').replaceAll('~0', '~');
}

/// An adapter for using browser APIs.
///
/// An example:
/// ```dart
/// import 'package:datastore/adapters.dart';
/// import 'package:datastore/datastore.dart';
///
/// void main() {
///   Datastore.freezeDefaultInstance(
///     BrowserDatastore(), // Uses the best API supported by the browser.
///   );
///
///   // ...
/// }
/// ```
abstract class BrowserDatastore extends Datastore {
  factory BrowserDatastore() {
    return BrowserLocalStorageDatastore();
  }
}

/// A [Datastore] implemented with [window.localStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage).
class BrowserLocalStorageDatastore extends DatastoreAdapter
    implements BrowserDatastore {
  final html.Storage impl;
  final String prefix;

  BrowserLocalStorageDatastore() : this._withStorage(html.window.localStorage);

  BrowserLocalStorageDatastore.withSessionStorage()
      : this._withStorage(html.window.sessionStorage);

  BrowserLocalStorageDatastore._withStorage(this.impl, {this.prefix = ''});

  @override
  Stream<Snapshot> performRead(ReadRequest request) {
    final document = request.document;
    final key = _documentKey(document);
    final serialized = impl[key];
    if (serialized == null) {
      return Stream<Snapshot>.value(Snapshot(
        document: document,
        data: null,
        exists: false,
      ));
    }
    final deserialized = _decode(serialized) as Map<String, Object>;
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
      final decoded = _decode(serialized) as Map<String, Object>;
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
          throw DatastoreException.notFound(document);
        }
        impl.remove(key);
        break;

      case WriteType.deleteIfExists:
        impl.remove(key);
        break;

      case WriteType.insert:
        if (exists) {
          throw DatastoreException.notFound(document);
        }
        impl[key] = encode(request.data);
        break;

      case WriteType.update:
        if (!exists) {
          throw DatastoreException.notFound(document);
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
    return jsonEncode(_toJson(value));
  }

  static Object _decode(String s) {
    return _fromJson(jsonDecode(s));
  }

  static Object _fromJson(Object value) {
    if (value == null || value is bool || value is int || value is String) {
      return value;
    }
    if (value is Map) {
      final result = <String, Object>{};
      for (var entry in value.entries) {
        result[entry.key] = _fromJson(entry.value);
      }
      return result;
    }
    if (value is List) {
      final type = value[0] as String;
      switch (type) {
        case 'nan':
          return double.nan;
        case '-inf':
          return double.negativeInfinity;
        case 'inf':
          return double.infinity;
        case 'double':
          return value[1] as double;
        case 'datetime':
          return DateTime.fromMillisecondsSinceEpoch((value[1] as num).toInt());
        case 'list':
          return value.skip(1).map(_fromJson).toList();
        default:
          throw ArgumentError('Unsupported type annotation "$type"');
      }
    }
    throw ArgumentError.value(value);
  }

  static Object _toJson(Object value) {
    if (value == null || value is bool || value is int || value is String) {
      return value;
    }
    if (value is double) {
      if (value.isNaN) {
        return const ['nan'];
      }
      if (value.isInfinite) {
        if (value.isNegative) {
          return const ['-inf'];
        }
        return const ['inf'];
      }
      return ['double', value];
    }
    if (value is DateTime) {
      return ['datetime', value.millisecondsSinceEpoch];
    }
    if (value is List) {
      return ['list', ...value.map(_toJson)];
    }
    if (value is Map) {
      final result = <String, Object>{};
      for (var entry in value.entries) {
        result[entry.key] = _toJson(entry.value);
      }
      return result;
    }
    throw ArgumentError.value(value);
  }
}
