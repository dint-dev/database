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

/// Kind for immutable objects.
///
/// There are four possible constructors:
///   * [ImmutableKind]
///     * Use if your class has a `const` constructor or it is at least deeply
///       immutable.
///   * [ImmutableKind.walkable]
///     * Use if your class implements [Walkable].
///   * [ImmutableKind.withConstructor]
///     * Use if the constructor of your class is not `const`.
///   * [ImmutableKind.jsonSerializable]
///     * Use if your class has a `YourClass.fromJson(Map<String, dynamic)`
///       factory and you are too lazy to write a mapper function.
///
/// ## Optimization tricks
///   * Use [Mapper.canReturnSame] in your `walk` function.
///   * Specify non-null [name]. Otherwise `T.toString()` has to be called
///     every time [name] or [jsonName] is read.
///
/// ## Example
/// ```
/// import 'package:kind/kind.dart';
///
/// void main() {
///   //
///   // Encode/decode JSON trees:
///   //
///   final company = Company.kind.decodeJsonTree({
///     'name': 'Flutter App Development Experts',
///     'shareholders': [
///       {
///         '@type': 'Person',
///         'firstName': 'Alice',
///         'lastName': 'Smith',
///       },
///       {
///         '@type': 'Person',
///         'firstName': 'Bob',
///       },
///     ],
///   });
///   print("${company.name} has ${company.shareholders.length} shareholders.");
///
///   //
///   // We have `==` and `hashCode` because we extended `HasKind`:
///   //
///   print(company.shareholders[1] == Person(firstName: 'Bob')); // --> true
///
///   //
///   // We have `toString()` because we extended `HasKind`:
///   //
///   print(company.toString());
///   // Prints:
///   //   Company(
///   //     "Flutter App Development Experts",
///   //     shareholders: [
///   //       Person(
///   //         firstName: 'John',
///   //         lastName: 'Doe',
///   //       ),
///   //       Person(firstName: 'Bob'),
///   //     ],
///   //   )
/// }
///
/// //
/// // Example class #1:
/// //   "A static `_walk` function"
/// //
/// class Company extends Shareholder {
///   static const kind = ImmutableKind<Company>(
///     name: 'Company',
///     blank: Company(''),
///     walk: _walk,
///   );
///
///   @override
///   final String name;
///
///   final List<Shareholder> shareholders;
///
///   const Company(this.name, {this.shareholders = const []});
///
///   @override
///   Kind<Company> get runtimeKind => kind;
///
///   static Company _walk(Mapper f, Company t) {
///     final name = f.positional(t.name, 'name');
///     final shareholders = f(
///       t.shareholders,
///       'shareholders',
///       kind: const ListKind(
///         elementKind: Shareholder.kind,
///       ),
///     );
///
///     // The following is a performance optimization we recommend:
///     if (f.canReturnSame) {
///       return t;
///     }
///
///     // Finally, construct a new instance:
///     return Company(
///       name,
///       shareholders: shareholders,
///     );
///   }
/// }
///
/// //
/// // Example #2:
/// //   "A class that extends `Walkable`"
/// //
/// class Person extends Shareholder with Walkable {
///   static const kind = ImmutableKind<Person>.walkable(
///     name: 'Person',
///     blank: Person(firstName: ''),
///   );
///
///   /// First name
///   final String firstName;
///
///   /// First name
///   final String lastName;
///
///   const Person({
///     required this.firstName,
///     this.lastName = '',
///   });
///
///   @override
///   String get name => '$firstName $lastName';
///
///   @override
///   Kind<Person> get runtimeKind => kind;
///
///   @override
///   Person walk(Mapper f) {
///     final firstName = f.required(
///       this.firstName,
///       'firstName',
///       kind: const StringKind.singleLineShort(),
///     );
///     final lastName = f(
///       this.lastName,
///       'lastName',
///       kind: const StringKind.singleLineShort(),
///     );
///     if (f.canReturnSame) {
///       return this;
///     }
///     return Person(
///       firstName: firstName,
///       lastName: lastName,
///     );
///   }
/// }
///
/// //
/// // Example #3:
/// //   "A polymorphic class"
/// //
/// abstract class Shareholder extends HasKind {
///   static const kind = PolymorphicKind<Shareholder>.sealed(
///     defaultKinds: [
///       Person.kind,
///       Company.kind,
///     ],
///   );
///
///   const Shareholder();
///
///   String get name;
/// }
/// ```
sealed class ImmutableKind<T> extends Kind<T> {
  /// Custom implementation of [decodeJsonTree].
  final Function? _fromJson;

