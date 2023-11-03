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

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:os/os.dart';

import '../kind.dart';

/// [Kind] for [int].
final class IntKind extends Kind<int>
    with PrimitiveKindMixin<int>, ComparableKindMixin<int> {
  /// [Kind] for [IntKind].
  static const kindForKind = ImmutableKind(
    name: 'IntKind',
    blank: IntKind(),
    walk: _walk,
  );

  /// Value of [bits] when a signed integer is small enough to fit into a
  /// [double].
  static const int bitsWhenJsCompatible = 53;

  /// Value of [bits] when an unsigned integer is small enough to fit into a
  /// [double].
  static const int bitsWhenJsCompatibleUnsigned = 52;

  /// Maximum number of bits.
  final int bits;

  /// Whether the integer is unsigned.
  final bool isUnsigned;

  /// Minimum value.
  final int? min;

  /// Maximum value.
  final int? max;

  final List<int> Function(int length)? _typedDataFactory;

  /// Constructs a [Kind] for a signed [int].
  ///
  /// The default number of bits is chosen so that [isJsCompatible] is true.
  const IntKind({
    this.isUnsigned = false,
    this.bits = bitsWhenJsCompatible,
    this.min,
    this.max,
    super.traits,
  })  : _typedDataFactory = isRunningInJs ? null : Int64List.new,
        super.constructor(name: 'int');

  /// A shorthand for expressing that an [int] must be equal to [value].
  ///
  /// Useful for properties such as [StringKind.lengthInUtf8].
  @literal
  const IntKind.exactly(int value) : this(min: value, max: value);

  /// Constructs a [Kind] for a signed 16 bit [int].
  const IntKind.int16({
    int? min,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          bits: 16,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: Int16List.new,
        );

  /// Constructs a [Kind] for a signed 32 bit [int].
  const IntKind.int32({
    int? min,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          bits: 32,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: Int32List.new,
        );

  /// Constructs a [Kind] for a signed 64 bit [int].
  const IntKind.int64({
    int? min,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          bits: 64,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: isRunningInJs ? null : Int64List.new,
        );

  /// Constructs a [Kind] for a signed 8 bit [int].
  const IntKind.int8({
    int? min,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          bits: 8,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: Int8List.new,
        );

  /// Constructs a [Kind] for an unsigned 16 bit [int].
  const IntKind.uint16({
    int min = 0,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          isUnsigned: true,
          bits: 16,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: Uint16List.new,
        );

  /// Constructs a [Kind] for an unsigned 32 bit [int].
  const IntKind.uint32({
    int min = 0,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          isUnsigned: true,
          bits: 32,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: Uint32List.new,
        );

  /// Constructs a [Kind] for an unsigned 64 bit [int].
  const IntKind.uint64({
    int min = 0,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          isUnsigned: true,
          bits: 64,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: isRunningInJs ? null : Uint64List.new,
        );

  /// Constructs a [Kind] for an unsigned 8 bit [int].
  const IntKind.uint8({
    int min = 0,
    int? max,
    List<Trait>? traits,
  }) : this._raw(
          isUnsigned: true,
          bits: 8,
          min: min,
          max: max,
          traits: traits,
          typedDataFactory: Uint8List.new,
        );

  /// Constructs a [Kind] for an unsigned [int].
  ///
  /// The default number of bits is chosen so that [isJsCompatible] is true.
  const IntKind.unsigned({
    this.bits = bitsWhenJsCompatibleUnsigned,
    int this.min = 0,
    this.max,
    super.traits,
  })  : isUnsigned = true,
        _typedDataFactory = isRunningInJs ? null : Uint64List.new,
        super.constructor(name: 'int');

  const IntKind._raw({
    this.isUnsigned = false,
    required this.bits,
    this.min,
    this.max,
    super.traits,
    required List<int> Function(int length)? typedDataFactory,
  })  : _typedDataFactory = typedDataFactory,
        super.constructor(name: 'int');

  @override
  Iterable<int> get examplesWithoutValidation {
    final min = this.min;
    final max = this.max;
    return [
      0,
      1,
      -1,
      maxWhenBits(bits, isUnsigned: isUnsigned),
      minWhenBits(bits, isUnsigned: isUnsigned),
      if (min != null) ...[
        min - 1,
        min,
        min + 1,
      ],
      if (max != null) ...[
        max - 1,
        max,
        max + 1,
      ],
    ];
  }

  @override
  int get hashCode =>
      Object.hash(
        (IntKind),
        isUnsigned,
        bits,
        min,
        max,
      ) ^
      super.hashCode;

  /// Whether all values of this kind can be represented as a [double].
  ///
  /// In practice, this means [bits] must not be greater than 52/53 bits
  /// (depending on the value of [isUnsigned]).
  bool get isJsCompatible {
    final maxBits =
        isUnsigned ? bitsWhenJsCompatibleUnsigned : bitsWhenJsCompatible;
    return bits <= maxBits;
  }

  @override
  bool operator ==(other) =>
      other is IntKind &&
      isUnsigned == other.isUnsigned &&
      bits == other.bits &&
      min == other.min &&
      max == other.max &&
      super == other;

  @override
  void checkValid(int instance, {String? label}) {
    label ??= 'Value';
    final unsignedOrSigned = isUnsigned ? 'unsigned' : 'signed';

    final bits = this.bits;
    if (bits == 64) {
      if (isRunningInJs) {
        const mask64 = 0xFFFFFFFF * 0x100000000 + 0xFFFFFFFF;
        if (!(instance >= 0 && instance <= mask64)) {
          throw ArgumentError.value(
            instance,
            'value',
            '$label does not fit in $unsignedOrSigned $bits bit integer.',
          );
        }
      } else {
        const mask63 = 0x7FFFFFFF * 0x100000000 + 0xFFFFFFFF;
        const maxValue = mask63;
        const minValue = -mask63 - 1;
        if (!(instance >= minValue && instance <= maxValue)) {
          throw ArgumentError.value(
            instance,
            'value',
            '$label does not fit in $unsignedOrSigned $bits bit integer.',
          );
        }
      }
    }
    {
      final min = this.min;
      if (min != null && instance < min) {
        throw ArgumentError.value(
          instance,
          'instance',
          '$label is less than $min.',
        );
      }
    }
    {
      final max = this.max;
      if (max != null && instance > max) {
        throw ArgumentError.value(
          instance,
          'instance',
          '$label is greater than $max.',
        );
      }
    }
    super.checkValid(instance);
  }

  @override
  int decodeJsonTree(Object? json) {
    if (json is num) {
      return json.toInt();
    }
    if (json is String) {
      return decodeString(json);
    }
    throw JsonDecodingError.expectedNumberOrString(json);
  }

  @override
  int decodeString(String string) {
    final intValue = int.tryParse(string);
    if (intValue != null) {
      return intValue;
    }
    throw ArgumentError.value(string);
  }

  @override
  Object? encodeJsonTree(int instance) {
    if (!isJsCompatible) {
      return encodeString(instance);
    }
    return instance.toDouble();
  }

  @override
  String encodeString(int instance) {
    return instance.toString();
  }

  @override
  bool isValid(int instance) {
    final bits = this.bits;
    if (bits == 64) {
      if (isRunningInJs) {
        const mask64 = 0xFFFFFFFF * 0x100000000 + 0xFFFFFFFF;
        if (!(instance >= 0 && instance <= mask64)) {
          return false;
        }
      } else {
        return true;
      }
    }
    final isUnsigned = this.isUnsigned;
    if (instance < minWhenBits(bits, isUnsigned: isUnsigned)) {
      return false;
    }
    if (instance > maxWhenBits(bits, isUnsigned: isUnsigned)) {
      return false;
    }
    {
      final min = this.min;
      if (min != null && instance < min) {
        return false;
      }
    }
    {
      final max = this.max;
      if (max != null && instance > max) {
        return false;
      }
    }
    return super.isValid(instance);
  }

  @override
  int newInstance() {
    return 0;
  }

  @override
  List<int> newList(int length, {bool growable = true}) {
    if (!growable) {
      final typedDataFactory = _typedDataFactory;
      if (typedDataFactory != null) {
        return typedDataFactory(length);
      }
    }
    return super.newList(length, growable: growable);
  }

  @override
  int permute(int instance) {
    if (isRunningInJs) {
      var next = instance + 1;
      if (next > instance) {
        return next;
      }
      if (instance.isNegative) {
        next = instance ~/ 2;
        if (next > instance) {
          return next;
        }
      } else {
        next = 2 * instance;
        if (next > instance) {
          return next;
        }
      }
      return IntKind.minWhenBits(IntKind.bitsWhenJsCompatible);
    } else {
      return instance + 1;
    }
  }

  @override
  String toString() {
    return kindForKind.debugString(this);
  }

  /// Maximum value.
  static int maxWhenBits(int bits, {required bool isUnsigned}) {
    var n = bits;
    if (!isUnsigned) {
      n--;
    }
    var m = 1;
    const bit32 = 0x100000000;
    if (n >= 32) {
      n -= 32;
      m = bit32; // 2^32
    }
    final r = (bit32 - 1) >> (32 - n);
    return (r * m) + (m - 1);
  }

  /// Minimum value
  static int minWhenBits(int bits, {bool isUnsigned = false}) {
    if (isUnsigned) {
      return 0;
    }
    return -maxWhenBits(bits, isUnsigned: isUnsigned) - 1;
  }

  static IntKind _walk(Mapper f, IntKind t) {
    if (f.isGeneratingSource) {
      if (t.isUnsigned) {
        f.setDefaultValue('isUnsigned', true);
        f.setDefaultValue('min', 0);
        if (t.bits == 8) {
          f.setConstructorIdentifier('uint8');
          f.setDefaultValue('bits', 8);
        } else if (t.bits == 16) {
          f.setConstructorIdentifier('uint16');
          f.setDefaultValue('bits', 16);
        } else if (t.bits == 32) {
          f.setConstructorIdentifier('uint32');
          f.setDefaultValue('bits', 32);
        } else if (t.bits == 64) {
          f.setConstructorIdentifier('uint64');
          f.setDefaultValue('bits', 64);
        } else {
          f.setConstructorIdentifier('unsigned');
          f.setDefaultValue('bits', IntKind.bitsWhenJsCompatibleUnsigned);
        }
      } else {
        if (t.bits == 8) {
          f.setConstructorIdentifier('int8');
          f.setDefaultValue('bits', 8);
        } else if (t.bits == 16) {
          f.setConstructorIdentifier('int16');
          f.setDefaultValue('bits', 16);
        } else if (t.bits == 32) {
          f.setConstructorIdentifier('int32');
          f.setDefaultValue('bits', 32);
        } else if (t.bits == 64) {
          f.setConstructorIdentifier('int64');
          f.setDefaultValue('bits', 64);
        } else {
          f.setDefaultValue('bits', IntKind.bitsWhenJsCompatible);
        }
      }
    }
    final isUnsigned = f(t.isUnsigned, 'isUnsigned', defaultConstant: false);
    final bits = f(t.bits, 'bits');
    final min = f(t.min, 'min');
    final max = f(t.max, 'max');
    if (f.canReturnSame) {
      return t;
    }
    return IntKind(
      isUnsigned: isUnsigned,
      bits: bits,
      min: min,
      max: max,
      // It won't have the expected typedDataFactory :(
    );
  }
}
