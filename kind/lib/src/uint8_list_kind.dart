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
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../kind.dart';

final class Uint8ListKind extends Kind<Uint8List>
    with PrimitiveKindMixin<Uint8List> {
  /// An empty [Uint8List].
  static final empty = Uint8List(0);

  /// [Kind] for [Uint8List] with any length.
  static const Uint8ListKind unlimited = Uint8ListKind();

  /// Length.
  final IntKind? length;

  const Uint8ListKind({
    super.name = 'Uint8List',
    this.length,
    super.traits,
  }) : super.constructor();

  @override
  Equality get equality => const ListEquality();

  @override
  Iterable<Uint8List> get examplesWithoutValidation {
    final minLength = length?.min ?? 0;
    final maxLength = length?.max ?? 0;
    final lengths = <int>{
      minLength - 1,
      minLength,
      minLength + 1,
      maxLength - 1,
      maxLength,
      maxLength + 1,
    }.toSet().where((element) => element >= 2);
    return [
      Uint8List(0),
      Uint8List.fromList([0]),
      Uint8List.fromList([255]),
      for (var length in lengths) Uint8List(length),
    ];
  }

  @override
  int get hashCode => Object.hash(
        Uint8ListKind,
        length?.min ?? 0,
        length?.max,
        super.hashCode,
      );

  @override
  bool operator ==(other) =>
      other is Uint8ListKind &&
      (length?.min ?? 0) == (other.length?.min ?? 0) &&
      length?.max == other.length?.max &&
      super == other;

  @override
  Uint8List clone(Uint8List instance) {
    if (instance is UnmodifiableUint8ListView) {
      return instance;
    }
    return Uint8List.fromList(instance);
  }

  @override
  int compare(Uint8List left, Uint8List right) {
    if (identical(left, right)) {
      return 0;
    }
    final minLength = min<int>(left.length, right.length);
    for (var i = 0; i < minLength; i++) {
      final r = left[i].compareTo(right[i]);
      if (r != 0) {
        return r;
      }
    }
    return left.length.compareTo(right.length);
  }

  @override
  String debugString(Uint8List instance) {
    if (instance.length <= 4) {
      return 'hex"${encodeHex(instance)}"';
    } else if (instance.length <= 64) {
      return 'hex"${encodeHex(instance)}" (L=${instance.length})';
    } else {
      return 'hex"${encodeHex(instance.sublist(0, 4))}...${encodeHex(instance.sublist(instance.length - 4, instance.length))}" (L=${instance.length})';
    }
  }

  /// Converts a hex string to a [Uint8List].
  Uint8List decodeHex(String hex) {
    if (hex.length % 2 != 0) {
      throw ArgumentError.value(hex, 'hex', 'must have even length');
    }
    final data = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < data.length; i++) {
      data[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return data;
  }

  @override
  Uint8List decodeJsonTree(Object? json) {
    if (json is String) {
      return decodeString(json);
    }
    throw JsonDecodingError.expectedString(json);
  }

  @override
  Uint8List decodeString(String string) {
    if (string.isEmpty) {
      return empty;
    }
    return base64Decode(string);
  }

  /// Converts a [Uint8List] to a hex string.
  String encodeHex(Uint8List data) {
    final sb = StringBuffer();
    for (var i = 0; i < data.length; i++) {
      final byte = data[i];
      if (byte < 0x10) {
        sb.write('0');
      }
      sb.write(byte.toRadixString(16));
    }
    return sb.toString();
  }

  @override
  Object? encodeJsonTree(Uint8List instance) {
    return encodeString(instance);
  }

  @override
  String encodeString(Uint8List instance) {
    return base64Encode(instance);
  }

  @override
  bool isDefaultValue(Object? instance) {
    return instance is Uint8List && instance.isEmpty;
  }

  @override
  int memorySize(Uint8List value) {
    return 128 + (value.lengthInBytes + 7) ~/ 8 * 8;
  }

  @override
  Uint8List newInstance() {
    return empty;
  }

  @override
  Uint8List permute(Uint8List instance) {
    final result = Uint8List.fromList(instance);
    for (var i = result.length - 1; i >= 0; i--) {
      final byte = result[i];
      final newByte = 0xFF & (byte + 1);
      result[i] = newByte;
      if (newByte > 0) {
        return result;
      }
    }

    var newLength = instance.length + 1;

    final maxLength = length?.max;
    if (maxLength != null && instance.length == maxLength) {
      newLength = length?.min ?? 0;
    }

    return Uint8List(newLength);
  }
}
