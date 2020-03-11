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
import 'package:meta/meta.dart';

/// A schema for arbitrary trees.
@sealed
class ArbitraryTreeSchema extends Schema<Object> {
  static const String nameForJson = '*';

  final DoubleSchema doubleSchema;

  const ArbitraryTreeSchema({
    this.doubleSchema = const DoubleSchema(),
  });

  @override
  int get hashCode => (ArbitraryTreeSchema).hashCode ^ doubleSchema.hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is ArbitraryTreeSchema && doubleSchema == other.doubleSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitArbitraryTreeSchema(this, context);
  }

  @override
  bool isValidSchema({List cycleDetectionStack}) {
    return true;
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
    if (argument is double) {
      return doubleSchema.isValidTree(argument);
    }
    if (argument == null ||
        argument is bool ||
        argument is int ||
        argument is Int64 ||
        argument is Date ||
        argument is DateTime ||
        argument is Timestamp ||
        argument is GeoPoint ||
        argument is String ||
        argument is Uint8List ||
        argument is Document) {
      return true;
    }
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
    return false;
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
