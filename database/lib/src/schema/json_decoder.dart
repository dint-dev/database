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
import 'dart:typed_data';

import 'package:database/database.dart';
import 'package:database/schema.dart';
import 'package:meta/meta.dart';

/// Decodes JSON based on [Schema] arguments. For decoding, use [JsonDecoder].
class JsonDecoder extends SchemaBasedConverterBase {
  /// Database for constructing [Document] objects.
  final Database database;

  /// Whether to support the following special strings when schema is
  /// [DoubleSchema]:
  ///   * "nan"
  ///   * "-inf"
  ///   * "+inf"
  final bool supportSpecialDoubleValues;

  JsonDecoder({
    @required this.database,
    this.supportSpecialDoubleValues = false,
  });

  @override
  Uint8List visitBytesSchema(BytesSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is String) {
      return base64Decode(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDateSchema(DateSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is String) {
      return Date.parse(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDateTimeSchema(DateTimeSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is String) {
      // TODO: Optimize?
      return DateTime.parse(argument.replaceAll('T', ' '));
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDocumentSchema(DocumentSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is String && argument.startsWith('/')) {
      if (argument == null) {
        throw ArgumentError.notNull('argument');
      }
      final parts = argument.substring(1).split('/');
      if (parts.length == 2) {
        final collectionId = _jsonPointerUnescape(parts[0]);
        final documentId = _jsonPointerUnescape(parts[1]);
        return database.collection(collectionId).document(documentId);
      }
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDoubleSchema(DoubleSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is double) {
      return argument;
    }
    if (argument is String && supportSpecialDoubleValues) {
      switch (argument) {
        case 'nan':
          return double.nan;
        case '-inf':
          return double.negativeInfinity;
        case '+inf':
          return double.infinity;
      }
    }
    throw ArgumentError.value(argument);
  }

  @override
  GeoPoint visitGeoPointSchema(GeoPointSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      final latitude = argument[0] as double;
      final longitude = argument[1] as double;
      return GeoPoint(latitude, longitude);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Int64 visitInt64Schema(Int64Schema schema, Object argument) {
    if (argument == null) {
      return argument;
    }
    if (argument is String) {
      return Int64.parseInt(argument);
    }
    throw ArgumentError.value(argument);
  }

  static String _jsonPointerUnescape(String s) {
    return s.replaceAll('~1', '/').replaceAll('~0', '~');
  }
}
