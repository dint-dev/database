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

import 'dart:math';
import 'dart:typed_data';

import '../kind.dart';

/// Provides access to fields of some object.
///
/// Use [Kind.instanceMirror] to get an instance of this class.
///
/// ## Example
/// ```
/// import 'package:kind/kind.dart';
///
/// void main() {
///   // Get example
///   final example = Example();
///   final mirror = Example.kind.instanceMirror(example);
///   final fieldNames = mirror.fieldNames;
///   print(fieldNames.join(', '));
/// }
///
/// // ...
/// ```
abstract class InstanceMirror implements Comparable<InstanceMirror> {
  static const forPrimitive = _InstanceMirror();

  static final _expando = Expando<_ImmutableInstanceMirror>('instanceMirror');

  const InstanceMirror.constructor();

  /// Mirrors for each field.
  Iterable<FieldMirror> get fieldMirrors;

  @override
  int compareTo(InstanceMirror other) {
    final fieldMirrors = this.fieldMirrors.toList();
    final otherFieldMirrors = other.fieldMirrors.toList();
    final length = min<int>(fieldMirrors.length, otherFieldMirrors.length);
    for (var i = 0; i < length; i++) {
      final fieldMirror = fieldMirrors[i];
      final otherFieldMirror = otherFieldMirrors[i];
      if (fieldMirror.traits.contains(Trait.noEquality)) {
        return -1;
      }
      if (otherFieldMirror.traits.contains(Trait.noEquality)) {
        return 1;
      }
      {
        final r = fieldMirror.name.compareTo(otherFieldMirror.name);
        if (r != 0) {
          return r;
        }
      }
      final fieldValue = get(fieldMirror.name);
      final otherFieldValue = get(otherFieldMirror.name);
      final r = fieldMirror.kind.compare(fieldValue, otherFieldValue);
      if (r != 0) {
        return 0;
      }
    }
    return 0;
  }

  /// Returns value of field [name].
  ///
  /// Throws [ArgumentError] if there is no such field.
  Object? get(String name) {
    throw ArgumentError.value(name, 'name', 'No such field');
  }

  /// Returns [Kind] of field [name].
  ///
  /// Throws [ArgumentError] if there is no such field.
  FieldMirror getFieldMirror(String name) {
    for (var fieldMirror in fieldMirrors) {
      if (name == fieldMirror.name) {
        return fieldMirror;
      }
    }
    throw ArgumentError.value(name, 'name', 'No such field');
  }

  /// Returns fields as a map.
  Map<String, Object?> toMap() {
    final result = <String, Object?>{};
    for (var fieldMirror in fieldMirrors) {
      final name = fieldMirror.name;
      result[name] = get(name);
    }
    return result;
  }

  /// Returns an instance mirror for [instance].
  ///
  /// If [kind] is specified, it is used instead of [Kind.find]. Otherwise
  /// [Kind.find] is used.
  static InstanceMirror of<T>(Object? instance, {required Kind? kind}) {
    if (instance == null ||
        instance is bool ||
        instance is num ||
        instance is String ||
        instance is DateTime ||
        instance is TypedData) {
      return const _InstanceMirror();
    }
    final expando = _expando;
    final existing = expando[instance];
    if (existing != null) {
      return existing;
    }
    _ImmutableInstanceMirrorBuilder builder;
    if (instance is Walkable) {
      builder = _ImmutableInstanceMirrorBuilder(instance.runtimeType);
      instance.walk(builder);
    } else {
      kind ??= Kind.find(instance: instance);
      if (kind is! ImmutableKind) {
        assert(false);
        return const _InstanceMirror();
      }
      builder = _ImmutableInstanceMirrorBuilder(instance.runtimeType);
      kind.map(builder, instance);
    }
    final mirror = builder._build();
    expando[instance] = mirror;
    return mirror;
  }
}

class _ImmutableInstanceMirror extends InstanceMirror {
  final List<FieldMirror> _fieldMirrors;
  final List<Object?> _values;

  _ImmutableInstanceMirror({
    required List<FieldMirror> fieldMirrors,
    required List<Object?> values,
  })  : _fieldMirrors = fieldMirrors,
        _values = values,
        super.constructor();

  @override
  Iterable<FieldMirror> get fieldMirrors => _fieldMirrors;

  @override
  int get hashCode {
    var h = 0;
    for (var fieldMirror in _fieldMirrors) {
      if (fieldMirror.traits.contains(Trait.noEquality)) {
        continue;
      }
      final value = get(fieldMirror.name);
      if (value == null ||
          value is bool ||
          value is num ||
          value is String ||
          value is DateTime) {
        h ^= value.hashCode;
      }
    }
    return h;
  }

