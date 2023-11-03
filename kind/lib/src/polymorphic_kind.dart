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
import 'package:os/os.dart';

import '../kind.dart';

/// [Kind] for situations when an instance is one of several possible kinds.
///
/// If you know all possible kinds, use [PolymorphicKind.sealed] constructor.
///
/// Otherwise the kind can be:
///   * [defaultKinds]
///   * OR any kind in [Kind.all]
///
/// The [defaultKind] is the first kind in [defaultKinds] or the first
/// matching kind in [Kind.all].
///
///
/// ## JSON encoding
///
/// The JSON encoding of a polymorphic kind is a JSON object with a field named
/// [jsonDiscriminator] with the value of [Kind.name] of the kind.
/// The default value of [jsonDiscriminator] is "@type"
/// ([PolymorphicKind.defaultJsonDiscriminator]).
///
/// For example, serialization of `Person` class would look like:
/// ```json
/// {
///   "@type": "Person",
///   "name": "John Doe",
/// }
/// ```
final class PolymorphicKind<T> extends Kind<T> {
  /// Default JSON discriminator ("@type").
  ///
  /// The discriminator "@type" was chosen because it is used by [Protocol
  /// Buffers v3 JSON serialization format](https://developers.google.com/protocol-buffers/docs/proto3#json).
  static const defaultJsonDiscriminator = '@type';

  /// Possible kinds.
  ///
  /// If [isSealed] is `true`, this list must contain all possible kinds.
  /// Otherwise it can be a subset of all possible kinds.
  final List<Kind<T>> defaultKinds;

  /// Discriminator field name
  ///
  /// The default value is [PolymorphicKind.defaultJsonDiscriminator].
  final String jsonDiscriminator;

  /// Whether [defaultKinds] contains all possible kinds.
  final bool isSealed;

  /// Constructs a polymorphic kind.
  const PolymorphicKind({
    super.name,
    this.jsonDiscriminator = defaultJsonDiscriminator,
    this.defaultKinds = const [],
  })  : isSealed = false,
        super.constructor();

  /// Constructor for situations when all possible kinds are known.
  const PolymorphicKind.sealed({
    super.name,
    this.jsonDiscriminator = defaultJsonDiscriminator,
    required this.defaultKinds,
  })  : isSealed = true,
        super.constructor();

  /// Returns [defaultKinds] and matching kinds in [Kind.all] (unless [isSealed]
  /// is true).
  Iterable<Kind<T>> get allKinds sync* {
    yield* (defaultKinds);
    if (isSealed) {
      return;
    }
    for (var kind in Kind.all.whereType<Kind<T>>()) {
      if (defaultKinds.contains(kind)) {
        continue;
      }
      yield (kind);
    }
  }

  /// Returns default kind.
  ///
  /// If [defaultKinds] is not empty, returns the first kind.
  Kind<T> get defaultKind {
    final possibleKinds = this.defaultKinds;
    if (possibleKinds.isNotEmpty) {
      return possibleKinds.first;
    }
    if (!isSealed) {
      final kind = Kind.all.whereType<Kind<T>>().firstOrNull;
      if (kind != null) {
        return kind;
      }
    }
    throw StateError(
      'You have not registered any Kind<$T> with Kind.registerAll(..).',
    );
  }

  @override
  Iterable<T> get examplesWithoutValidation sync* {
    final iterators =
        defaultKinds.map((e) => e.examplesWithoutValidation.iterator);
    var iterate = true;
    while (iterate) {
      iterate = false;
      for (var iterator in iterators) {
        if (iterator.moveNext()) {
          yield (iterator.current);
          iterate = true;
        }
      }
    }
  }

  @override
  int get hashCode =>
      Object.hash(
        PolymorphicKind,
        Object.hashAll(defaultKinds),
        isSealed,
      ) ^
      super.hashCode;

  @override
  bool get isPrimitive =>
      isSealed && defaultKinds.every((element) => element.isPrimitive);

  @override
  bool operator ==(Object other) =>
      other is PolymorphicKind<T> &&
      const ListEquality().equals(defaultKinds, other.defaultKinds) &&
      isSealed == other.isSealed &&
      super == other;

  @override
  void checkValid(T instance) {
    for (var kind in allKinds) {
      if (kind.isValid(instance)) {
        kind.checkValid(instance);
        super.checkValid(instance);
        return;
      }
    }
    throw ArgumentError.value(
      instance,
      'instance',
      'No kind for an instance of ${instance.runtimeType}',
    );
  }

  @override
  T clone(T instance) {
    return findKindByInstance(instance).clone(instance);
  }

  @override
  int compare(T left, T right) {
    final leftKind = findKindByInstance(left);
    final rightKind = findKindByInstance(right);
    if (leftKind == rightKind) {
      return leftKind.compare(left, right);
    }
    return kindIndexOfKind(leftKind).compareTo(kindIndexOfKind(rightKind));
  }

