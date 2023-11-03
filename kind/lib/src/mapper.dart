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

/// Maps constructor arguments of an [Immutable] instance.
///
/// ## Example
///
/// See [ImmutableKind].
abstract class Mapper {
  /// A mapper that clones an object tree.
  static const deepCloning = _DeepCloningMapper();

  const Mapper();

  /// Whether the mapper can return the same instance it was given.
  ///
  /// This can be used to optimize a mapper.
  ///
  /// ## Example
  /// ```
  /// class Example {
  ///   static const kind = ImmutableKind<Example>(
  ///     name: 'Example',
  ///     blank: Example(),
  ///     walk: _walk,
  ///   );
  ///   static Example _walk(Mapper f, Example t) {
  ///     // Map all fields:
  ///     final someField = f(t.someField, 'someField');
  ///
  ///     // Optimization: Check whether we can return the same instance.
  ///     if (f.canReturnSame) {
  ///       return t;
  ///     }
  ///     return Example(someField: someField);
  ///   }
  ///
  ///   final String someField;
  ///
  ///   const Example({this.someField});
  /// }
  /// ```
  bool get canReturnSame => false;

  /// Whether the mapper needs source code information such as constructor
  /// names.
  ///
  /// Default is false.
  bool get isGeneratingSource => false;

  /// A shorthand for calling [optional].
  ///
  /// Parameter [value] is the mapped value.
  ///
  /// Parameter [name] is the name of the named parameter.
  ///
  /// Optional parameter [kind] is the kind of the value. If omitted, the kind
  /// is inferred from type parameter [V] and [value] using [Kind.find].
  ///
  /// Optional parameter [defaultConstant] is the default value.
  ///
  /// Optional parameter [tags] is a list [Trait] instances such as
  /// [ProtobufFieldTag].
  @nonVirtual
  V call<V>(
    V value,
    String name, {
    Kind<V>? kind,
    Kind? superKind,
    V? defaultConstant,
    String? jsonName,
    List<Trait> tags = const [],
  }) {
    if (kind != null && superKind != null) {
      throw ArgumentError.value(
        superKind,
        'superKind',
        'Must be null if kind is not null',
      );
    }
    return handle<V>(
      parameterType: ParameterType.optionalNamed,
      value: value,
      name: name,
      kind: kind ?? superKind,
      defaultConstant: defaultConstant,
      jsonName: jsonName,
      tags: tags,
    );
  }

  /// Handles calls to [positional], [optionalPositional], [required], [call],
  /// [optional].
  V handle<V>({
    required ParameterType parameterType,
    required V value,
    required String name,
    Kind? kind,
    V? defaultConstant,
    String? jsonName,
    List<Trait>? tags,
  });

  /// Maps an optional named parameter of a constructor.
  ///
  /// Parameter [value] is the mapped value.
  ///
  /// Parameter [name] is the name of the named parameter.
  ///
  /// Optional parameter [kind] is the kind of the value. If omitted, the kind
  /// is inferred from type parameter [V] and [value] using [Kind.find].
  ///
  /// Optional parameter [defaultConstant] is the default value.
  ///
  /// Optional parameter [tags] is a list [Trait] instances such as
  /// [ProtobufFieldTag].
  ///
  /// The default implementation calls [required].
  ///
  /// ## Example
  ///
  /// See [ImmutableKind].
  @nonVirtual
  V optional<V>(
    V value,
    String name, {
    Kind<V>? kind,
    Kind? superKind,
    V? defaultConstant,
    String? jsonName,
    List<Trait> tags = const [],
  }) {
    if (kind != null && superKind != null) {
      throw ArgumentError.value(
        superKind,
        'superKind',
        'Must be null if kind is not null',
      );
    }
    return handle<V>(
      parameterType: ParameterType.optionalNamed,
      value: value,
      name: name,
      kind: kind ?? superKind,
      defaultConstant: defaultConstant,
      jsonName: jsonName,
      tags: tags,
    );
  }