  @override
  bool operator ==(other) {
    if (other is! _ImmutableInstanceMirror) {
      return false;
    }

    // Are the length are equal?
    final leftFieldMirrors = _fieldMirrors;
    final rightFieldMirrors = other._fieldMirrors;
    if (leftFieldMirrors.length != rightFieldMirrors.length) {
      return false;
    }

    // For item.
    final leftValues = _values;
    final rightValues = other._values;
    for (var i = 0; i < leftFieldMirrors.length; i++) {
      // Are names equal?
      final fieldMirror = leftFieldMirrors[i];
      if (fieldMirror != rightFieldMirrors[i]) {
        return false;
      }

      if (fieldMirror.traits.contains(Trait.noEquality)) {
        continue;
      }

      final fieldKind = fieldMirror.kind;
      final leftValue = leftValues[i];
      final rightValue = rightValues[i];
      if (!fieldKind.equality.equals(leftValue, rightValue)) {
        return false;
      }
    }
    return true;
  }

  @override
  Object? get(String name) {
    final fieldMirrors = _fieldMirrors;
    for (var i = 0; i < fieldMirrors.length; i++) {
      if (fieldMirrors[i].name == name) {
        return _values[i];
      }
    }
    return super.get(name);
  }
}

class _ImmutableInstanceMirrorBuilder extends Mapper {
  static final _defaultFieldMirrorLists = <Type, List<FieldMirror>>{};

  final Type _type;
  int _nextIndex = 0;
  List<FieldMirror>? _fieldMirrors;
  List<Object?>? _values;

  _ImmutableInstanceMirrorBuilder(Type type) : _type = type {
    final existingFieldMirrors = _defaultFieldMirrorLists[type];
    if (existingFieldMirrors == null) {
      _fieldMirrors = [];
      _values = [];
      _nextIndex = -1;
    } else {
      _fieldMirrors = existingFieldMirrors;
      _values = List<Object?>.filled(existingFieldMirrors.length, null);
      _nextIndex = 0;
    }
  }

  @override
  bool get canReturnSame => true;

  @override
  V handle<V>({
    required ParameterType parameterType,
    required V value,
    required String name,
    Kind? kind,
    V? defaultConstant,
    String? jsonName,
    List<Trait>? tags,
  }) {
    kind ??= Kind.find<V>(instance: value);
    if (null is V) {
      kind = kind.toNullable();
    }
    final actualDefaultConstant = defaultConstant ?? kind.newInstance();

    final fieldMirrors = _fieldMirrors!;
    final values = _values!;
    final nextIndex = _nextIndex;
    if (nextIndex >= 0) {
      final fieldMirror = fieldMirrors[nextIndex];
      if (fieldMirror.name != name) {
        throw StateError(
          'Previous mirror has different name: "${fieldMirror.name}" != "$name"',
        );
      }
      if (fieldMirror.kind != kind) {
        throw StateError(
          'Previous mirror for field "$name" has different kind',
        );
      }
      if (!kind.equality.equals(
        fieldMirror.defaultValue,
        actualDefaultConstant,
      )) {
        throw StateError(
          'Previous mirror for field "$name" is different default value:'
          ' ${fieldMirror.defaultValue} != $actualDefaultConstant',
        );
      }
      values[nextIndex] = value;
      _nextIndex = nextIndex + 1;
    } else {
      fieldMirrors.add(FieldMirror<V>(
        name: name,
        jsonName: jsonName ?? name,
        kind: kind,
        defaultValue: actualDefaultConstant,
      ));
      values.add(value);
    }
    return value;
  }

  _ImmutableInstanceMirror _build() {
    var fieldMirrors = _fieldMirrors!;
    var values = _values!;
    final nextIndex = _nextIndex;
    if (nextIndex == -1) {
      fieldMirrors = List<FieldMirror>.unmodifiable(fieldMirrors);
      values = List<Object?>.unmodifiable(values);
      _defaultFieldMirrorLists[_type] = fieldMirrors;
    } else if (nextIndex != fieldMirrors.length) {
      throw StateError('Did not declare all properties.');
    }
    final result = _ImmutableInstanceMirror(
      fieldMirrors: fieldMirrors,
      values: values,
    );
    _nextIndex = 0;
    _fieldMirrors = null;
    _values = null;
    return result;
  }
}

class _InstanceMirror extends InstanceMirror {
  const _InstanceMirror() : super.constructor();

  @override
  Iterable<FieldMirror> get fieldMirrors => const [];
}
