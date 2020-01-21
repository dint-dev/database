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

/// Enables describing graph schema. The main use cases are validation and
/// GraphQL-like subgraph selections.
import 'dart:convert';
import 'dart:typed_data';

import 'package:database/database.dart';
import 'package:database/schema.dart';

/// Encodes JSON based on [Schema] arguments. For encoding, use [JsonEncoder].
class JsonEncoder extends SchemaBasedConverterBase {
  final bool supportSpecialDoubleValues;

  const JsonEncoder({this.supportSpecialDoubleValues = false});

  @override
  Object visitBytesSchema(BytesSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Uint8List) {
      return base64Encode(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDateSchema(DateSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Date) {
      return argument.toString();
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDateTimeSchema(DateTimeSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is DateTime) {
      // TODO: Optimize?
      return argument.toString().replaceAll(' ', 'T');
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDocumentSchema(DocumentSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Document) {
      final collectionId = _jsonPointerEscape(argument.parent.collectionId);
      final documentId = _jsonPointerEscape(argument.documentId);
      return '/$collectionId/$documentId';
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDoubleSchema(DoubleSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is double) {
      if (argument.isNaN) {
        if (supportSpecialDoubleValues) {
          return 'nan';
        }
      } else if (argument == double.negativeInfinity) {
        if (supportSpecialDoubleValues) {
          return '-inf';
        }
      } else if (argument == double.infinity) {
        if (supportSpecialDoubleValues) {
          return '+inf';
        }
      } else {
        return argument;
      }
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitGeoPointSchema(GeoPointSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is GeoPoint) {
      return [argument.latitude, argument.longitude];
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitInt64Schema(Int64Schema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Int64) {
      return argument.toString();
    }
    throw ArgumentError.value(argument);
  }

  static String _jsonPointerEscape(String s) {
    return s.replaceAll('~', '~0').replaceAll('/', '~1');
  }
}
