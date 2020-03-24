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

/// A schema for lists.
///
/// ## Example
/// ```
/// const recipeSchema = MapSchema(
///   properties: {
///     'title': StringSchema(),
///     'rating': DoubleSchema(),
///     'similar': ListSchema(
///       items: DocumentSchema(
///         collection:'recipes',
///       ),
///     ),
///   },
/// );
/// ```
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
  void checkTreeIsValid(Object argument, {List<Object> stack}) {
    if (isValidTree(argument)) {
      return;
    }
    stack ??= [];
    if (argument is List) {
      if (maxLength != null && argument.length > maxLength) {
        throw StateError(
          'List has ${argument.length} items, which exceeds maximum $maxLength: /${stack.join('/')}',
        );
      }
      final itemsSchema = items;
      if (itemsSchema != null) {
        stack ??= <Object>[];
        for (var i = 0; i < argument.length; i++) {
          stack.add(i);
          itemsSchema.checkTreeIsValid(argument[i], stack: stack);
          stack.removeLast();
        }
      }
      throw StateError(
        'An error somewhere in: /${stack.join('/')}',
      );
    } else {
      throw StateError(
        'Expected List in: /${stack.join('/')}',
      );
    }
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
