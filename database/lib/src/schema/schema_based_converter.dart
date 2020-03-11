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

import 'dart:typed_data';

import 'package:database/database.dart';
import 'package:database/schema.dart';

/// Base class for schema-based converters.
///
/// Subclasses only need to override methods where the encoding output or
/// decoding input is different from the Dart graph value.
///
/// The default implementations check that the argument matches the schema.
/// The methods methods [visitListSchema] and [visitMapSchema] also convert
/// child nodes and return an immutable List/Map.
class SchemaBasedConverterBase extends SchemaVisitor<Object, Object> {
  const SchemaBasedConverterBase();

  @override
  Object visitArbitraryTreeSchema(ArbitraryTreeSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is bool) {
      return const BoolSchema().acceptVisitor(this, argument);
    }
    if (argument is double) {
      return const DoubleSchema().acceptVisitor(this, argument);
    }
    if (argument is int) {
      return const IntSchema().acceptVisitor(this, argument);
    }
    if (argument is Int64) {
      return const Int64Schema().acceptVisitor(this, argument);
    }
    if (argument is DateTime) {
      return const DateTimeSchema().acceptVisitor(this, argument);
    }
    if (argument is GeoPoint) {
      return const GeoPointSchema().acceptVisitor(this, argument);
    }
    if (argument is String) {
      return const StringSchema().acceptVisitor(this, argument);
    }
    if (argument is Uint8List) {
      return const BytesSchema().acceptVisitor(this, argument);
    }
    if (argument is Document) {
      return const DocumentSchema().acceptVisitor(this, argument);
    }
    if (argument is Blob) {
      return const BlobSchema().acceptVisitor(this, argument);
    }
    if (argument is List) {
      // TODO: Eliminate allocation?
      final listSchema = ListSchema(items: schema);
      return listSchema.acceptVisitor(this, argument);
    }
    if (argument is Map) {
      // TODO: Eliminate allocation?
      final mapSchema = MapSchema(const {}, additionalValues: schema);
      return mapSchema.acceptVisitor(this, argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitBlobSchema(BlobSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Blob) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitBoolSchema(BoolSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is bool) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitBytesSchema(BytesSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Uint8List) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDateSchema(DateSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Date) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDateTimeSchema(DateTimeSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is DateTime) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitDocumentSchema(DocumentSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is DocumentSchema) {
      return argument;
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
    throw ArgumentError.value(argument);
  }

  @override
  Object visitGeoPointSchema(GeoPointSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is GeoPoint) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitInt64Schema(Int64Schema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Int64) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitIntSchema(IntSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is int) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitListSchema(ListSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      final itemSchema = schema.items;
      if (itemSchema == null) {
        return List.unmodifiable(argument);
      }
      return List.unmodifiable(argument.map((item) {
        return itemSchema.acceptVisitor(this, item);
      }));
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitMapSchema(MapSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Map) {
      final properties = schema.properties;
      final result = <String, Object>{};
      for (var entry in argument.entries) {
        final key = entry.key;
        final value = entry.value;
        final valueSchema = properties[key] ??
            schema.additionalValues ??
            const ArbitraryTreeSchema();
        result[key] = valueSchema.acceptVisitor(this, value);
      }
      return Map<String, Object>.unmodifiable(result);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object visitStringSchema(StringSchema schema, Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is String) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }
}