  /// Maps an optional positional parameter of a constructor.
  ///
  /// Parameter [value] is the mapped value.
  ///
  /// Parameter [name] is the name of the positional parameter.
  ///
  /// Optional parameter [kind] is the kind of the value. If omitted, the kind
  /// is inferred from type parameter [V] and [value] using [Kind.find].
  ///
  /// Optional parameter [defaultConstant] is the default value.
  ///
  /// Optional parameter [tags] is a list [Trait] instances such as
  /// [ProtobufFieldTag].
  ///
  /// The default implementation calls [positional].
  ///
  /// ## Example
  ///
  /// See [ImmutableKind].
  @nonVirtual
  V optionalPositional<V>(
    V value,
    String name, {
    Kind<V>? kind,
    Kind? superKind,
    V? defaultConstant,
    String? jsonName,
    List<Trait> tags = const [],
  }) {
    if (kind != null && superKind != null) {
      throw ArgumentError.value(
        superKind,
        'superKind',
        'Must be null if kind is not null',
      );
    }
    return handle<V>(
      parameterType: ParameterType.optionalPositional,
      value: value,
      name: name,
      kind: kind ?? superKind,
      defaultConstant: defaultConstant,
      jsonName: jsonName,
      tags: tags,
    );
  }

  /// Maps a required positional parameter of a constructor.
  ///
  /// Parameter [value] is the mapped value.
  ///
  /// Parameter [name] is the name of the positional parameter.
  ///
  /// Optional parameter [kind] is the kind of the value. If omitted, the kind
  /// is inferred from type parameter [V] and [value] using [Kind.find].
  ///
  /// Optional parameter [defaultConstant] is the default value.
  ///
  /// Optional parameter [tags] is a list [Trait] instances such as
  /// [ProtobufFieldTag].
  ///
  /// The default implementation calls [required].
  ///
  /// ## Example
  ///
  /// See [ImmutableKind].
  @nonVirtual
  V positional<V>(
    V value,
    String name, {
    Kind<V>? kind,
    Kind? superKind,
    String? jsonName,
    List<Trait> tags = const [],
  }) {
    if (kind != null && superKind != null) {
      throw ArgumentError.value(
        superKind,
        'superKind',
        'Must be null if kind is not null',
      );
    }
    return handle<V>(
      parameterType: ParameterType.requiredPositional,
      value: value,
      name: name,
      kind: kind ?? superKind,
      jsonName: jsonName,
      tags: tags,
    );
  }

  /// Maps a required named parameter of a constructor.
  ///
  /// Parameter [value] is the mapped value.
  ///
  /// Parameter [name] is the name of the named parameter.
  ///
  /// Optional parameter [kind] is the kind of the value. If omitted, the kind
  /// is inferred from [V] and [value] using [Kind.find].
  ///
  /// Optional parameter [defaultConstant] is the default value.
  ///
  /// Optional parameter [tags] is a list [Trait] instances such as
  /// [ProtobufFieldTag].
  ///
  /// ## Example
  ///
  /// See [ImmutableKind].
  @nonVirtual
  V required<V>(
    V value,
    String name, {
    Kind<V>? kind,
    Kind? superKind,
    String? jsonName,
    List<Trait> tags = const [],
  }) {
    if (kind != null && superKind != null) {
      throw ArgumentError.value(
        superKind,
        'superKind',
        'Must be null if kind is not null',
      );
    }
    return handle<V>(
      parameterType: ParameterType.requiredNamed,
      value: value,
      name: name,
      kind: kind ?? superKind,
      jsonName: jsonName,
      tags: tags,
    );
  }

  /// Sets constructor identifier.
  ///
  /// This is used by [Kind.debugString].
  void setConstructorIdentifier(String identifier) {}

  /// Set default value.
  ///
  /// Must be called before declaring the field.
  void setDefaultValue(String name, Object? value) {}
}

enum ParameterType {
  optionalNamed,
  optionalPositional,
  requiredNamed,
  requiredPositional;

  bool get isNamed {
    switch (this) {
      case requiredNamed:
        return true;
      case optionalNamed:
        return true;
      default:
        return false;
    }
  }

  bool get isOptional {
    switch (this) {
      case optionalNamed:
        return true;
      case optionalPositional:
        return true;
      default:
        return false;
    }
  }

  bool get isPositional => !isNamed;

  bool get isRequired => !isOptional;
}

class _DeepCloningMapper extends Mapper {
  const _DeepCloningMapper();

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
    if (value == null || value is bool || value is num || value is String) {
      return value;
    }
    final actualKind = kind ?? Kind.find<V>(instance: value);
    return actualKind.clone(value);
  }
}
