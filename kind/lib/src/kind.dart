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

import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:os/os.dart';

import '../kind.dart';

/// Describes how to construct an instance of some type [T].
///
/// # Fixed-width types
///  * [BoolKind] (or constant [Kind.forBool])
///  * [IntKind] (or constant [Kind.forInt])
///  * [FloatKind] (or constant [Kind.forDouble])
///  * [DateTimeKind] (or constant [Kind.forDateTime])
///  * [DurationKind] (or constant [Kind.forDuration])
///  * [EnumKind]
///  * [EnumLikeKind]
///
/// # Variable-width types
///  * [StringKind] (or constant [Kind.forString])
///  * [Uint8ListKind] (or constant [Kind.forUint8List])
///
/// # Nullable types and collections
///  * [NullableKind] (or [toNullable])
///  * [ListKind] (or [toList])
///  * [SetKind] (or [toSet])
///  * [MapKind]
///
/// # Custom objects
///   * [ImmutableKind]
@immutable
abstract class Kind<T> {
  /// [Kind] for [Null] (null).
  // ignore: prefer_void_to_null
  static const Kind<Null> forNull = _NullKind();

  /// [Kind] for [bool].
  static const Kind<bool> forBool = BoolKind();

  /// [Kind] for [int].
  static const Kind<int> forInt = IntKind();

  /// [Kind] for [double].
  static const Kind<double> forDouble = FloatKind();

  /// [Kind] for [DateTime].
  static const Kind<DateTime> forDateTime = DateTimeKind.utc();

  /// [Kind] for [Duration].
  static const Kind<Duration> forDuration = DurationKind();

  /// [Kind] for [BigInt].
  static const Kind<BigInt> forBigInt = BigIntKind();

  /// [Kind] for [String].
  static const Kind<String> forString = StringKind();

  /// [Kind] for [Uint8List].
  static const Kind<Uint8List> forUint8List = Uint8ListKind();

  /// [Kind] for [Kind].
  static const forKindInDebugMode = PolymorphicKind<Kind>(
    defaultKinds: [
      // By default, we include these only in debug mode.
      if (isRunningInDebugMode) ...[
        BoolKind.kindForKind,
        IntKind.kindForKind,
        FloatKind.kindForKind,
        StringKind.kindForKind,
      ],
    ],
  );

  /// An allocation-minimizing optimization for [toNullable].
  static final _expandoForToNullable = Expando<NullableKind>('toNullable');

  /// An allocation-minimizing optimization for [toList].
  static final _expandoForToList = Expando<ListKind>('toList');

  /// An allocation-minimizing optimization for [toSet].
  static final _expandoForToSet = Expando<SetKind>('toSet');

  /// An allocation-minimizing optimization for [isDefaultValue].
  static final _expandoForDefaultValue = Expando('defaultValue');

  /// Default primitive kinds.
  static const defaultPrimitiveKinds = <Kind>[
    forNull,
    forBool,
    forInt,
    forDouble,
    forString,
    forUint8List,
    forDateTime,
    forDuration,
  ];

  /// All registered kinds.
  ///
  /// Items to this list are added by [register].
  static final _kinds = <Kind>{
    ...defaultPrimitiveKinds,
  };

  /// All registered kinds, nullable variants.
  ///
  /// This is an optimization used by [Kind.maybeFindByType].
  ///
  /// Items to this list are added by [register].
  static final _nullableKinds = _kinds.map((e) => e.toNullable()).toList();

  /// All registered kinds.
  ///
  /// You can register kinds with [Kind.registerAll].
  ///
  /// ## Example
  /// ```
  /// import 'package:kind/kind.dart';
  ///
  /// void main() {
  ///   Kind.registerAll([
  ///     Example.kind,
  ///   ]);
  ///   print(Kind.all.contains(Example.kind)); // true
  /// }
  /// ```
  static final Set<Kind> all = UnmodifiableSetView(_kinds);

  static final _expandoForDefaultValueMirror =
      Expando<InstanceMirror>('defaultValue');

  final String? _name;

  /// JSON identifier of the class.
  final String? jsonName;

  /// Traits of the kind.
  final List<Trait> traits;

  /// Examples.
  final List<T>? _examples;

  /// Constructor for subclasses.
  const Kind.constructor({
    required String? name,
    this.jsonName,
    List<Trait>? traits,
    List<T>? examples,
  })  : _name = name,
        traits = traits ?? const [],
        _examples = examples;

  /// Type [T].
  Type get dartType => T;

