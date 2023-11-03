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

/// [Kind] for [bool].
final class Tuple2Kind<T0, T1> extends Kind<(T0, T1)>
    with PrimitiveKindMixin<(T0, T1)> {
  /// [Kind] for [BoolKind].
  static const kindForKind = ImmutableKind(
    name: 'Tuple2Kind',
    blank: Tuple2Kind(BoolKind(), BoolKind()),
    walk: _kindMapper,
  );
  final Kind<T0> kind0;

  final Kind<T1> kind1;

  const Tuple2Kind(
    this.kind0,
    this.kind1, {
    super.name,
    super.jsonName,
  }) : super.constructor();

  @override
  Iterable<(T0, T1)> get examplesWithoutValidation sync* {
    final i0 = kind0.examplesWithoutValidation.iterator;
    final i1 = kind1.examplesWithoutValidation.iterator;
    while (true) {
      final hasNext0 = i0.moveNext();
      final hasNext1 = i1.moveNext();
      if (!hasNext0 && !hasNext1) {
        break;
      }
      yield (
        hasNext0 ? i0.current : kind0.newInstance(),
        hasNext1 ? i1.current : kind1.newInstance(),
      );
    }
  }

  @override
  int get hashCode => (BoolKind).hashCode ^ super.hashCode;

  @override
  bool operator ==(other) => other is Tuple2Kind && super == other;

  @override
  void checkValid((T0, T1) instance) {
    kind0.checkValid(instance.$1);
    kind1.checkValid(instance.$2);
    super.checkValid(instance);
  }

  @override
  int compare((T0, T1) left, (T0, T1) right) {
    final r = kind0.compare(left.$1, right.$1);
    if (r != 0) {
      return r;
    }
    return kind1.compare(left.$2, right.$2);
  }

  @override
  (T0, T1) decodeJsonTree(Object? json) {
    if (json is List) {
      if (json.length != 2) {
        throw JsonDecodingError(
          value: json,
          message: 'Expected ${json.length} items',
        );
      }
      final value0 = kind0.decodeJsonTree(json[0]);
      final value1 = kind1.decodeJsonTree(json[1]);
      return (value0, value1);
    }
    throw JsonDecodingError.expectedBool(json);
  }

  @override
  Object? encodeJsonTree((T0, T1) instance) {
    final (value0, value1) = instance;
    return <Object?>[
      kind0.encodeJsonTree(value0),
      kind1.encodeJsonTree(value1),
    ];
  }

  @override
  bool isValid((T0, T1) instance) {
    return kind0.isValid(instance.$1) &&
        kind1.isValid(instance.$2) &&
        super.isValid(instance);
  }

  @override
  (T0, T1) newInstance() {
    return (kind0.newInstance(), kind1.newInstance());
  }

  @override
  (T0, T1) permute((T0, T1) instance) {
    return (kind0.permute(instance.$1), kind1.permute(instance.$2));
  }

  @override
  String toString() {
    return kindForKind.debugString(this);
  }

  static Tuple2Kind _kindMapper(Mapper f, Tuple2Kind t) {
    return Tuple2Kind(
      f(t.kind0, 'kind0'),
      f(t.kind1, 'kind1'),
    );
  }
}