  @override
  T decodeJsonTree(Object? json) {
    if (json == null) {
      if (json is T) {
        return json;
      }
    }
    if (json is Map) {
      final type = json[jsonDiscriminator];
      if (type is! String) {
        if (json.containsKey(jsonDiscriminator)) {
          throw ArgumentError(
            'JSON object field "$jsonDiscriminator" has invalid value of type ${type.runtimeType}.',
          );
        } else {
          throw ArgumentError(
            'JSON object is missing discriminator "$jsonDiscriminator".',
          );
        }
      }
      final kind = findKindByName(type);
      if (kind.isPrimitive && json.length == 2) {
        final value = json['value'];
        return kind.decodeJsonTree(value);
      }
      return kind.decodeJsonTree(json);
    } else {
      throw ArgumentError('Expected JSON object, got ${json.runtimeType}');
    }
  }

  @override
  Object? encodeJsonTree(T instance) {
    if (instance == null) {
      return null;
    }
    final kind = findKindByInstance(instance);
    final name = kind.name;
    final jsonTree = kind.encodeJsonTree(instance);
    if (jsonTree is Map) {
      assert(jsonTree[jsonDiscriminator] == null);
      jsonTree[jsonDiscriminator] = name;
      return jsonTree;
    } else {
      return {
        jsonDiscriminator: name,
        'value': jsonTree,
      };
    }
  }

  /// Finds kind by [instance].
  Kind<T> findKindByInstance(T instance) {
    Kind<T>? best;
    for (var possibleKind in defaultKinds) {
      if (possibleKind.isInstance(instance)) {
        if (best == null || best.isSubKind(possibleKind)) {
          best = possibleKind;
        }
      }
    }
    if (best == null && !isSealed) {
      for (var possibleKind in Kind.all) {
        if (possibleKind is Kind<T> && possibleKind.isInstance(instance)) {
          if (best == null || best.isSubKind(possibleKind)) {
            best = possibleKind;
          }
        }
      }
    }
    if (best == null) {
      throw ArgumentError('No kind for an instance of ${instance.runtimeType}');
    }
    return best;
  }

  /// Finds kind by [name].
  Kind<T> findKindByName(String name) {
    for (var possibleKind in defaultKinds) {
      if (possibleKind.name == name) {
        return possibleKind;
      }
    }
    if (!isSealed) {
      for (var possibleKind in Kind.all) {
        if (possibleKind.name == name && possibleKind is Kind<T>) {
          return possibleKind;
        }
      }
    }

    if (!isRunningInDebugMode) {
      throw ArgumentError.value(name, 'name', 'Unknown kind name.');
    }

    // Build list of possible names
    final foundNames = <String>{};
    for (var possibleKind in defaultKinds) {
      foundNames.add(possibleKind.name);
    }
    for (var possibleKind in Kind.all) {
      if (possibleKind is Kind<T>) {
        foundNames.add(possibleKind.name);
      }
    }
    if (foundNames.isEmpty) {
      throw ArgumentError(
        'JSON object field "$jsonDiscriminator" value "$name" is unsupported.\n\n'
        'You have not registered any matching kinds with `Kind.registerAll(..)`.',
      );
    }
    throw ArgumentError(
      'JSON object field "$jsonDiscriminator" value "$name" is unsupported.\n\n'
      'Supported values are: ${foundNames.map((e) => '"$e"').join(', ')}',
    );
  }

  @override
  bool isDefaultValue(Object? instance) {
    return defaultKind.isInstance(instance) &&
        defaultKind.isDefaultValue(instance);
  }

  @override
  bool isValid(T instance) {
    for (var kind in allKinds) {
      if (kind.isValid(instance)) {
        return super.isValid(instance);
      }
    }
    return false;
  }

  int kindIndexOfKind(Kind<T> kind) {
    var i = 0;
    for (var possibleKind in defaultKinds) {
      if (identical(possibleKind, kind)) {
        return i;
      }
      i++;
    }
    if (!isSealed) {
      for (var possibleKind in Kind.all) {
        if (identical(possibleKind, kind)) {
          return i;
        }
        i++;
      }
    }
    return -1;
  }

  @override
  int memorySize(T instance) {
    return findKindByInstance(instance).memorySize(instance);
  }

  @override
  void memorySizeWith(MemoryCounter counter, T instance) {
    return findKindByInstance(instance).memorySizeWith(counter, instance);
  }

  @override
  T newInstance() {
    return defaultKind.newInstance();
  }

  @override
  T permute(T instance) {
    return findKindByInstance(instance).permute(instance);
  }

  @override
  void register() {
    Kind.registerAll(defaultKinds);
  }

  @override
  PolymorphicKind<T> toPolymorphic() {
    return this;
  }
}
