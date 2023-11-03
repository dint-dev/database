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

/// [Kind] for [Enum] subclasses.
///
/// By default, the first value is the default value.
///
/// ## Example
/// ```
/// import 'package:kind/kind.dart';
///
/// enum OperatingSystem {
///   android,
///   ios,
///   mac,
///   linux,
///   windows;
///
///   static const kind = EnumKind<OperatingSystem>(
///     name: 'OperatingSystem',
///     values: OperatingSystem.values,
///   );
/// }
/// ```
final class EnumKind<T extends Enum> extends Kind<T>
    with PrimitiveKindMixin<T> {
  /// Possible values.
  final List<T> values;

  final T? _defaultValue;

  const EnumKind({
    required super.name,
    super.jsonName,
    required this.values,
    T? defaultValue,
    super.traits,
  })  : _defaultValue = defaultValue,
        super.constructor();

  @override
  Iterable<T> get examples => values;

  @override
  Iterable<T> get examplesWithoutValidation {
    return values;
  }

  @override
  int get hashCode =>
      Object.hash(EnumKind, Object.hashAll(values), super.hashCode) ^
      super.hashCode;

  @override
  bool operator ==(other) =>
      other is EnumKind &&
      const ListEquality().equals(values, other.values) &&
      newInstance() == other.newInstance() &&
      super == other;

  @override
  int compare(T left, T right) {
    return left.index.compareTo(right.index);
  }

  @override
  T decodeJsonTree(Object? json) {
    final values = this.values;
    if (json is String) {
      return decodeString(json);
    } else if (json is num) {
      final searchedIndex = json.toInt();
      RangeError.checkValidIndex(
        searchedIndex,
        values,
        'values',
        values.length,
      );
      return values[searchedIndex];
    } else {
      throw ArgumentError.value(json);
    }
  }

  @override
  T decodeString(String string) {
    for (var value in values) {
      if (value.name == string) {
        return value;
      }
    }
    throw ArgumentError.value(string);
  }

  @override
  Object? encodeJsonTree(T instance) {
    return encodeString(instance);
  }

  @override
  String encodeString(T instance) {
    return instance.name;
  }

  @override
  bool isValid(T instance) {
    return values.contains(instance) && super.isValid(instance);
  }

  @override
  T newInstance() {
    return _defaultValue ?? values.first;
  }

  @override
  T permute(T instance) {
    final values = this.values;
    if (values.length < 2) {
      return instance;
    }
    return values[(instance.index + 1) % values.length];
  }
}
