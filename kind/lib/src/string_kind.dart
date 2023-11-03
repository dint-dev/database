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

import 'dart:convert';
import 'dart:math';

import '../kind.dart';

/// [Kind] for [String].
final class StringKind extends Kind<String>
    with PrimitiveKindMixin<String>, ComparableKindMixin<String> {
  /// [Kind] for [StringKind].
  static const kindForKind = ImmutableKind(
    name: 'StringKind',
    blank: StringKind(),
    walk: _kindMapper,
  );

  /// Optimization for [regExp].
  static final _expandoForRegExp = Expando<RegExp>('regExp');

  /// Maximum number of lines.
  final int? maxLines;

  /// Minimum and/or maximum length when UTF-8 encoded.
  final IntKind? lengthInUtf8;

  /// Minimum and/or maximum length when UTF-16 encoded.
  final IntKind? lengthInUtf16;

  /// Regular expression pattern.
  final String? pattern;

  const StringKind({
    this.maxLines,
    this.lengthInUtf8,
    this.lengthInUtf16,
    this.pattern,
    super.examples,
    super.traits,
  }) : super.constructor(name: 'String');

  const StringKind.singleLine({
    IntKind? lengthInUtf8,
    IntKind? lengthInUtf16,
    String? pattern,
    List<Trait>? traits,
  }) : this(
          maxLines: 1,
          lengthInUtf8: lengthInUtf8,
          lengthInUtf16: lengthInUtf16,
          pattern: pattern,
          traits: traits,
        );

  const StringKind.singleLineShort({
    String? pattern,
    List<Trait>? traits,
  }) : this(
          maxLines: 1,
          lengthInUtf8: const IntKind(max: 80),
          pattern: pattern,
          traits: traits,
        );

  @override
  Iterable<String> get examplesWithoutValidation sync* {
    final minLengthInUtf8 = lengthInUtf8?.min;
    final maxLengthInUtf8 = lengthInUtf8?.max;
    final minLengthInUtf16 = lengthInUtf16?.min;
    final maxLengthInUtf16 = lengthInUtf16?.max;
    final utf8Lengths = <int>[
      1,
      minLengthInUtf8 ?? 0 - 1,
      maxLengthInUtf8 ?? 0 - 1,
      minLengthInUtf8 ?? 0,
      maxLengthInUtf8 ?? 0,
      2 * (minLengthInUtf16 ?? 0),
      2 * (maxLengthInUtf16 ?? 0),
      2 * (minLengthInUtf16 ?? 0) + 1,
      2 * (maxLengthInUtf16 ?? 0) + 1,
    ].where((element) => element >= 1).toSet().toList()
      ..sort();
    final characters = [
      'a', // One byte in UTF-8
      '£', // Two bytes in UTF-8
      '€', // Three bytes in UTF-8
      '𐍈', // Four bytes in UTF-8
      '😃', // Emoji
      ' ',
      '\n',
    ];
    for (var utf8Length in utf8Lengths) {
      for (var character in characters) {
        yield (character * utf8Length);
      }
    }
  }

  @override
  int get hashCode => Object.hash(
        StringKind,
        maxLines,
        lengthInUtf8?.max ?? 0,
        lengthInUtf16?.max ?? 0,
        pattern,
        super.hashCode,
      );

  RegExp? get regExp {
    final pattern = this.pattern;
    if (pattern == null) {
      return null;
    }
    return _expandoForRegExp[this] ??= RegExp(pattern);
  }

  @override
  bool operator ==(other) =>
      other is StringKind &&
      maxLines == other.maxLines &&
      (lengthInUtf8?.min ?? 0) == (other.lengthInUtf8?.min ?? 0) &&
      lengthInUtf8?.max == other.lengthInUtf8?.max &&
      (lengthInUtf16?.min ?? 0) == (other.lengthInUtf16?.min ?? 0) &&
      lengthInUtf16?.max == other.lengthInUtf16?.max &&
      pattern == other.pattern &&
      super == other;

  @override
  String debugString(String instance) {
    final sb = StringBuffer();
    sb.write('"');
    var start = 0;
    for (var i = 0; i < instance.length; i++) {
      if (i == 64 && instance.length > 128) {
        sb.write(instance.substring(start, i));
        sb.write('" ... "');
        i = instance.length - 64;
        start = i;
        i--; // Because of i++
        continue;
      }
      final c = instance.codeUnitAt(i);
      if (c < 32 || c == 127) {
        sb.write(instance.substring(start, i));
        start = i + 1;
        sb.write(_escapedChar(c));
      }
    }
    sb.write(instance.substring(start));
    sb.write('"');
    return sb.toString();
  }

  @override
  String decodeJsonTree(Object? json) {
    if (json is String) {
      return json;
    }
    throw JsonDecodingError.expectedString(json);
  }

  @override
  String decodeString(String string) {
    return string;
  }

  @override
  Object? encodeJsonTree(String instance) {
    return instance;
  }

  @override
  String encodeString(String instance) {
    return instance;
  }

  @override
  bool isValid(String instance) {
    final maxLines = this.maxLines;
    if (maxLines != null) {
      var n = maxLines;
      if (n < 1) {
        return false;
      }
      for (var i = 0; i < instance.length; i++) {
        if (instance.codeUnitAt(i) == 10) {
          n--;
          if (n < 1) {
            return false;
          }
        }
      }
    }
    final lengthInUtf16 = this.lengthInUtf16;
    if (lengthInUtf16 != null && !lengthInUtf16.isValid(instance.length)) {
      return false;
    }
    final lengthInUtf8 = this.lengthInUtf8;
    if (lengthInUtf8 != null &&
        !lengthInUtf8.isValid(utf8.encode(instance).length)) {
      return false;
    }
    final regExp = this.regExp;
    if (regExp != null && !regExp.hasMatch(instance)) {
      return false;
    }
    return super.isValid(instance);
  }

  @override
  int memorySize(String value) {
    return 32 + (2 * value.length + 7) ~/ 8 * 8;
  }

  @override
  String newInstance() {
    return '';
  }

  @override
  String permute(String instance) {
    //
    // We use simplified alphabet A-Z
    //
    if (instance.isEmpty) {
      return 'A';
    }
    final runes = instance.runes.toList();
    const A = 0x41;
    const Z = 0x5a;
    for (var i = runes.length - 1; i >= 0; i--) {
      final rune = runes[i];
      if (rune < Z) {
        runes[i] = min<int>(rune + 1, A);
        return String.fromCharCodes(runes);
      }
      runes[i] = A;
    }
    return '${instance}A';
  }

  @override
  String toString() {
    return kindForKind.debugString(this);
  }

  static String _escapedChar(int value) {
    switch (value) {
      case 9:
        return r'\t';
      case 10:
        return r'\n';
      case 11:
        return r'\v';
      case 13:
        return r'\r';
      default:
        return '\\x${value.toRadixString(16).padLeft(2, '0')}';
    }
  }

  static StringKind _kindMapper(Mapper f, StringKind t) {
    final maxLines = f(t.maxLines, 'maxLines');
    final lengthInUtf8 = f(
      t.lengthInUtf8,
      'lengthInUtf8',
      kind: IntKind.kindForKind,
    );
    final lengthInUtf16 = f(
      t.lengthInUtf16,
      'lengthInUtf16',
      kind: IntKind.kindForKind,
    );
    final pattern = f(t.pattern, 'pattern');
    return StringKind(
      maxLines: maxLines,
      lengthInUtf8: lengthInUtf8,
      lengthInUtf16: lengthInUtf16,
      pattern: pattern,
    );
  }
}
