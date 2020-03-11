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

import 'package:database/database.dart';
import 'package:database/schema.dart';
import 'package:fixnum/fixnum.dart' show Int64;

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

  void checkTreeIsValid(Object argument, {List<Object> stack}) {
    if (isValidTree(argument)) {
      return;
    }
    stack ??= const <Object>[];
    throw ArgumentError('Invalid tree: /${stack.join('/')}');
  }

  T decodeWith(SchemaBasedConverterBase visitor, Object argument) {
    final result = acceptVisitor(visitor, argument);
    if (result == null) {
      return result;
    }
    return result as T;
  }

  Object encodeWith(SchemaBasedConverterBase visitor, T argument) {
    return acceptVisitor(visitor, argument);
  }

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
          final valueSchema = Schema.fromValue(
            entry.value,
            cycleDetectionStack: cycleDetectionStack,
          );
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