  /// [InstanceMirror] for the default value.
  InstanceMirror get defaultValueMirror =>
      _expandoForDefaultValueMirror[this] ??=
          InstanceMirror.of(newInstance(), kind: this);

  /// Equality for the kind;
  Equality get equality => const DeepCollectionEquality();

  /// Examples of instances that are valid ([isValidDynamic]).
  Iterable<T> get examples =>
      _examples ?? examplesWithoutValidation.where(isValidDynamic);

  /// Examples of instances that are NOT valid ([isValidDynamic]).
  @nonVirtual
  Iterable<T> get examplesThatAreInvalid =>
      examplesWithoutValidation.where((e) => !isValidDynamic(e));

  /// Interesting examples of instances (may be valid or invalid).
  ///
  /// Use [examples] to get valid examples.
  ///
  /// Use [examplesThatAreInvalid] to get invalid examples.
  Iterable<T> get examplesWithoutValidation => _examples ?? const [];

  @mustCallSuper
  @override
  int get hashCode => name.hashCode ^ const ListEquality().hash(traits);

  /// Whether this kind is nullable.
  bool get isNullable => false;

  /// Whether instances of the kind can't have references to other instances.
  bool get isPrimitive => false;

  /// Dart identifier of the class.
  String get name => _name ?? T.toString();

  @mustCallSuper
  @override
  bool operator ==(other) =>
      other is Kind &&
      name == other.name &&
      const ListEquality().equals(traits, other.traits);

  /// Casts [value] to [T].
  T asType(Object? value) {
    return value as T;
  }

  /// Checks that the declaration makes sense.
  @mustCallSuper
  void checkDeclaration() {}

  void checkInstance(Object? value) {
    if (value is! T) {
      throw ArgumentError.value(value, 'value', 'Not an instance of $T');
    }
  }

  @mustCallSuper
  void checkValid(T instance) {
    if (!isValid(instance)) {
      throw newInvalidValueError(
        kind: this,
        instance: instance,
      );
    }
  }

  /// Throws [ArgumentError] error if [instance] is not valid ([isValidDynamic]).
  @nonVirtual
  void checkValidDynamic(Object? instance) {
    if (instance is T) {
      checkValid(instance);
    } else {
      throw newInvalidValueError(
        kind: this,
        instance: instance,
      );
    }
  }

  /// Clones the instance.
  T clone(T instance) {
    return instance;
  }

  /// Compares two values.
  int compare(T left, T right) {
    return convert
        .jsonEncode(encodeJsonTree(left))
        .compareTo(convert.jsonEncode(encodeJsonTree(right)));
  }

  /// Constructs a string for debugging [instance].
  String debugString(T instance) {
    return instance.toString();
  }

  /// Converts [json] (any JSON tree) to an instance of [T].
  ///
  /// Throws [ArgumentError] if the JSON does not match.
  T decodeJsonTree(Object? json);

  /// Decodes [string] to an instance of [T].
  T decodeString(String string) {
    throw UnsupportedError('$runtimeType does not support this');
  }

  /// Converts [instance] to a JSON tree.
  ///
  /// Before calling this method, you should call [isInstance] to check whether
  /// [instance] is an instance of [T] .
  Object? encodeJsonTree(T instance);

  /// Converts [instance] to a string.
  String encodeString(T instance) {
    throw UnsupportedError('$runtimeType does not support this');
  }

  /// Determines whether the argument is a default value of this kind.
  ///
  /// You can construct a default value with [newInstance].
  bool isDefaultValue(Object? instance) {
    return instance is T &&
        equality.equals(
            instance, _expandoForDefaultValue[this] ??= newInstance());
  }

  /// Determines whether the argument is an instance of [T].
  ///
  /// Use [isDefaultValue] to check whether something is a default value of
  /// this kind.
  bool isInstance(Object? instance) => instance is T;

  /// Determines whether the argument is an instance of `List<T>`.
  bool isInstanceOfList(Object? instance) => instance is List<T>;

  /// Determines whether the argument is an instance of `Set<T>`.
  bool isInstanceOfSet(Object? instance) => instance is Set<T>;

  /// Tells whether the argument is instance of `Kind<T>` and [dartType]
  /// values are different.
  bool isNullableSubKind(Kind other, {bool andNotEqual = true}) {
    return other is Kind<T?> &&
        (!andNotEqual || !other.isNullableSubKind(this, andNotEqual: false));
  }

  /// Tells whether the argument is instance of `Kind<T>` and [dartType]
  /// values are different.
  bool isSubKind(Kind other, {bool andNotEqual = true}) {
    return other is Kind<T> &&
        (!andNotEqual || !other.isSubKind(this, andNotEqual: false));
  }

