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

/// [Kind] for [bool].
final class BoolKind extends Kind<bool> with PrimitiveKindMixin<bool> {
  /// [Kind] for [BoolKind].
  static const kindForKind = ImmutableKind(
    name: 'BoolKind',
    blank: BoolKind(),
    walk: _kindMapper,
  );

  @literal
  const BoolKind({
    super.traits,
  }) : super.constructor(name: 'bool');

  @override
  List<bool> get examplesWithoutValidation => const [false, true];

  @override
  int get hashCode => (BoolKind).hashCode ^ super.hashCode;

  @override
  bool operator ==(other) => other is BoolKind && super == other;

  @override
  int compare(bool left, bool right) {
    if (left == right) {
      return 0;
    }
    return left == false ? -1 : 1;
  }

  @override
  bool decodeJsonTree(Object? json) {
    if (json is bool) {
      return json;
    }
    throw JsonDecodingError.expectedBool(json);
  }

  @override
  bool decodeString(String string) {
    switch (string) {
      case 'false':
        return false;
      case 'true':
        return true;
      default:
        throw ArgumentError.value(string);
    }
  }

  @override
  Object? encodeJsonTree(bool instance) {
    return instance;
  }

  @override
  String encodeString(bool instance) {
    return instance.toString();
  }

  @override
  bool newInstance() {
    return false;
  }

  @override
  bool permute(bool instance) {
    return !instance;
  }

  @override
  String toString() {
    return 'Kind.forBool';
  }

  static BoolKind _kindMapper(Mapper f, BoolKind t) {
    return t;
  }
}
