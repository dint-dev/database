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
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:meta/meta.dart';

/// Schema for arbitrary trees.
@sealed
class ArbitraryTreeSchema extends Schema<Object> {
  static const String nameForJson = '*';

  const ArbitraryTreeSchema();

  @override
  int get hashCode => (ArbitraryTreeSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is ArbitraryTreeSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitArbitraryTreeSchema(this, context);
  }

  @override
  Object decodeLessTyped(Object argument,
      {LessTypedDecodingContext context, bool noUnsupported = false}) {
    if (argument == null ||
        argument is bool ||
        argument is num ||
        argument is DateTime ||
        argument is GeoPoint ||
        argument is String) {
      return argument;
    }
    if (argument is List) {
      return ListSchema(items: this).decodeLessTyped(
        argument,
        context: context,
      );
    }
    if (argument is Map) {
      return MapSchema(const {}, additionalValues: this).decodeLessTyped(
        argument,
        context: context,
      );
    }
    if (!noUnsupported) {
      final f = context?.onUnsupported;
      if (f != null) {
        return decodeLessTyped(
          f(context, argument),
          context: context,
          noUnsupported: true,
        );
      }
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is bool) {
      return const BoolSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is double) {
      return const DoubleSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is int) {
      return const IntSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is Int64) {
      return const Int64Schema().encodeLessTyped(argument, context: context);
    }
    if (argument is DateTime) {
      return const DateTimeSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is GeoPoint) {
      return const GeoPointSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is String) {
      return const StringSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is Uint8List) {
      return const BytesSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is Document) {
      return const DocumentSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is Blob) {
      return const BlobSchema().encodeLessTyped(argument, context: context);
    }
    if (argument is List) {
      return ListSchema(items: this).encodeLessTyped(
        argument,
        context: context,
      );
    }
    if (argument is Map) {
      return MapSchema(const {}, additionalValues: this).encodeLessTyped(
        argument,
        context: context,
      );
    }
    throw ArgumentError.value(argument);
  }

