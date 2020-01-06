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

/// Enables describing graph schema. The main use cases are validation and
/// GraphQL-like subgraph selections.
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:datastore/datastore.dart';
import 'package:meta/meta.dart';

/// Schema for arbitrary trees.
class ArbitraryTreeSchema extends Schema<Object> {
  const ArbitraryTreeSchema();

  @override
  int get hashCode => (ArbitraryTreeSchema).hashCode;

  @override
  bool operator ==(other) => other is ArbitraryTreeSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitArbitraryTreeSchema(this, context);
  }

  @override
  Object decodeJson(Object argument, {JsonDecodingContext context}) {
    if (!isValidTree(argument)) {
      throw ArgumentError.value(argument);
    }
    return argument;
  }

  @override
  Object encodeJson(Object argument) {
    if (!isValidTree(argument)) {
      throw ArgumentError.value(argument);
    }
    return argument;
  }

  @override
  bool isValidSchema({List stack}) {
    return true;
  }

  @override
  bool isValidTree(Object argument, {List stack}) {
    if (argument is List) {
      try {
        if (stack != null) {
          for (var item in stack) {
            if (identical(item, argument)) {
              return false;
            }
          }
        }
        stack ??= [];
        stack.add(argument);
        for (var item in argument) {
          if (!isValidTree(item, stack: stack)) {
            return false;
          }
        }
        return true;
      } finally {
        stack.removeLast();
      }
    }
    if (argument is Map) {
      try {
        if (stack != null) {
          for (var item in stack) {
            if (identical(item, argument)) {
              return false;
            }
          }
        }
        stack ??= [];
        stack.add(argument);
        return argument.entries.every((entry) {
          return entry.key is String && isValidTree(entry.value, stack: stack);
        });
      } finally {
        stack.removeLast();
      }
    }
    // TODO: Should we check that the argument is a valid primitive?
    return true;
  }

  @override
  Object selectTree(Object argument, {bool ignoreErrors = false}) {
    if (argument == null ||
        argument is bool ||
        argument is num ||
        argument is String) {
      return argument;
    }
    if (argument is List) {
      return List.unmodifiable(
        argument.map((item) => selectTree(item, ignoreErrors: ignoreErrors)),
      );
    }
    if (argument is Map) {
      final result = <String, Object>{};
      for (var entry in argument.entries) {
        result[entry.key] = selectTree(entry.value, ignoreErrors: ignoreErrors);
      }
      return Map.unmodifiable(result);
    }
    if (ignoreErrors) {
      return null;
    }
    throw ArgumentError.value(argument);
  }
}

class BlobSchema extends PrimitiveSchema<Blob> {
  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBlobSchema(this, context);
  }

  @override
  Blob decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      throw UnimplementedError();
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Blob) {
      throw UnimplementedError();
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [bool] values.
class BoolSchema extends PrimitiveSchema<bool> {
  const BoolSchema();

  @override
  int get hashCode => (BoolSchema).hashCode;

  @override
  bool operator ==(other) => other is BoolSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBoolSchema(this, context);
  }

  @override
  bool decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is bool) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is bool) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [Uint8List] values.
class BytesSchema extends PrimitiveSchema<Uint8List> {
  final int maxLength;

  const BytesSchema({this.maxLength});

  @override
  int get hashCode => (BytesSchema).hashCode ^ maxLength.hashCode;

  @override
  bool operator ==(other) =>
      other is BytesSchema && maxLength == other.maxLength;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBytesSchema(this, context);
  }

  @override
  Uint8List decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is String) {
      return Uint8List.fromList(base64Decode(argument));
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Uint8List) {
      return base64Encode(argument);
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [DateTime] values.
class DateTimeSchema extends PrimitiveSchema<DateTime> {
  const DateTimeSchema();

  @override
  int get hashCode => (DateTimeSchema).hashCode;

  @override
  bool operator ==(other) => other is DateTimeSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDateTimeSchema(this, context);
  }

  @override
  DateTime decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is String) {
      return DateTime.parse(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is DateTime) {
      return argument.toUtc().toIso8601String().replaceAll(' ', 'T');
    }
    throw ArgumentError.value(argument);
  }
}

