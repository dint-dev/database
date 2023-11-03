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

import '../kind.dart';

/// A simple API for customizing behavior of another kind.
final class SimpleKind<T> extends DelegatingKind<T> {
  static final _traitsExpando = Expando<List<Trait>>('traits');

  /// New name.
  final String? _name;

  /// New JSON name.
  final String? _jsonName;

  /// New JSON decoder.
  final T Function(Object? json)? _fromJson;

  /// New JSON encoder.
  final Object? Function(T instance)? _toJson;

  /// New traits.
  final List<Trait>? _traits;

  const SimpleKind({
    String? name,
    String? jsonName,
    required Kind<T> kind,
    T Function(Object? json)? fromJson,
    Object? Function(T instance)? toJson,
    List<Trait>? traits,
  })  : _name = name,
        _jsonName = jsonName,
        _fromJson = fromJson,
        _toJson = toJson,
        _traits = traits,
        super(kind);

  @override
  int get hashCode => Object.hash(
        SimpleKind,
        name,
        super.hashCode,
      );

  @override
  String? get jsonName => _jsonName ?? wrappedKind.jsonName;

  @override
  String get name => _name ?? wrappedKind.name;

  @override
  List<Trait> get traits {
    final thisTraits = _traits;
    final wrappedTraits = wrappedKind.traits;
    if (thisTraits == null || thisTraits.isEmpty) {
      return wrappedTraits;
    }
    if (wrappedTraits.isEmpty) {
      return thisTraits;
    }
    return _traitsExpando[this] ??= [...thisTraits, ...wrappedTraits];
  }

  @override
  bool operator ==(other) =>
      other is SimpleKind<T> &&
      _name == other._name &&
      _jsonName == other._jsonName &&
      _fromJson == other._fromJson &&
      _toJson == other._toJson &&
      super == other;

  @override
  T decodeJsonTree(Object? json) {
    final fromJson = _fromJson;
    if (fromJson != null) {
      return fromJson(json);
    }
    return super.decodeJsonTree(json);
  }

  @override
  Object? encodeJsonTree(T instance) {
    final toJson = _toJson;
    if (toJson != null) {
      return toJson(instance);
    }
    return super.encodeJsonTree(instance);
  }
}
