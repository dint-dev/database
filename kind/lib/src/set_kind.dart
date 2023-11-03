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

import 'dart:collection';
import 'dart:math';

import '../kind.dart';

/// [Kind] for [Set].
final class SetKind<E> extends Kind<Set<E>> {
  /// [Kind] of set elements.
  final Kind<E> elementKind;

  /// Minimum and maximum length of the set.
  final IntKind? length;

  const SetKind({
    super.name = 'Set',
    required this.elementKind,
    this.length,
    super.traits,
  }) : super.constructor();

  @override
  Iterable<Set<E>> get examplesWithoutValidation sync* {
    yield (<E>{});
    final minLength = length?.min ?? 0;
    for (var item in elementKind.examplesWithoutValidation) {
      final set = <E>{};
      final n = max(1, minLength);
      for (var i = 0; i < n; i++) {
        set.add(item);
        item = elementKind.permute(item);
      }
      yield (set);
    }
  }

  @override
  int get hashCode =>
      Object.hash(SetKind, elementKind, length) ^ super.hashCode;

  @override
  bool operator ==(Object other) =>
      other is SetKind &&
      elementKind == other.elementKind &&
      length == other.length &&
      super == other;

  @override
  void checkValid(Set<E> instance) {
    length?.checkValid(instance.length, label: 'Length');
    for (var element in instance) {
      elementKind.checkValid(element);
    }
    super.checkValid(instance);
  }

  @override
  Set<E> clone(Set<E> instance) {
    final result = Set<E>.from(instance.map(elementKind.clone));
    if (instance is UnmodifiableSetView<E>) {
      return UnmodifiableSetView(result);
    }
    return result;
  }

  @override
  int compare(Set<E> left, Set<E> right) {
    if (equality.equals(left, right)) {
      return 0;
    }
    final leftList = left.toList();
    leftList.sort(elementKind.compare);
    final rightList = right.toList();
    rightList.sort(elementKind.compare);
    return ListKind(elementKind: elementKind).compare(leftList, rightList);
  }

  @override
  String debugString(Set<E> instance) {
    final sb = StringBuffer();
    sb.write('<');
    sb.write(E);
    sb.write('>{');
    sb.write(ListKind.debugStringForIterableElements(
      iterable: instance,
      debugString: elementKind.debugString,
    ));
    sb.write('}');
    return sb.toString();
  }

  @override
  Set<E> decodeJsonTree(Object? json) {
    if (json is List) {
      return json.map((e) => elementKind.decodeJsonTree(e)).toSet();
    }
    throw JsonDecodingError.expectedList(json);
  }

  @override
  Object? encodeJsonTree(Set<E> instance) {
    return instance.map((e) => elementKind.encodeJsonTree(e)).toList();
  }

  @override
  bool isDefaultValue(Object? instance) {
    return instance is Set<E> && instance.isEmpty;
  }

  @override
  bool isValid(Set<E> instance) {
    final length = this.length;
    if (length != null && !length.isValid(instance.length)) {
      return false;
    }
    if (!instance.every(elementKind.isValid)) {
      return false;
    }
    return super.isValid(instance);
  }

  @override
  void memorySizeWith(MemoryCounter counter, Set<E> instance) {
    counter.add(32);
    for (var item in instance) {
      counter.addObject(item, kind: elementKind);
    }
  }

  @override
  Set<E> newInstance() {
    return <E>{};
  }

  @override
  Set<E> permute(Set<E> instance) {
    return Set<E>.from(instance.map(elementKind.permute));
  }
}