  /// Custom implementation of [encodeJsonTree].
  final Object? Function(T object)? _toJson;

  /// Whether subclasses are possible;
  final bool isSealed;

  /// Constant instances.
  ///
  /// The main purpose is debug string generators.
  final Map<String, T> constantsByName;

  /// Constructs a kind for a class that has a constant constructor.
  ///
  /// Parameter [blank] is the default value. It should be a compile-time
  /// constant or at least an unmodifiable object.
  ///
  /// Parameter [walk] is a function that maps an instance to a new instance
  /// using a [Mapper].
  @literal
  const factory ImmutableKind({
    String? name,
    String? jsonName,
    required T blank,
    required WalkFunction<T> walk,
    Function? fromJson,
    Object? Function(T object)? toJson,
    Map<String, T>? constantsByName,
  }) = _ImmutableKind<T>;

  /// Creates a kind for any JSON-serializable class.
  ///
  /// This is convenient if you already have `fromJson` factory and don't want
  /// to invest time in writing a mapper.
  ///
  /// ## Example
  /// ```
  /// import 'package:kind/kind.dart';
  ///
  /// final exampleKind = ImmutableKind<Example>.jsonSerializable(
  ///   fromJson: Example.fromJson,
  /// );
  ///
  /// class Example {
  ///   factory Example.fromJson(Map<String,dynamic> json) {
  ///     // ...
  ///   }
  ///
  ///   Map<String,dynamic> toJson() {
  ///     // ...
  ///   }
  /// }
  /// ```
  factory ImmutableKind.jsonSerializable({
    String? name,
    String? jsonName,
    Map<String, Kind>? kinds,
    T Function(Mapper f, T t)? walk,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic> Function(T object)? toJson,
    Map<String, T>? constantsByName,
  }) {
    Map<String, Object?> defaultToJson(T object) {
      return (object as dynamic).toJson();
    }

    T defaultWalk(Mapper f, T t) {
      final json = defaultToJson(t);
      json.forEach((key, value) {
        final kind = kinds?[key];
        if (kind == null) {
          f(value, key);
        } else {
          final decodedValue = kind.decodeJsonTree(value);
          f(decodedValue, key, kind: kind);
        }
      });
      return t;
    }

    toJson ??= defaultToJson;
    walk ??= defaultWalk;

    return ImmutableKind<T>.withConstructor(
      name: name,
      jsonName: jsonName,
      constructor: () => fromJson({}),
      walk: walk,
      fromJson: fromJson,
      toJson: toJson,
    );
  }

  /// Constructs a kind for a class that implements [Walkable].
  ///
  /// Parameter [blank] is the default value. It should be a compile-time
  /// constant or at least an unmodifiable object.
  ///
  /// Parameter [walk] is a function that maps an instance to a new instance
  /// using a [Mapper].
  @literal
  const factory ImmutableKind.walkable({
    String? name,
    String? jsonName,
    required T blank,
    Function? fromJson,
    Object? Function(T object)? toJson,
    Map<String, T> constantsByName,
  }) = _WalkableImmutableKind<T>;

  /// Constructs a kind for a class that has a non-constant constructor.
  ///
  /// Parameter [constructor] is a function that constructs a default instance.
  ///
  /// Parameter [walk] is a function that maps an instance to a new instance
  /// using a [Mapper].
  @literal
  const factory ImmutableKind.withConstructor({
    String? name,
    String? jsonName,
    required T Function() constructor,
    required WalkFunction<T> walk,
    Function? fromJson,
    Object? Function(T object)? toJson,
    Map<String, T> constantsByName,
  }) = _ConstructorImmutableKind<T>;

  /// Constructor for subclasses.
  const ImmutableKind._({
    super.name,
    super.jsonName,
    Function? fromJson,
    Object? Function(T object)? toJson,
    this.isSealed = true,
    Map<String, T>? constantsByName,
  })  : _fromJson = fromJson,
        _toJson = toJson,
        constantsByName = constantsByName ?? const {},
        super.constructor();

  @override
  Iterable<T> get examplesWithoutValidation sync* {
    final mapper = _InterestingExamplesMapper();
    do {
      final instance = mapDefault(mapper);
      yield (instance);
    } while (!mapper._isDone);
  }

  @override
  // ignore: must_call_super
  int get hashCode => identityHashCode(this);

  @override
  // ignore: must_call_super
  bool operator ==(other) => identical(this, other);

  @override
  void checkValid(T instance) {
    map(const _CheckValidMapper(), instance);
    super.checkValid(instance);
  }

  @override
  T clone(T instance) {
    return map(Mapper.deepCloning, instance);
  }