  /// Tells whether the instance is valid.
  @mustCallSuper
  bool isValid(T instance) {
    return true;
  }

  /// Tells whether the instance is valid.
  @nonVirtual
  bool isValidDynamic(Object? instance) {
    return instance is T && isValid(instance);
  }

  /// Estimates memory usage of [instance].
  int memorySize(T instance) {
    final builder = MemoryCounter();
    memorySizeWith(builder, instance);
    return builder.memoryUsageInBytes;
  }

  /// Estimates memory usage with an instance of [MemoryCounter].
  void memorySizeWith(MemoryCounter counter, T instance);

  /// Constructs a new instance of the default value.
  ///
  /// Use [isDefaultValue] to determine whether something is a default value of
  /// this kind.
  T newInstance();

  /// Constructs a new list.
  ///
  /// If [growable] is false and the kind is either [IntKind] or [FloatKind],
  /// the method returns a [TypedData] object such as [Uint32List].
  List<T> newList(int length, {bool growable = true}) {
    if (isPrimitive) {
      final fill = newInstance();
      return List<T>.filled(
        length,
        fill,
        growable: growable,
      );
    }
    return List<T>.generate(
      length,
      (index) => newInstance(),
      growable: growable,
    );
  }

  /// Constructs a new list from [iterable].
  List<T> newListFrom(Iterable<T> iterable, {bool growable = true}) {
    final result = newList(iterable.length, growable: growable);
    result.setAll(0, iterable);
    return result;
  }

  /// Generates another instance with some deterministic function.
  ///
  /// The only exception is [Kind.forNull] (because it has no other instances).
  T permute(T instance);

  /// Registers this kind so that it will be visible in [Kind.all].
  ///
  /// Use [Kind.registerAll] to register multiple kinds at once.
  void register() {
    if (!_kinds.contains(this)) {
      _kinds.add(this);
      _nullableKinds.add(toNullable());
    }
  }

  /// Constructs [Kind] for `List<T>`.
  Kind<List<T>> toList() => (_expandoForToList[this] ??=
      ListKind<T>(elementKind: this)) as ListKind<T>;

  /// Returns a non-nullable kind.
  Kind<T> toNonNullable() => this;

  /// Constructs [Kind] for `T?`.
  Kind<T?> toNullable() => (_expandoForToNullable[this] ??=
      NullableKind<T>(this)) as NullableKind<T>;

  /// Constructs a [PolymorphicKind] for this kind.
  ///
  /// If this is already a [PolymorphicKind], returns `this`.
  PolymorphicKind<T> toPolymorphic() {
    return PolymorphicKind<T>(
      name: name,
      defaultKinds: [this],
    );
  }

  /// Constructs [Kind] for `Set<T>`.
  Kind<Set<T>> toSet() =>
      (_expandoForToSet[this] ??= SetKind<T>(elementKind: this)) as SetKind<T>;

  /// Finds a registered kind for [T].
  ///
  /// If [instance] implements [HasKind], the method tries to determine
  /// the kind with [HasKind.runtimeKind].
  ///
  /// If no kind has been found and [instance] is non-null, the method seeks
  /// the best kind for which [Kind.isInstance] is true.
  ///
  /// If no kind has been found, the method tries to find a kind that has
  /// exactly the same type as [T] ([Kind.dartType]).
  ///
  /// If no kind was found, the method inspects whether [T] is a list type of
  /// one of the registered kinds in [Kind.all].
  ///
  /// If no kind was found, the method inspects whether [T] is a set type of one
  /// of the registered kinds in [Kind.all].
  ///
  /// Whenever [T] is nullable, the method returns a [NullableKind].
  ///
  /// Throws [ArgumentError] if no kind is registered for [T].
  static Kind<T> find<T>({T? instance}) {
    if (instance == null) {
      final kind = maybeFindByType<T>();
      if (kind != null) {
        return kind;
      }
      throw ArgumentError(
        'Could not find kind for $T.\n'
        '\n'
        'Registered kinds are: ${_kinds.map((e) => e.dartType).join(', ')}',
      );
    } else {
      final kind = maybeFindByInstance<T>(instance);
      if (kind != null) {
        return kind;
      }
      throw ArgumentError(
        'Could not find kind for $T (given an instance of ${instance.runtimeType}).\n'
        '\n'
        'Registered kinds are: ${_kinds.map((e) => e.dartType).join(', ')}',
      );
    }
  }

