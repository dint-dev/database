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
import 'dart:typed_data';

import '../kind.dart';

/// [Kind] for [List].
final class ListKind<E> extends Kind<List<E>> {
  /// [Kind] of list elements.
  final Kind<E> elementKind;

  final IntKind? length;

  const ListKind({
    super.name = 'List',
    required this.elementKind,
    this.length,
    super.traits,
  }) : super.constructor();

  @override
  Iterable<List<E>> get examplesWithoutValidation sync* {
    final lengths = <int?>[
      0,
      1,
      (length?.min ?? 0) - 1,
      length?.min,
      length?.max,
      (length?.max ?? 0) + 1,
    ].whereType<int>().where((element) => element >= 0).toSet().toList()
      ..sort();
    for (var length in lengths) {
      final list = List<E>.generate(
        length,
        (i) => elementKind.newInstance(),
      );
      yield (list);
    }
  }

  @override
  int get hashCode => Object.hash(ListKind, elementKind) ^ super.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ListKind && elementKind == other.elementKind && super == other;

  @override
  void checkValid(List<E> instance) {
    length?.checkValid(instance.length, label: 'Length');
    for (var element in instance) {
      elementKind.checkValid(element);
    }
    super.checkValid(instance);
  }

  @override
  List<E> clone(List<E> instance) {
    if (instance is TypedData) {
      return elementKind.newListFrom(instance);
    }
    final result = List<E>.from(instance.map(elementKind.clone));
    if (instance is UnmodifiableListView<E>) {
      return UnmodifiableListView<E>(result);
    }
    return result;
  }

  @override
  int compare(List<E> left, List<E> right) {
    if (identical(left, right)) {
      return 0;
    }
    final minLength = min<int>(left.length, right.length);
    final items = this.elementKind;
    for (var i = 0; i < minLength; i++) {
      final r = items.compare(left[i], right[i]);
      if (r != 0) {
        return r;
      }
    }
    return left.length.compareTo(right.length);
  }

  @override
  String debugString(List<E> instance) {
    final sb = StringBuffer();
    sb.write('<');
    sb.write(E);
    sb.write('>[');
    sb.write(ListKind.debugStringForIterableElements(
      iterable: instance,
      debugString: elementKind.debugString,
    ));
    sb.write(']');
    return sb.toString();
  }

  @override
  List<E> decodeJsonTree(Object? json) {
    if (json is List) {
      return json.map((e) => elementKind.decodeJsonTree(e)).toList();
    }
    throw JsonDecodingError.expectedList(json);
  }

  @override
  Object? encodeJsonTree(List<E> instance) {
    return instance.map((e) => elementKind.encodeJsonTree(e)).toList();
  }

  @override
  bool isDefaultValue(Object? instance) {
    return instance is List<E> && instance.isEmpty;
  }

  @override
  bool isValid(List<E> instance, {String? label}) {
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
  void memorySizeWith(MemoryCounter counter, List<E> instance) {
    counter.add(32);
    for (var item in instance) {
      counter.addObject(item, kind: elementKind);
    }
  }

  @override
  List<E> newInstance() {
    return <E>[];
  }

  @override
  List<E> permute(List<E> instance) {
    if (instance.isEmpty) {
      return [elementKind.newInstance()];
    }
    return instance.map(elementKind.permute).toList();
  }

  /// Prints comma-separated items.
  ///
  /// Each element is converted to string using [debugString].
  ///
  /// If [iterable] is empty, returns an empty string.
  ///
  /// If [iterable] elements do not fit in a single line with [maxLineLength]
  /// characters, the method slits the output into multiple lines. Each line
  /// is intended with [indent]. The first line is empty.
  ///
  /// If [iterable] is too large, returns result of [onTooLarge]. If
  /// [onTooLarge] is null, returns some unspecified summary string such as
  /// "...9999 items...".
  ///
  /// The [iterable] is too large when:
  ///   * It has more than [maxItems] elements.
  ///   * The string would be longer than [maxOutputLength].
  static String debugStringForIterableElements<E>({
    required Iterable<E> iterable,
    required String Function(E) debugString,
    String Function(Iterable<E> iterable)? onTooLarge,
    int maxItems = 100,
    int maxLineLength = 60,
    int maxOutputLength = 2000,
    String indent = '  ',
  }) {
    // Empty?
    if (iterable.isEmpty) {
      return '';
    }

    onTooLarge ??= (iterable) => '...${iterable.length} items...';

    // Too many items?
    if (iterable.length > maxItems) {
      return onTooLarge(iterable);
    }

    // Debug strings for items
    final strings = <String>[];
    var outputLength = 0;
    var isSingleLine = true;
    for (var element in iterable) {
      final s = debugString(element);
      outputLength += s.length + 2;

      // Too long debug string?
      if (outputLength > maxOutputLength) {
        return onTooLarge(iterable);
      }

      if (isSingleLine && (outputLength > maxLineLength || s.contains('\n'))) {
        isSingleLine = false;
      }

      strings.add(s);
    }

    // Single line?
    if (isSingleLine) {
      return strings.join(', ');
    }

    final sb = StringBuffer();
    sb.write('\n');
    final newLineReplacement = '\n$indent';
    for (var string in strings) {
      sb.write(indent);
      sb.write(string.replaceAll('\n', newLineReplacement));
      sb.write(',\n');
    }
    if (sb.length > maxOutputLength) {
      return onTooLarge(iterable);
    }
    return sb.toString();
  }
}