class DocumentSchema extends PrimitiveSchema<Document> {
  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDocumentSchema(this, context);
  }

  @override
  Document decodeJson(Object argument, {JsonDecodingContext context}) {
    if (context == null) {
      throw ArgumentError.notNull('context');
    }
    if (argument == null) {
      return null;
    }
    if (argument is String && argument.startsWith('/')) {
      final parts = argument.substring(1).split('/');
      if (parts.length == 2) {
        final collectionId = _jsonPointerUnescape(parts[0]);
        final documentId = _jsonPointerUnescape(parts[1]);
        return context.datastore.collection(collectionId).document(documentId);
      }
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Document) {
      final collectionId = _jsonPointerEscape(
        argument.parent.collectionId,
      );
      final documentId = _jsonPointerEscape(
        argument.documentId,
      );
      return '/$collectionId/$documentId';
    }
    throw ArgumentError.value(argument);
  }

  String _jsonPointerEscape(String s) {
    return s.replaceAll('~', '~0').replaceAll('/', '~1');
  }

  String _jsonPointerUnescape(String s) {
    return s.replaceAll('~1', '/').replaceAll('~0', '~');
  }
}

/// Schema for [double] values.
class DoubleSchema extends PrimitiveSchema<double> {
  const DoubleSchema();

  @override
  int get hashCode => (DoubleSchema).hashCode;

  @override
  bool operator ==(other) => other is DoubleSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDoubleSchema(this, context);
  }

  @override
  double decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      return argument.toDouble();
    }
    if (argument is String) {
      return double.parse(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      if (argument == double.nan ||
          argument == double.negativeInfinity ||
          argument == double.infinity) {
        throw ArgumentError.value(argument);
      }
      return argument.toDouble();
    }
    throw ArgumentError.value(argument);
  }
}

class GeoPointSchema extends PrimitiveSchema<GeoPoint> {
  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitGeoPointSchema(this, context);
  }

  @override
  GeoPoint decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      return GeoPoint(
        (argument[0] as num).toDouble(),
        (argument[1] as num).toDouble(),
      );
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is GeoPoint) {
      return List.unmodifiable([argument.latitude, argument.longitude]);
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [int] values.
class IntSchema extends PrimitiveSchema<int> {
  const IntSchema();

  @override
  int get hashCode => (IntSchema).hashCode;

  @override
  bool operator ==(other) => other is IntSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitIntSchema(this, context);
  }

  @override
  int decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      return argument.toInt();
    }
    if (argument is String) {
      return int.parse(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      if (argument.toDouble().toInt() != argument) {
        return argument.toString();
      }
      return argument.toDouble();
    }
    throw ArgumentError.value(argument);
  }
}

/// JSON decoding context used by [Schema].
class JsonDecodingContext {
  /// For decoding [Document] instances.
  final Datastore datastore;

  JsonDecodingContext({@required this.datastore});
}

/// Schema for [List] values.
class ListSchema extends Schema {
  final Schema items;
  final int maxLength;

  const ListSchema({this.items, this.maxLength});

  @override
  int get hashCode =>
      (ListSchema).hashCode ^ items.hashCode ^ maxLength.hashCode;

