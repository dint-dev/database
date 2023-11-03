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

/// Abstract [Kind] for composite types.
abstract class CompositeKind<T, B> extends Kind<T> {
  static final _expando = Expando<Kind>();

  const CompositeKind({
    required super.name,
    super.jsonName,
    super.traits,
  }) : super.constructor();

  /// Constructs an instance of [CompositeKind].
  const factory CompositeKind.inline({
    String? name,
    String? jsonName,
    required Kind<B> kind,
    required B Function(T) encode,
    required T Function(B) decode,
    List<Trait>? traits,
  }) = _InlineCompositeKind<T, B>;

  /// Kind built by [buildKind].
  Kind<B> get builtKind => (_expando[this] ??= buildKind()) as Kind<B>;

  @override
  Iterable<T> get examplesWithoutValidation {
    return builtKind.examplesWithoutValidation.map(instanceFromBuiltKind);
  }

  @override
  bool get isPrimitive => builtKind.isPrimitive;

  @protected
  Kind<B> buildKind();

  @override
  T clone(T instance) {
    return instanceFromBuiltKind(
      builtKind.clone(
        instanceToBuiltKind(instance),
      ),
    );
  }

  @override
  String debugString(T instance) {
    return builtKind.debugString(instanceToBuiltKind(instance));
  }

  @override
  T decodeJsonTree(Object? json) {
    final built = builtKind.decodeJsonTree(json);
    return instanceFromBuiltKind(built);
  }

  @override
  T decodeString(String string) {
    final built = builtKind.decodeString(string);
    return instanceFromBuiltKind(built);
  }

  @override
  Object? encodeJsonTree(T instance) {
    final built = instanceToBuiltKind(instance);
    return builtKind.encodeJsonTree(built);
  }

  @override
  String encodeString(T instance) {
    final built = instanceToBuiltKind(instance);
    return builtKind.encodeString(built);
  }

  /// Maps an instance of [B] ([builtKind]) to an instance of [T].
  T instanceFromBuiltKind(B built);

  /// Maps an instance of [T] to an instance of [B] ([builtKind]).
  B instanceToBuiltKind(T instance);

  @override
  bool isDefaultValue(Object? instance) {
    return instance is T &&
        builtKind.isDefaultValue(instanceToBuiltKind(instance));
  }

  @override
  void checkValid(T instance) {
    builtKind.checkValid(instanceToBuiltKind(instance));
    super.checkValid(instance);
  }

  @override
  bool isValid(T instance) {
    return builtKind.isValid(instanceToBuiltKind(instance)) &&
        super.isValid(instance);
  }

  @override
  void memorySizeWith(MemoryCounter counter, T instance) {
    final built = instanceToBuiltKind(instance);
    return builtKind.memorySizeWith(counter, built);
  }

  @override
  T newInstance() {
    return instanceFromBuiltKind(builtKind.newInstance());
  }

  @override
  T permute(T instance) {
    final built = builtKind.permute(instanceToBuiltKind(instance));
    return instanceFromBuiltKind(built);
  }
}

class _InlineCompositeKind<T, B> extends CompositeKind<T, B> {
  final Kind<B> _kind;
  final B Function(T) _encode;
  final T Function(B) _decode;

  const _InlineCompositeKind({
    super.name,
    super.jsonName,
    required Kind<B> kind,
    required B Function(T) encode,
    required T Function(B) decode,
    super.traits,
  })  : _kind = kind,
        _encode = encode,
        _decode = decode,
        super();

  @override
  Kind<B> buildKind() {
    return _kind;
  }

  @override
  T instanceFromBuiltKind(B built) {
    return _decode(built);
  }

  @override
  B instanceToBuiltKind(T instance) {
    return _encode(instance);
  }
}
