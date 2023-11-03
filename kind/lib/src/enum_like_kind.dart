// Copyright 2021 Gohilla Ltd.
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

import '../kind.dart';

/// [Kind] for [Enum]-like classes that do not implement [Enum].
///
/// Use [EnumKind] for classes that do implement [Enum].
///
/// ## Example
/// ```
/// import 'package:kind/kind.dart';
///
/// class Example {
///   static const kind = EnumKind<Example>(
///     name: 'Example',
///     byName: {
///       'value0': value0,
///       'value1': value1,
///     },
///   );
///
///   static const value0 = Example._('value0');
///   static const value1 = Example._('value1');
///
///   final String name;
///
///   Example._(this.name);
/// }
/// ```
class EnumLikeKind<T> extends Kind<T> with PrimitiveKindMixin<T> {
  /// Possible values.
  final Map<String, T> byName;

  final T? _defaultValue;

  const EnumLikeKind({
    required super.name,
    required this.byName,
    T? defaultValue,
  })  : _defaultValue = defaultValue,
        super.constructor();

  @override
  Iterable<T> get examplesWithoutValidation {
    return byName.values;
  }

  @override
  int get hashCode =>
      Object.hash(name, const MapEquality().hash(byName)) ^ super.hashCode;

  @override
  bool operator ==(other) =>
      other is EnumLikeKind &&
      const MapEquality().equals(byName, other.byName) &&
      newInstance() == other.newInstance() &&
      super == other;

  @override
  int compare(T left, T right) {
    return indexOf(left).compareTo(indexOf(right));
  }

  @override
  String debugString(T instance) {
    return '$name.${nameOf(instance)}';
  }

  @override
  T decodeJsonTree(Object? json) {
    final values = this.byName;
    if (json is String) {
      final value = byName[json];
      if (value != null) {
        return value;
      }
    } else if (json is num) {
      final searchedIndex = json.toInt();
      if (json >= 0 && json < values.length) {
        var i = 0;
        for (var item in byName.values) {
          if (i == searchedIndex) {
            return item;
          }
          i++;
        }
      }
    }
    throw ArgumentError.value(json);
  }

  @override
  T decodeString(String string) {
    return decodeJsonTree(string);
  }

  @override
  String encodeJsonTree(T instance) {
    final s = nameOf(instance);
    if (s == null) {
      throw StateError('Invalid value: $instance');
    }
    return s;
  }

  @override
  String encodeString(T instance) {
    return encodeJsonTree(instance);
  }

  int indexOf(T argument) {
    var i = 0;
    for (var item in byName.values) {
      if (identical(item, argument)) {
        return i;
      }
      assert(item != argument);
      i++;
    }
    return -1;
  }

  @override
  bool isValid(T instance) {
    return byName.values.contains(instance) && super.isValid(instance);
  }

  String? nameOf(T value) {
    for (var entry in byName.entries) {
      if (identical(entry.value, value)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  T newInstance() {
    return _defaultValue ?? byName.values.first;
  }

  @override
  T permute(T instance) {
    var previousWasEqual = false;
    for (var value in byName.values) {
      if (previousWasEqual) {
        return value;
      } else if (value == instance) {
        previousWasEqual = true;
      }
    }
    if (previousWasEqual) {
      return byName.values.first;
    }
    return instance;
  }
}
