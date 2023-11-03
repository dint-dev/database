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

/// [Kind] for [BigInt].
final class BigIntKind extends Kind<BigInt>
    with PrimitiveKindMixin<BigInt>, ComparableKindMixin<BigInt> {
  const BigIntKind({
    super.name = 'BigInt',
    super.traits,
  }) : super.constructor();

  @override
  Iterable<BigInt> get examplesWithoutValidation => [BigInt.zero, BigInt.one];

  @override
  int get hashCode => (BigIntKind).hashCode ^ super.hashCode;

  @override
  bool operator ==(other) => other is BigIntKind && super == other;

  @override
  BigInt decodeJsonTree(Object? json) {
    if (json is num) {
      return BigInt.from(json);
    }
    if (json is String) {
      return decodeString(json);
    }
    throw ArgumentError.value(json);
  }

  @override
  BigInt decodeString(String string) {
    final bigIntValue = BigInt.tryParse(string);
    if (bigIntValue != null) {
      return bigIntValue;
    }
    throw ArgumentError.value(string);
  }

  @override
  Object? encodeJsonTree(BigInt instance) {
    return encodeString(instance);
  }

  @override
  String encodeString(BigInt instance) {
    return instance.toString();
  }

  @override
  BigInt newInstance() {
    return BigInt.zero;
  }

  @override
  BigInt permute(BigInt instance) {
    return instance + BigInt.one;
  }
}
