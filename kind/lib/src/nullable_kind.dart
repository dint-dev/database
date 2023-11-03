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

import 'package:meta/meta.dart';

import '../kind.dart';

/// [Kind] for nullable types.
///
/// ## Example
/// ```
/// import 'package:kind/kind.dart';
///
/// final nullableString = StringKind().toNullable();
/// ``
final class NullableKind<T> extends Kind<T?> {
  /// Non-nullable kind.
  final Kind<T> elementKind;

  @literal
  const NullableKind(this.elementKind) : super.constructor(name: 'Nullable');

  @override
  Iterable<T?> get examplesWithoutValidation sync* {
    yield (null);
    yield* (elementKind.examplesWithoutValidation);
  }

  @override
  int get hashCode => Object.hash(NullableKind, elementKind) ^ super.hashCode;

  @override
  bool get isNullable => true;

  @override
  String get name => '${elementKind.name}?';

  @override
  List<Trait> get traits => elementKind.traits;

  @override
  bool operator ==(Object other) =>
      other is NullableKind &&
      elementKind == other.elementKind &&
      super == other;

  @override
  // ignore: must_call_super
  void checkValid(T? instance) {
    if (instance == null) {
      return;
    }
    elementKind.checkValid(instance);
  }

  @override
  T? clone(T? instance) {
    if (instance == null) {
      return null;
    }
    return elementKind.clone(instance);
  }

  @override
  int compare(T? left, T? right) {
    if (left == null) {
      if (right == null) {
        return 0;
      }
      return -1;
    }
    if (right == null) {
      return 1;
    }
    return elementKind.compare(left, right);
  }

  @override
  String debugString(T? instance) {
    if (instance == null) {
      return 'null';
    }
    return elementKind.debugString(instance);
  }

  @override
  T? decodeJsonTree(Object? json) {
    if (json == null) {
      return null;
    }
    return elementKind.decodeJsonTree(json);
  }

  @override
  Object? encodeJsonTree(T? instance) {
    if (instance == null) {
      return null;
    }
    return elementKind.encodeJsonTree(instance);
  }

  @override
  bool isDefaultValue(Object? instance) {
    return instance == null;
  }

  @override
  // ignore: must_call_super
  bool isValid(T? instance) {
    return instance == null || elementKind.isValid(instance);
  }

  @override
  int memorySize(T? instance) {
    if (instance == null) {
      return 8;
    }
    return elementKind.memorySize(instance);
  }

  @override
  void memorySizeWith(MemoryCounter counter, T? instance) {
    if (instance == null) {
      counter.add(8);
    } else {
      elementKind.memorySizeWith(counter, instance);
    }
  }

  @override
  T? newInstance() {
    return null;
  }

  @override
  T? permute(T? instance) {
    if (instance == null) {
      return elementKind.newInstance();
    }
    return elementKind.permute(instance);
  }

  @override
  Kind<T> toNonNullable() => elementKind;

  @override
  NullableKind<T> toNullable() => this;

  @override
  String toString() {
    return 'NullableKind($elementKind)';
  }
}
