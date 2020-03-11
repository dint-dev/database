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

import 'package:collection/collection.dart';
import 'package:database/schema.dart';
import 'package:meta/meta.dart';

/// A schema for maps.
///
/// ## Example
/// ```
/// const recipeSchema = MapSchema(
///   properties: {
///     'title': StringSchema(),
///     'rating': DoubleSchema(),
///     'similar': ListSchema(
///       items: DocumentSchema(
///         collection:'recipes'
///       ),
///     ),
///   },
/// );
/// ```
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
  void checkTreeIsValid(Object argument, {List<Object> stack}) {
    if (isValidTree(argument)) {
      return;
    }
    stack ??= [];
    if (argument is Map) {
      final properties = this.properties ?? <String, Schema>{};
      final additionalValues = this.additionalValues;
      for (var key in argument.keys) {
        stack.add(key);
        final valueSchema = properties[key] ?? additionalValues;
        if (valueSchema == null) {
          throw StateError(
            'Unexpected property in: /${stack.join('/')}',
          );
        }
        valueSchema.checkTreeIsValid(argument[key], stack: stack);
        stack.removeLast();
      }
      throw StateError(
        'An error somewhere in: /${stack.join('/')}',
      );
    } else {
      throw StateError(
        'Expected Map<String,Object> in: /${stack.join('/')}',
      );
    }
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