  /// Finds a registered kind for [instance].
  static Kind<T>? maybeFindByInstance<T>(T instance) {
    var kind = _maybeFindByInstance<T>(instance);
    if (kind == null) {
      return maybeFindByType<T>();
    }
    if (null is T) {
      if (identical(kind, Kind.forNull)) {
        return kind;
      }
      return kind.toNullable() as Kind<T>;
    }
    return kind;
  }

  /// Finds a registered kind for [T].
  ///
  /// First he method inspects whether [T] is equal to one of the registered
  /// kinds in [Kind.all].
  ///
  /// If no kind was found, the method inspects whether [T] is a list type of
  /// one of the registered kinds in [Kind.all].
  ///
  /// If no kind was found, the method inspects whether [T] is a set type of one
  /// of the registered kinds in [Kind.all].
  ///
  /// Note that if a kind is found and [T] is nullable, the method returns a
  /// [NullableKind].
  static Kind<T>? maybeFindByType<T>() {
    if (T == Null) {
      return Kind.forNull as Kind<T>;
    }
    if (0.0 is T) {
      if (false is T) {
        if (null is T) {
          // T = `Object?`
          const Kind anyKind = NullableKind(PolymorphicKind<Object>());
          if (anyKind is Kind<T>) {
            return anyKind;
          }
        }

        // T = `Object`
        const Kind objectKind = PolymorphicKind<Object>();
        if (objectKind is Kind<T>) {
          return objectKind;
        }
      } else if (null is T) {
        // T = `double?`
        const Kind doubleKind = NullableKind(Kind.forDouble);
        if (doubleKind is Kind<T>) {
          return doubleKind;
        }

        // T = `int?`
        const Kind intKind = NullableKind(Kind.forInt);
        if (intKind is Kind<T>) {
          return intKind;
        }
      } else {
        // T = `double`
        const Kind doubleKind = Kind.forDouble;
        if (doubleKind is Kind<T>) {
          return doubleKind;
        }

        // T = `int`
        const Kind intKind = Kind.forInt;
        if (intKind is Kind<T>) {
          return intKind;
        }
      }
    }
    if (null is T) {
      for (var kind in _nullableKinds) {
        if (kind.dartType == T) {
          return kind as Kind<T>;
        }
      }
      for (var item in _kinds) {
        final kind = item.toList().toNullable();
        if (kind.dartType == T) {
          return kind as Kind<T>;
        }
      }
      for (var item in _kinds) {
        final kind = item.toSet().toNullable();
        if (kind.dartType == T) {
          return kind as Kind<T>;
        }
      }
    } else {
      for (var item in _kinds) {
        final kind = item;
        if (kind.dartType == T) {
          return kind as Kind<T>;
        }
      }
      for (var item in _kinds) {
        final kind = item.toList();
        if (kind.dartType == T) {
          return kind as Kind<T>;
        }
      }
      for (var item in _kinds) {
        final kind = item.toSet();
        if (kind.dartType == T) {
          return kind as Kind<T>;
        }
      }
    }
    return null;
  }

  /// Used by [checkValidDynamic].
  static Error newInvalidValueError({
    required Kind kind,
    required Object? instance,
  }) {
    if (!kind.isInstance(instance)) {
      return ArgumentError(
        'Instance of ${instance.runtimeType} does not implement ${kind.dartType}:\n'
        '  ${kind.debugString(instance).replaceAll('\n', '\n  ')}\n',
      );
    }
    return ArgumentError(
      'Value is not valid:\n'
      '  ${kind.debugString(instance).replaceAll('\n', '\n  ')}\n'
      '\n'
      'Kind is:\n'
      '  ${kind.toString().replaceAll('\n', '\n  ')}',
    );
  }

  /// Registers all [kinds].
  ///
  /// ## Example
  /// ```
  /// import 'package:kind/kind.dart';
  ///
  /// void main() {
  ///   Kind.registerAll([
  ///     kind0,
  ///     kind1,
  ///     // ...
  ///   ]);
  ///
  ///   // ...
  /// }
  /// ```
  static void registerAll(Iterable<Kind> kinds) {
    for (var kind in kinds) {
      kind.register();
    }
  }