  @override
  bool isValidSchema({List cycleDetectionStack}) {
    return true;
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
    if (argument is List) {
      try {
        if (cycleDetectionStack != null) {
          for (var item in cycleDetectionStack) {
            if (identical(item, argument)) {
              return false;
            }
          }
        }
        cycleDetectionStack ??= [];
        cycleDetectionStack.add(argument);
        for (var item in argument) {
          if (!isValidTree(item, cycleDetectionStack: cycleDetectionStack)) {
            return false;
          }
        }
        return true;
      } finally {
        cycleDetectionStack.removeLast();
      }
    }
    if (argument is Map) {
      try {
        if (cycleDetectionStack != null) {
          for (var item in cycleDetectionStack) {
            if (identical(item, argument)) {
              return false;
            }
          }
        }
        cycleDetectionStack ??= [];
        cycleDetectionStack.add(argument);
        return argument.entries.every((entry) {
          return entry.key is String &&
              isValidTree(entry.value,
                  cycleDetectionStack: cycleDetectionStack);
        });
      } finally {
        cycleDetectionStack.removeLast();
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

  @override
  Object toJson() {
    return name;
  }
}

@sealed
class BlobSchema extends PrimitiveSchema<Blob> {
  static const String nameForJson = 'blob';

  const BlobSchema();

  @override
  int get hashCode => (BlobSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is BlobSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBlobSchema(this, context);
  }

  @override
  Blob decodeLessTyped(Object argument, {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is Blob) {
      return argument;
    }
    if (argument is List) {
      throw UnimplementedError();
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is Blob) {
      if (context != null && context.supportsBlob) {
        return argument;
      }
      throw UnimplementedError();
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [bool] values.
@sealed
class BoolSchema extends PrimitiveSchema<bool> {
  static const String nameForJson = 'bool';

  const BoolSchema();

  @override
  int get hashCode => (BoolSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is BoolSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBoolSchema(this, context);
  }

  @override
  bool decodeLessTyped(Object argument, {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is bool) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
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
@sealed
class BytesSchema extends PrimitiveSchema<Uint8List> {
  static const String nameForJson = 'bytes';

  final int maxLength;

  const BytesSchema({this.maxLength});

  @override
  int get hashCode => (BytesSchema).hashCode ^ maxLength.hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is BytesSchema && maxLength == other.maxLength;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBytesSchema(this, context);
  }

  @override
  Uint8List decodeLessTyped(Object argument,
      {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is Uint8List) {
      return argument;
    }
    if (argument is String) {
      return Uint8List.fromList(base64Decode(argument));
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
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
@sealed
class DateTimeSchema extends PrimitiveSchema<DateTime> {
  static const String nameForJson = 'datetime';

  const DateTimeSchema();

  @override
  int get hashCode => (DateTimeSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is DateTimeSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDateTimeSchema(this, context);
  }

  @override
  DateTime decodeLessTyped(Object argument,
      {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is DateTime) {
      return argument;
    }
    if (argument is String) {
      return DateTime.parse(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is DateTime) {
      if (context != null && context.supportsDateTime) {
        return argument;
      }
      return argument.toUtc().toIso8601String().replaceAll(' ', 'T');
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [Document] values.
@sealed
class DocumentSchema extends PrimitiveSchema<Document> {
  static const String nameForJson = 'document';

  const DocumentSchema();

  @override
  int get hashCode => (DocumentSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is DocumentSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDocumentSchema(this, context);
  }

  @override
  Document decodeLessTyped(Object argument,
      {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is Document) {
      return argument;
    }
    if (argument is String && argument.startsWith('/')) {
      if (context == null) {
        throw ArgumentError.notNull('context');
      }
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
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is Document) {
      if (context != null && context.supportsDocument) {
        return argument;
      }
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
@sealed
class DoubleSchema extends PrimitiveSchema<double> {
  static const String nameForJson = 'double';

  const DoubleSchema();

  @override
  int get hashCode => (DoubleSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is DoubleSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDoubleSchema(this, context);
  }

  @override
  double decodeLessTyped(Object argument, {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      return argument.toDouble();
    }
    if (argument is String) {
      switch (argument) {
        case 'nan':
          return double.nan;
        case '-inf':
          return double.negativeInfinity;
        case 'inf':
          return double.infinity;
      }
      return double.parse(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      if (context != null && !context.supportsDoubleSpecialValues) {
        if (argument.isNaN) {
          return 'nan';
        }
        if (argument == double.negativeInfinity) {
          return '-inf';
        }
        if (argument == double.infinity) {
          return 'inf';
        }
      }
      return argument.toDouble();
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [GeoPoint] values.
@sealed
class GeoPointSchema extends PrimitiveSchema<GeoPoint> {
  static const String nameForJson = 'geopoint';

  const GeoPointSchema();

  @override
  int get hashCode => (GeoPointSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is GeoPointSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitGeoPointSchema(this, context);
  }

  @override
  GeoPoint decodeLessTyped(Object argument,
      {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is GeoPoint) {
      return argument;
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
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is GeoPoint) {
      if (context != null && context.supportsGeoPoint) {
        // Supports GeoPoint
        if (context.mapGeoPoint != null) {
          return context.mapGeoPoint(argument);
        }
        return argument;
      }

      // Does not support GeoPoint
      return List.unmodifiable([argument.latitude, argument.longitude]);
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [Int64] values.
@sealed
class Int64Schema extends PrimitiveSchema<Int64> {
  static const String nameForJson = 'int64';

  const Int64Schema();

  @override
  int get hashCode => (Int64Schema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is Int64Schema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitInt64Schema(this, context);
  }

  @override
  Int64 decodeLessTyped(Object argument, {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      return Int64(argument.toInt());
    }
    if (argument is String) {
      return Int64.parseInt(argument);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is Int64) {
      if (context != null && context.supportsInt64) {
        return argument;
      }
      return argument.toString();
    }
    throw ArgumentError.value(argument);
  }
}

/// Schema for [int] values.
@sealed
class IntSchema extends PrimitiveSchema<int> {
  static const String nameForJson = 'int';

  const IntSchema();

  @override
  int get hashCode => (IntSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is IntSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitIntSchema(this, context);
  }

  @override
  int decodeLessTyped(Object argument, {LessTypedDecodingContext context}) {
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
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is num) {
      if (argument.toDouble().toInt() == argument) {
        return argument.toDouble();
      }
      return argument.toString();
    }
    throw ArgumentError.value(argument);
  }
}

class LessTypedDecodingContext {
  /// For decoding [Document] instances.
  final Datastore datastore;

  final Object Function(LessTypedDecodingContext context, Object value)
      onUnsupported;

  LessTypedDecodingContext({@required this.datastore, this.onUnsupported});
}

class LessTypedEncodingContext {
  final bool supportsBlob;
  final bool supportsDateTime;
  final bool supportsDoubleSpecialValues;
  final bool supportsDocument;
  final bool supportsGeoPoint;
  final bool supportsInt;
  final bool supportsInt64;
  final Object Function(Blob value) mapBlob;
  final Object Function(Document value) mapDocument;
  final Object Function(GeoPoint value) mapGeoPoint;

  LessTypedEncodingContext({
    this.supportsBlob = false,
    this.supportsDocument = false,
    this.supportsDoubleSpecialValues = false,
    this.supportsDateTime = false,
    this.supportsGeoPoint = false,
    this.supportsInt = false,
    this.supportsInt64 = false,
    this.mapBlob,
    this.mapDocument,
    this.mapGeoPoint,
  });
}

/// Schema for [List] values.
@sealed
class ListSchema extends Schema {
  static const String nameForJson = 'list';
  final Schema items;
  final List<Schema> itemsByIndex;
  final int maxLength;

  const ListSchema({
    this.items,
    this.itemsByIndex,
    this.maxLength,
  });

  @override
  int get hashCode =>
      (ListSchema).hashCode ^
      maxLength.hashCode ^
      items.hashCode ^
      const ListEquality<Schema>().hash(itemsByIndex);

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is ListSchema &&
      maxLength == other.maxLength &&
      items == other.items &&
      const ListEquality<Schema>().equals(itemsByIndex, other.itemsByIndex);

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitListSchema(this, context);
  }

  @override
  List decodeLessTyped(Object argument, {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      final itemsByIndex = this.itemsByIndex;
      if (itemsByIndex != null) {
        if (argument.length != itemsByIndex.length) {
          throw ArgumentError.value(
            argument,
            'argument',
            'Should have length ${argument.length}',
          );
        }
        final result = List(itemsByIndex.length);
        for (var i = 0; i < result.length; i++) {
          result[i] =
              itemsByIndex[i].decodeLessTyped(argument, context: context);
        }
        return List.unmodifiable(result);
      }
      final itemSchema = items;
      if (itemSchema == null) {
        return List.unmodifiable(argument);
      }
      return List.unmodifiable(argument.map((item) {
        return itemSchema.decodeLessTyped(item, context: context);
      }));
    }
    throw ArgumentError.value(argument);
  }

  @override
  List encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is List) {
      final itemSchema = items;
      if (itemSchema == null) {
        return List.unmodifiable(argument);
      }
      return List.unmodifiable(argument.map((item) {
        return itemSchema.encodeLessTyped(item, context: context);
      }));
    }
    throw ArgumentError.value(argument);
  }

  @override
  bool isValidSchema({List cycleDetectionStack}) {
    if (cycleDetectionStack != null) {
      for (var ancestor in cycleDetectionStack) {
        if (identical(ancestor, this)) {
          return false;
        }
      }
    }
    cycleDetectionStack ??= [];
    cycleDetectionStack.add(this);
    final items = this.items;
    if (items != null &&
        items.isValidSchema(cycleDetectionStack: cycleDetectionStack)) {
      cycleDetectionStack.removeLast();
      return true;
    }
    cycleDetectionStack.removeLast();
    return false;
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
    if (argument == null) {
      return true;
    }
    if (argument is List) {
      if (cycleDetectionStack != null) {
        for (var parent in cycleDetectionStack) {
          if (identical(parent, argument)) {
            return false;
          }
        }
      }
      cycleDetectionStack ??= [];
      cycleDetectionStack.add(argument);
      final itemsSchema = items ?? ArbitraryTreeSchema();
      for (var item in argument) {
        final isValid = itemsSchema.isValidTree(
          item,
          cycleDetectionStack: cycleDetectionStack,
        );
        if (!isValid) {
          cycleDetectionStack.removeLast();
          return false;
        }
      }
      cycleDetectionStack.removeLast();
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

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{
      '@type': nameForJson,
    };
    if (items != null) {
      json['@items'] = items.toJson();
    }
    if (maxLength != null) {
      json['@maxLength'] = maxLength;
    }
    return json;
  }
}

/// Schema for [Map] values. Keys must be strings.
@sealed
class MapSchema extends Schema<Map<String, Object>> {
  static const String nameForJson = 'map';
  final Map<String, Schema> properties;
  final Set<String> requiredProperties;
  final Schema additionalValues;

  const MapSchema(
    this.properties, {
    this.additionalValues,
    this.requiredProperties,
  });

  @override
  int get hashCode =>
      (MapSchema).hashCode ^
      additionalValues.hashCode ^
      const SetEquality().hash(requiredProperties) ^
      const DeepCollectionEquality().hash(properties);

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is MapSchema &&
      additionalValues == other.additionalValues &&
      const SetEquality()
          .equals(requiredProperties, other.requiredProperties) &&
      const DeepCollectionEquality().equals(properties, other.properties);

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitMapSchema(this, context);
  }

  @override
  Map<String, Object> decodeLessTyped(Object argument,
      {LessTypedDecodingContext context}) {
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
        result[key] = valueSchema.decodeLessTyped(
          entry.value,
          context: context,
        );
      }
      return Map<String, Object>.unmodifiable(result);
    }
    throw ArgumentError.value(argument);
  }

  @override
  Map<String, Object> encodeLessTyped(Object argument,
      {LessTypedEncodingContext context}) {
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
        result[key] = valueSchema.encodeLessTyped(
          entry.value,
          context: context,
        );
      }
      return Map<String, Object>.unmodifiable(result);
    }
    throw ArgumentError.value(argument);
  }

  @override
  bool isValidSchema({List cycleDetectionStack}) {
    cycleDetectionStack ??= [];
    for (var stackItem in cycleDetectionStack) {
      if (identical(stackItem, this)) {
        return true;
      }
    }
    cycleDetectionStack.add(this);
    final properties = this.properties;
    if (properties != null) {
      for (var schema in properties.values) {
        if (schema.isValidSchema(cycleDetectionStack: cycleDetectionStack)) {
          cycleDetectionStack.removeLast();
          return true;
        }
      }
    }
    final additionalValues = this.additionalValues;
    if (additionalValues != null &&
        additionalValues.isValidSchema(
            cycleDetectionStack: cycleDetectionStack)) {
      cycleDetectionStack.removeLast();
      return true;
    }
    cycleDetectionStack.removeLast();
    return false;
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
    if (argument == null) {
      return true;
    }
    if (argument is Map) {
      if (cycleDetectionStack != null) {
        for (var ancestor in cycleDetectionStack) {
          if (identical(ancestor, argument)) {
            return false;
          }
        }
      }
      cycleDetectionStack ??= [];
      cycleDetectionStack.add(argument);
      final requiredProperties = this.requiredProperties;
      if (requiredProperties != null) {
        for (var propertyName in requiredProperties) {
          if (!argument.containsKey(propertyName)) {
            cycleDetectionStack.removeLast();
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
            if (!valueSchema.isValidTree(value,
                cycleDetectionStack: cycleDetectionStack)) {
              cycleDetectionStack.removeLast();
              return false;
            }
          }
        }
      }
      cycleDetectionStack.removeLast();
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

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{};
    json['@type'] = name;

    final properties = this.properties;
    if (properties != null && properties.isNotEmpty) {
      for (var entry in properties.entries) {
        final valueJson = entry.value?.toJson();
        if (valueJson != null) {
          var key = entry.key;

          // '@example' --> '@@example'
          if (key.startsWith('@')) {
            key = '@$key';
          }

          // Put
          json[key] = entry.value?.toJson();
        }
      }
    }

    return json;
  }
}

abstract class PrimitiveSchema<T> extends Schema<T> {
  const PrimitiveSchema();

  @override
  bool isValidSchema({List cycleDetectionStack}) {
    return false;
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
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

  @override
  Object toJson() {
    return name;
  }
}

/// Describes valid values and decodes/encodes JSON.
abstract class Schema<T> {
  const Schema();

  /// Name of the type.
  String get name;

  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context);

  /// Converts a less typed tree (such as a JSON tree) into an immutable Dart
  /// tree of correct types.
  ///
  /// For example, `{'dateTime': '2020-01-01T00:00:00Z'}` could be converted
  /// into `{'dateTime': DateTime(2020,1,1)}`.
  T decodeLessTyped(
    Object argument, {
    @required LessTypedDecodingContext context,
  });

  /// Converts a Dart tree of correct types into a less typed tree (such as a
  /// JSON tree).
  ///
  /// For example, `{'dateTime': DateTime(2020,1,1)}` could be converted into
  /// `{'dateTime': '2020-01-01T00:00:00Z'}`.
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context});

  bool isInstance(Object value) => value is T;

  /// Determines whether the schema is valid.
  ///
  /// Optional argument [cycleDetectionStack] is used for detecting cycles.
  bool isValidSchema({List cycleDetectionStack});

  /// Determines whether the argument matches the schema.
  ///
  /// Optional argument [cycleDetectionStack] is used for detecting cycles.
  bool isValidTree(Object argument, {List cycleDetectionStack});

  /// Select a tree in a graph.
  T selectTree(Object argument, {bool ignoreErrors = false});

  Object toJson();

  static Schema fromJson(Object json) {
    if (json == null) {
      return null;
    }
    if (json is String) {
      switch (json) {
        case ArbitraryTreeSchema.nameForJson:
          return const ArbitraryTreeSchema();

        case BoolSchema.nameForJson:
          return const BoolSchema();

        case IntSchema.nameForJson:
          return const IntSchema();

        case Int64Schema.nameForJson:
          return const Int64Schema();

        case DoubleSchema.nameForJson:
          return const DoubleSchema();

        case DateTimeSchema.nameForJson:
          return const DateTimeSchema();

        case GeoPointSchema.nameForJson:
          return const GeoPointSchema();

        case StringSchema.nameForJson:
          return const StringSchema();

        case DocumentSchema.nameForJson:
          return const DocumentSchema();

        default:
          throw ArgumentError.value(json);
      }
    }
    if (json is List) {
      return ListSchema(
        itemsByIndex: List<Schema>.unmodifiable(json.map(Schema.fromJson)),
      );
    }
    if (json is Map) {
      final type = json['@type'];
      if (type != null) {
        if (type is String) {
          switch (type) {
            case ListSchema.nameForJson:
              return ListSchema(
                items: Schema.fromJson(json['@items']),
              );
            case MapSchema.nameForJson:
              break;
            default:
              throw ArgumentError('Invalid @type: $type');
          }
        } else {
          throw ArgumentError('Invalid @type: $type');
        }
      }
      final properties = <String, Schema>{};
      for (var entry in json.entries) {
        var key = entry.key;
        if (key.startsWith('@')) {
          if (key.startsWith('@@')) {
            key = key.substring(1);
          } else {
            // Do not add entry
            continue;
          }
        }
        final valueSchema = Schema.fromJson(entry.value);
        if (valueSchema == null) {
          continue;
        }
        properties[entry.key] = valueSchema;
      }
      return MapSchema(
        properties,
        additionalValues: Schema.fromJson(json['@additionalValues']),
      );
    }
    throw ArgumentError.value(json);
  }

  /// Constructs a schema from a Dart tree.
  static Schema fromValue(Object value, {List cycleDetectionStack}) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return BoolSchema();
    }
    if (value is double) {
      return DoubleSchema();
    }
    if (value is int) {
      return IntSchema();
    }
    if (value is Int64) {
      return Int64Schema();
    }
    if (value is DateTime) {
      return DateTimeSchema();
    }
    if (value is GeoPoint) {
      return GeoPointSchema();
    }
    if (value is String) {
      return StringSchema();
    }
    if (value is Document) {
      return DocumentSchema();
    }

    // Detect cycles
    cycleDetectionStack ??= [];
    for (var ancestor in cycleDetectionStack) {
      if (identical(ancestor, value)) {
        throw ArgumentError('Detected a cycle');
      }
    }
    cycleDetectionStack.add(value);

    try {
      if (value is List) {
        if (value.isEmpty) {
          return const ListSchema(itemsByIndex: []);
        }
        var itemSchemas = <Schema>[];
        var noNonNull = true;
        for (var item in value) {
          final schema =
              Schema.fromValue(item, cycleDetectionStack: cycleDetectionStack);
          itemSchemas.add(schema);
          noNonNull = false;
        }
        if (noNonNull) {
          itemSchemas = null;
        }
        return ListSchema(itemsByIndex: itemSchemas);
      }
      if (value is Map) {
        if (value.isEmpty) {
          return const MapSchema({});
        }
        final propertySchemas = <String, Schema>{};
        for (var entry in value.entries) {
          final valueSchema = Schema.fromValue(entry.value,
              cycleDetectionStack: cycleDetectionStack);
          if (valueSchema != null) {
            propertySchemas[entry.key] = valueSchema;
          }
        }
        return MapSchema(propertySchemas);
      }
      throw ArgumentError.value(value);
    } finally {
      cycleDetectionStack.removeLast();
    }
  }
}

/// Schema for [String] values.
class StringSchema extends PrimitiveSchema<String> {
  static const String nameForJson = 'string';

  final int maxLength;

  const StringSchema({this.maxLength});

  @override
  int get hashCode => (StringSchema).hashCode ^ maxLength.hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is StringSchema && maxLength == other.maxLength;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitStringSchema(this, context);
  }

  @override
  String decodeLessTyped(Object argument, {LessTypedDecodingContext context}) {
    if (argument == null) {
      return null;
    }
    return argument as String;
  }

  @override
  Object encodeLessTyped(Object argument, {LessTypedEncodingContext context}) {
    if (argument == null) {
      return null;
    }
    if (argument is String) {
      return argument;
    }
    throw ArgumentError.value(argument);
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
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