  @override
  bool operator ==(other) =>
      other is ListSchema &&
      maxLength == other.maxLength &&
      items == other.items;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitListSchema(this, context);
  }

  @override
  List decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    final itemSchema = items;
    if (itemSchema == null) {
      return List.unmodifiable(argument as List);
    }
    return List.unmodifiable((argument as List).map((item) {
      return itemSchema.decodeJson(item, context: context);
    }));
  }

  @override
  List encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      final itemSchema = items;
      if (itemSchema == null) {
        return List.unmodifiable(argument);
      }
      return List.unmodifiable(argument.map((item) {
        return itemSchema.encodeJson(item);
      }));
    }
    throw ArgumentError.value(argument);
  }

  @override
  bool isValidSchema({List stack}) {
    stack ??= [];
    for (var stackItem in stack) {
      if (identical(stackItem, this)) {
        return true;
      }
    }
    stack.add(this);
    final items = this.items;
    if (items != null && items.isValidSchema(stack: stack)) {
      return true;
    }
    stack.removeLast();
    return false;
  }

  @override
  bool isValidTree(Object argument, {List stack}) {
    if (argument == null) {
      return true;
    }
    if (argument is List) {
      if (stack != null) {
        for (var parent in stack) {
          if (identical(parent, argument)) {
            return false;
          }
        }
      }
      stack ??= [];
      stack.add(argument);
      final itemsSchema = items ?? ArbitraryTreeSchema();
      try {
        for (var item in argument) {
          if (!itemsSchema.isValidTree(item, stack: stack)) {
            return false;
          }
        }
      } finally {
        stack.removeLast();
      }
      return true;
    }
    return false;
  }

  @override
  List selectTree(Object argument, {bool ignoreErrors = false}) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      final itemSchema = items;
      final result = List(argument.length);
      for (var i = 0; i < argument.length; i++) {
        final oldItem = argument[i];
        final newItem =
            itemSchema.selectTree(oldItem, ignoreErrors: ignoreErrors);
        result[i] = newItem;
      }
      return List.unmodifiable(result);
    }
    if (ignoreErrors) {
      return null;
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [Map] values. Keys must be strings.
class MapSchema extends Schema<Map<String, Object>> {
  final StringSchema additionalKeys;
  final Schema additionalValues;
  final Set<String> requiredProperties;
  final Map<String, Schema> properties;

  const MapSchema({
    this.additionalKeys,
    this.additionalValues,
    this.requiredProperties,
    this.properties,
  });

  @override
  int get hashCode =>
      (MapSchema).hashCode ^
      additionalKeys.hashCode ^
      additionalValues.hashCode ^
      const SetEquality().hash(requiredProperties) ^
      const DeepCollectionEquality().hash(properties);

  @override
  bool operator ==(other) =>
      other is MapSchema &&
      additionalKeys == other.additionalKeys &&
      additionalValues == other.additionalValues &&
      const SetEquality()
          .equals(requiredProperties, other.requiredProperties) &&
      const DeepCollectionEquality().equals(properties, other.properties);

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitMapSchema(this, context);
  }

  @override
  Map<String, Object> decodeJson(Object argument,
      {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is Map) {
      final properties = this.properties;
      final result = <String, Object>{};
      for (var entry in argument.entries) {
        final key = entry.key;
        final valueSchema =
            properties[key] ?? additionalValues ?? const ArbitraryTreeSchema();
        result[key] = valueSchema.decodeJson(entry.value, context: context);
      }
      return Map<String, Object>.unmodifiable(result);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Map<String, Object> encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    if (argument is Map) {
      final properties = this.properties;
      final result = <String, Object>{};
      for (var entry in argument.entries) {
        final key = entry.key;
        final valueSchema =
            properties[key] ?? additionalValues ?? const ArbitraryTreeSchema();
        result[key] = valueSchema.encodeJson(entry.value);
      }
      return Map<String, Object>.unmodifiable(result);
    }
    throw ArgumentError.value(argument);
  }

  @override
  bool isValidSchema({List stack}) {
    stack ??= [];
    for (var stackItem in stack) {
      if (identical(stackItem, this)) {
        return true;
      }
    }
    stack.add(this);
    final properties = this.properties;
    if (properties != null) {
      for (var schema in properties.values) {
        if (schema.isValidSchema(stack: stack)) {
          return true;
        }
      }
    }
    final additionalValues = this.additionalValues;
    if (additionalValues != null &&
        additionalValues.isValidSchema(stack: stack)) {
      return true;
    }
    stack.removeLast();
    return false;
  }

  @override
  bool isValidTree(Object argument, {List stack}) {
    if (argument == null) {
      return true;
    }
    if (argument is Map) {
      if (stack != null) {
        for (var parent in stack) {
          if (identical(parent, argument)) {
            return false;
          }
        }
      }
      stack ??= [];
      stack.add(argument);
      try {
        final requiredProperties = this.requiredProperties;
        if (requiredProperties != null) {
          for (var propertyName in requiredProperties) {
            if (!argument.containsKey(propertyName)) {
              return false;
            }
          }
        }
        final properties = this.properties;
        if (properties != null) {
          for (var key in argument.keys) {
            final valueSchema = properties[key] ??
                additionalValues ??
                const ArbitraryTreeSchema();
            if (valueSchema != null) {
              final value = argument[key];
              if (!valueSchema.isValidTree(value, stack: stack)) {
                return false;
              }
            }
          }
        }
      } finally {
        stack.removeLast();
      }
      return true;
    }
    return false;
  }

  @override
  Map<String, Object> selectTree(Object argument, {bool ignoreErrors = false}) {
    if (argument == null) {
      return null;
    } else if (argument is Map) {
      final properties = this.properties ?? const <String, Schema>{};
      final additionalValues = this.additionalValues;
      final result = <String, Object>{};
      for (var entry in argument.entries) {
        final key = entry.key;
        final oldValue = entry.value;
        final valueSchema = properties[key] ?? additionalValues;
        if (valueSchema == null) {
          continue;
        }
        final newValue = valueSchema.selectTree(
          oldValue,
          ignoreErrors: ignoreErrors,
        );
        result[key] = newValue;
      }
      return Map<String, Object>.unmodifiable(result);
    } else {
      if (ignoreErrors) {
        return null;
      }
      throw ArgumentError.value(argument);
    }
  }
}

abstract class PrimitiveSchema<T> extends Schema<T> {
  const PrimitiveSchema();

  @override
  bool isValidSchema({List stack}) {
    return false;
  }

  @override
  bool isValidTree(Object argument, {List stack}) {
    if (argument == null) {
      return true;
    }
    return argument is T;
  }

  @override
  T selectTree(Object argument, {bool ignoreErrors = false}) {
    if (argument == null) {
      return null;
    }
    if (argument is T) {
      return argument;
    }
    if (ignoreErrors) {
      return null;
    }
    throw ArgumentError.value(argument);
  }
}

/// Describes valid values and decodes/encodes JSON.
abstract class Schema<T> {
  const Schema();

  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context);

  /// Converts a JSON tree into an immutable Dart tree.
  ///
  /// For example, `{'dateTime': '2020-01-01T00:00:00Z'}` could be converted
  /// into `{'dateTime': DateTime(2020,1,1)}`.
  T decodeJson(Object argument, {JsonDecodingContext context});

  /// Converts a Dart tree into an immutable JSON tree.
  ///
  /// For example, `{'dateTime': DateTime(2020,1,1)}` could be converted into
  /// `{'dateTime': '2020-01-01T00:00:00Z'}`.
  Object encodeJson(Object argument);

  /// Determines whether the schema is valid.
  ///
  /// Optional argument [stack] is used for detecting cycles.
  bool isValidSchema({List stack});

  /// Determines whether the argument matches the schema.
  ///
  /// Optional argument [stack] is used for detecting cycles.
  bool isValidTree(Object argument, {List stack});

  /// Select a tree in a graph.
  T selectTree(Object argument, {bool ignoreErrors = false});
}

/// Schema for [String] values.
class StringSchema extends PrimitiveSchema<String> {
  final int maxLength;

  const StringSchema({this.maxLength});

  @override
  int get hashCode => (StringSchema).hashCode ^ maxLength.hashCode;

  @override
  bool operator ==(other) =>
      other is StringSchema && maxLength == other.maxLength;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitStringSchema(this, context);
  }

  @override
  String decodeJson(Object argument, {JsonDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    return argument as String;
  }

  @override
  Object encodeJson(Object argument) {
    if (argument == null) {
      return null;
    }
    return argument as String;
  }

  @override
  bool isValidTree(Object argument, {List stack}) {
    if (argument == null) {
      return true;
    }
    if (argument is String) {
      if (maxLength != null && argument.length > maxLength) {
        return false;
      }
      return true;
    }
    return false;
  }
}