  static Kind<T>? _maybeFindByInstance<T>(T instance) {
    // For JS compatibility,
    // prefer double over int whenever possible.
    if (instance is double) {
      final Kind kind = Kind.forDouble;
      if (kind is Kind<T>) {
        return kind;
      }
    }

    if (instance is HasKind) {
      final Kind runtimeKind = instance.runtimeKind;
      if (runtimeKind is Kind<T>) {
        return runtimeKind;
      }
    }
    Kind<T>? best;
    for (var kind in defaultPrimitiveKinds) {
      if (kind.isInstance(instance) && kind is Kind<T>) {
        best = kind;
        break;
      }
    }
    if (best == null) {
      if (instance is List) {
        //
        // List of some type
        //
        if (instance is TypedData) {
          if (instance is Uint8List) {
            const Kind kind = Uint8ListKind();
            if (kind is Kind<T>) {
              return kind;
            }
          } else if (instance is Int8List) {
            const Kind kind = ListKind(elementKind: IntKind.int8());
            if (kind is Kind<T>) {
              return kind;
            }
          } else if (instance is Int16List) {
            const Kind kind = ListKind(elementKind: IntKind.int16());
            if (kind is Kind<T>) {
              return kind;
            }
          } else if (instance is Int32List) {
            const Kind kind = ListKind(elementKind: IntKind.int32());
            if (kind is Kind<T>) {
              return kind;
            }
          } else if (instance is Uint16List) {
            const Kind kind = ListKind(elementKind: IntKind.uint16());
            if (kind is Kind<T>) {
              return kind;
            }
          } else if (instance is Uint32List) {
            const Kind kind = ListKind(elementKind: IntKind.uint32());
            if (kind is Kind<T>) {
              return kind;
            }
          } else if (instance is Float32List) {
            const Kind kind = ListKind(elementKind: FloatKind.float32());
            if (kind is Kind<T>) {
              return kind;
            }
          } else if (instance is Float64List) {
            const Kind kind = ListKind(elementKind: FloatKind.float64());
            if (kind is Kind<T>) {
              return kind;
            }
          }

          if (!isRunningInJs) {
            if (instance is Int64List) {
              const Kind kind = ListKind(elementKind: IntKind.int64());
              if (kind is Kind<T>) {
                return kind;
              }
            } else if (instance is Uint64List) {
              const Kind kind = ListKind(elementKind: IntKind.uint64());
              if (kind is Kind<T>) {
                return kind;
              }
            }
          }
        }

        for (var kind in _kinds) {
          if (kind.isInstanceOfList(instance)) {
            final dynamic listKind = kind.toList();
            if (listKind is Kind<T> &&
                (best == null || best.isSubKind(listKind))) {
              best = listKind;
            }
          }
        }
      } else if (instance is Set) {
        //
        // Set of some type
        //
        for (var kind in _kinds) {
          if (kind.isInstanceOfSet(instance)) {
            final dynamic setKind = kind.toSet();
            if (setKind is Kind<T> &&
                (best == null || best.isSubKind(setKind))) {
              best = setKind;
            }
          }
        }
      } else {
        //
        // Other object
        //
        for (var kind in _kinds) {
          if (kind.isInstance(instance) &&
              kind is Kind<T> &&
              (best == null || best.isSubKind(kind))) {
            best = kind;
          }
        }

        // We don't have the following types in defaultPrimitiveKinds.
        // By using `instance is X`, tree shaking can remove unused types
        // (that are never allocated in the program).
        if (instance is BigInt) {
          return Kind.forBigInt as Kind<T>;
        }
      }
    }
    return best;
  }
}

/// A singleton exposed via static constant [Kind.forNull].
// ignore: prefer_void_to_null
final class _NullKind extends Kind<Null> with PrimitiveKindMixin<Null> {
  @literal
  const _NullKind() : super.constructor(name: 'Null');

  @override
  // ignore: prefer_void_to_null
  Iterable<Null> get examplesWithoutValidation {
    // ignore: prefer_void_to_null
    return const <Null>[null];
  }

  @override
  int get hashCode => (_NullKind).hashCode ^ super.hashCode;

  @override
  bool get isNullable => true;

  @override
  bool operator ==(other) => other is _NullKind && super == other;

  @override
  int compare(void left, void right) {
    return 0;
  }

  @override
  Null decodeJsonTree(Object? json) {
    if (json == null) {
      return null;
    }
    throw JsonDecodingError.expectedNull(json);
  }

  @override
  Null decodeString(String string) {
    switch (string) {
      case 'null':
        return null;
      default:
        throw ArgumentError.value(string);
    }
  }

  @override
  Null encodeJsonTree(void instance) {
    return null;
  }

  @override
  String encodeString(void instance) {
    return 'null';
  }

  @override
  bool isDefaultValue(Object? instance) {
    return instance == null;
  }

  @override
  Null newInstance() {
    return null;
  }

  @override
  // ignore: prefer_void_to_null
  Null permute(Null instance) {
    return null;
  }

  @override
  _NullKind toNullable() {
    return this;
  }

  @override
  String toString() => 'Kind.forNull';
}