  @override
  int compare(T left, T right) {
    return InstanceMirror.of(left, kind: this)
        .compareTo(InstanceMirror.of(right, kind: this));
  }

  @override
  String debugString(T instance) {
    final mapper = _DebugStringMapper();
    map(mapper, instance);
    final parts = mapper._parts;
    final constructorIdentifier = mapper._constructorIdentifier;

    final sb = StringBuffer();
    final classIdentifier = instance.runtimeType.toString();
    sb.write(classIdentifier);

    // Custom constructor?
    if (constructorIdentifier != null) {
      sb.write('.');
      sb.write(constructorIdentifier);
    }

    sb.write('(');
    sb.write(ListKind.debugStringForIterableElements(
      iterable: parts,
      debugString: (e) => e,
      maxLineLength:
          30 - classIdentifier.length - ((constructorIdentifier ?? '').length),
    ));
    sb.write(')');
    return sb.toString();
  }

  @override
  T decodeJsonTree(Object? json) {
    final fromJson = _fromJson;
    if (fromJson != null) {
      if (fromJson is T Function(Object? json)) {
        return fromJson(json);
      }
      if (fromJson is T Function(Map<String, dynamic> json)) {
        if (json is! Map<String, dynamic>) {
          throw ArgumentError.value(json, 'json');
        }
        return fromJson(json);
      }
      if (fromJson is T Function(String json)) {
        if (json is! String) {
          throw ArgumentError.value(json, 'json');
        }
        return fromJson(json);
      }
      throw StateError('Invalid JSON function: $fromJson');
    }
    if (json is! Map) {
      throw JsonDecodingError.expectedObject(json);
    }
    final mapper = JsonObjectDecodingMapper(json);
    return map(mapper, newInstance());
  }

  @override
  Object? encodeJsonTree(T instance) {
    final toJson = _toJson;
    if (toJson != null) {
      return toJson(instance);
    }
    final fromJson = _fromJson;
    if (fromJson != null) {
      return (instance as dynamic).toJson();
    }
    final mapper = JsonObjectEncodingMapper();
    map(mapper, instance);
    return mapper.jsonObject;
  }

  @override
  bool isValid(T instance) {
    if (!super.isValid(instance)) {
      return false;
    }
    final mapper = _IsValidMapper();
    map(mapper, instance);
    return mapper._isValid;
  }

  /// Maps [object] to a new instance of [T].
  T map(Mapper mapper, T object);

  /// Maps the default value with the [mapper] to a new instance of [T].
  ///
  /// The main use case is deserializing data. In that case, the default value
  /// is simply ignored.
  T mapDefault(Mapper mapper) {
    return map(mapper, newInstance());
  }

  @override
  void memorySizeWith(MemoryCounter counter, T instance) {
    map(counter.mapper, instance);
  }

  @override
  T permute(T instance) {
    return mapDefault(const _NextInstanceMapper());
  }
}

class _CheckValidMapper extends Mapper {
  @literal
  const _CheckValidMapper();

  @override
  bool get canReturnSame => true;

  @override
  V handle<V>(
      {required ParameterType parameterType,
      required V value,
      required String name,
      Kind? kind,
      V? defaultConstant,
      String? jsonName,
      List<Trait>? tags}) {
    kind ??= Kind.find<V>(instance: value);
    kind.checkValid(value);
    return value;
  }
}

final class _ConstructorImmutableKind<T> extends ImmutableKind<T> {
  final T Function() _constructor;
  final WalkFunction<T> _walk;

  const _ConstructorImmutableKind({
    super.name,
    super.jsonName,
    required T Function() constructor,
    required WalkFunction<T> walk,
    super.fromJson,
    super.toJson,
    super.constantsByName,
  })  : _constructor = constructor,
        _walk = walk,
        super._();

  @override
  T map(Mapper mapper, T object) {
    return _walk(mapper, object);
  }

  @override
  T newInstance() {
    final result = _constructor();
    assert(result is! HasKind || identical(result.runtimeKind, this));
    return result;
  }
}

class _DebugStringMapper extends Mapper {
  static final _dartIdentifierRegExp = RegExp(
    r'^[a-zA-Z_$][a-zA-Z0-9_$]{0,64}$',
  );
  String? _constructorIdentifier;
  final Map<String, Object?> _defaultValues = {};

  final List<String> _parts = [];

  @override
  bool get canReturnSame => true;

  @override
  bool get isGeneratingSource => true;

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
    name = _validatedIdentifier(name);

    if (parameterType.isOptional) {
      final defaultValues = _defaultValues;
      if (defaultValues.containsKey(name)) {
        if (value == defaultValues[name]) {
          return value;
        }
      } else {
        // Default value?
        if (value == defaultConstant) {
          // Do not write default value.
          return value;
        }

        // If default value was (probably) not given,
        // use `kind` to check whether the value is default value.
        if (defaultConstant == null) {
          kind ??= Kind.find<V>(instance: value);
          if (kind.isDefaultValue(value)) {
            // Do not write default value.
            return value;
          }
        }
      }
    }
    kind ??= Kind.find<V>(instance: value);
    var valueDebugString = _valueDebugString(
      value,
      kind: kind,
      tags: tags,
    );
    if (parameterType.isNamed) {
      valueDebugString = '$name: $valueDebugString';
    }
    _parts.add(valueDebugString);
    return value;
  }

  @override
  void setConstructorIdentifier(String identifier) {
    _constructorIdentifier = identifier;
  }

  @override
  void setDefaultValue(String name, Object? value) {
    _defaultValues[name] = value;
  }

  String _validatedIdentifier(String name) {
    if (_dartIdentifierRegExp.hasMatch(name)) {
      return name;
    } else {
      assert(false, 'Invalid identifier: $name');
      return 'INVALID_IDENTIFIER';
    }
  }

  String _valueDebugString(
    Object? value, {
    required Kind? kind,
    required List<Trait>? tags,
  }) {
    if (kind == null) {
      return '...';
    }
    if (tags != null && tags.contains(Trait.confidential)) {
      return '(secret)';
    }
    return kind.debugString(value);
  }
}

final class _ImmutableKind<T> extends ImmutableKind<T> {
  final T _blank;
  final WalkFunction<T> _walk;

  const _ImmutableKind({
    super.name,
    super.jsonName,
    required T blank,
    required WalkFunction<T> walk,
    super.fromJson,
    super.toJson,
    super.constantsByName,
  })  : _blank = blank,
        _walk = walk,
        super._();

  @override
  T map(Mapper mapper, T object) {
    return _walk(mapper, object);
  }

  @override
  T mapDefault(Mapper mapper) {
    return map(mapper, _blank);
  }

  @override
  T newInstance() {
    return _blank;
  }

  @override
  List<T> newList(int length, {bool growable = true}) {
    return List<T>.filled(length, _blank, growable: growable);
  }
}

class _InterestingExamplesMapper extends Mapper {
  final Map<String, Iterator> _iterators = {};
  final Set<String> _done = {};

  bool get _isDone => _done.length >= _iterators.length;

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
    var iterator = _iterators[name];
    if (iterator == null) {
      iterator = kind.examplesWithoutValidation.iterator;
      _iterators[name] = iterator;
    }
    while (iterator.moveNext()) {
      final current = iterator.current;
      if (current is V) {
        return current;
      }
    }
    _done.add(name);
    final blank = kind.newInstance();
    if (blank is V) {
      return blank;
    }
    return value;
  }
}

class _IsValidMapper extends Mapper {
  bool _isValid = true;

  _IsValidMapper();

  @override
  bool get canReturnSame => true;

  @override
  V handle<V>(
      {required ParameterType parameterType,
      required V value,
      required String name,
      Kind? kind,
      V? defaultConstant,
      String? jsonName,
      List<Trait>? tags}) {
    kind ??= Kind.find<V>(instance: value);
    if (!kind.isValid(value)) {
      _isValid = false;
    }
    return value;
  }
}

class _NextInstanceMapper extends Mapper {
  @literal
  const _NextInstanceMapper();

  @override
  V handle<V>(
      {required ParameterType parameterType,
      required V value,
      required String name,
      Kind? kind,
      V? defaultConstant,
      String? jsonName,
      List<Trait>? tags}) {
    kind ??= Kind.find<V>(instance: value);
    return kind.permute(value);
  }
}

final class _WalkableImmutableKind<T> extends ImmutableKind<T> {
  final T _blank;

  const _WalkableImmutableKind({
    super.name,
    super.jsonName,
    required T blank,
    super.fromJson,
    super.toJson,
    super.constantsByName,
  })  : _blank = blank,
        assert(blank is Walkable),
        super._();

  @override
  T map(Mapper mapper, T object) {
    return (object as Walkable).walk(mapper) as T;
  }

  @override
  T mapDefault(Mapper mapper) {
    return map(mapper, _blank);
  }

  @override
  T newInstance() {
    return _blank;
  }

  @override
  List<T> newList(int length, {bool growable = true}) {
    return List<T>.filled(length, _blank, growable: growable);
  }
}
