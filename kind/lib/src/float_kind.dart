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

import 'package:os/os.dart';

import '../kind.dart';

/// [Kind] for [double].
final class FloatKind extends Kind<double>
    with PrimitiveKindMixin<double>, ComparableKindMixin<double> {
  /// [Kind] for [IntKind].
  static const kindForKind = ImmutableKind(
    name: 'FloatKind',
    blank: FloatKind(),
    walk: _walk,
  );

  static const minWhenFloat64 = 2.2250738585072014e-308;

  /// Whether non-finite values are allowed.
  final bool nonFinite;

  /// Whether negatives zeroes (-0.0) are allowed.
  final bool negativeZeroes;

  /// Minimum value.
  final double? min;

  /// Maximum value.
  final double? max;

  /// Whether the minimum value is exclusive.
  final bool isExclusiveMin;

  /// Whether the maximum value is exclusive.
  final bool isExclusiveMax;

  /// Maximum number of bits.
  final int bits;

  final List<double> Function(int length) _typedDataFactory;

  /// A finite 64-bit floating-point integer.
  ///
  /// If -0.0 is seen, it is converted to 0.0. Non-finite values are treated as
  /// errors.
  ///
  /// Use [FloatKind.float32] or [FloatKind.float64] if you want raw
  /// floating-point values (including non-finite values).
  const FloatKind({
    this.nonFinite = false,
    this.negativeZeroes = false,
    this.min,
    this.max,
    this.isExclusiveMin = false,
    this.isExclusiveMax = false,
    super.traits,
  })  : bits = 64,
        _typedDataFactory = Float64List.new,
        super.constructor(name: 'double');

  /// Raw "bfloat16" 16-bit floating-point value (including NaN, Infinity,
  /// -Infinity, and -0.0).
  const FloatKind.bfloat16({
    this.min,
    this.max,
    this.isExclusiveMin = false,
    this.isExclusiveMax = false,
    super.traits,
  })  : bits = 16,
        nonFinite = true,
        negativeZeroes = true,
        _typedDataFactory = Float32List.new,
        super.constructor(name: 'double');

  /// Raw 32-bit floating-point value (including NaN, Infinity, -Infinity, and
  /// -0.0).
  const FloatKind.float32({
    this.min,
    this.max,
    this.isExclusiveMin = false,
    this.isExclusiveMax = false,
    super.traits,
  })  : bits = 32,
        nonFinite = true,
        negativeZeroes = true,
        _typedDataFactory = Float32List.new,
        super.constructor(name: 'double');

  /// Raw 64-bit floating-point value (including NaN, Infinity, -Infinity, and
  /// -0.0).
  const FloatKind.float64({
    this.min,
    this.max,
    this.isExclusiveMin = false,
    this.isExclusiveMax = false,
    super.traits,
  })  : bits = 64,
        nonFinite = true,
        negativeZeroes = true,
        _typedDataFactory = Float64List.new,
        super.constructor(name: 'double');

  const FloatKind._({
    required this.bits,
    required this.nonFinite,
    required this.negativeZeroes,
    required this.min,
    required this.max,
    required this.isExclusiveMin,
    required this.isExclusiveMax,
    required List<double> Function(int length) typedDataFactory,
  })  : _typedDataFactory = typedDataFactory,
        super.constructor(name: 'double');

  @override
  Iterable<double> get examplesWithoutValidation {
    return [
      0.0,
      3.14,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      -0.0,
    ];
  }

  @override
  int get hashCode => Object.hash(FloatKind, bits, min, max, super.hashCode);

  @override
  bool operator ==(other) =>
      other is FloatKind &&
      bits == other.bits &&
      min == other.min &&
      max == other.max &&
      isExclusiveMin == other.isExclusiveMin &&
      isExclusiveMax == other.isExclusiveMax &&
      negativeZeroes == other.negativeZeroes &&
      super == other;

  @override
  String debugString(double instance) {
    final s = instance.toString();
    if (isRunningInJs && !s.contains('.')) {
      return '$s.0';
    }
    return s;
  }

  @override
  double decodeJsonTree(Object? json) {
    if (json is num) {
      final doubleValue = json.toDouble();
      if (doubleValue == -0.0 && !negativeZeroes) {
        return 0.0;
      }
      return doubleValue;
    }
    if (json is String) {
      switch (json) {
        case 'NaN':
          return double.nan;
        case 'Infinity':
          return double.infinity;
        case '-Infinity':
          return double.negativeInfinity;
      }
    }
    throw JsonDecodingError.expectedNumberOrString(json);
  }

  @override
  double decodeString(String string) {
    switch (string) {
      case 'NaN':
        return double.nan;
      case 'Infinity':
        return double.infinity;
      case '-Infinity':
        return double.negativeInfinity;
      default:
        return double.parse(string);
    }
  }

  @override
  Object? encodeJsonTree(double instance) {
    if (instance.isNaN) {
      return 'NaN';
    }
    if (instance.isInfinite) {
      if (instance.isNegative) {
        return '-Infinity';
      }
      return 'Infinity';
    }
    if (instance == -0.0 && !negativeZeroes) {
      instance = 0.0;
    }
    return instance;
  }

  @override
  String encodeString(double instance) {
    if (instance.isNaN) {
      return 'NaN';
    }
    if (instance.isInfinite) {
      if (instance.isNegative) {
        return '-Infinity';
      }
      return 'Infinity';
    }
    if (instance == -0.0 && !negativeZeroes) {
      instance = 0.0;
    }
    return instance.toString();
  }

  @override
  bool isDefaultValue(Object? instance) {
    return instance is double && 0.0 == instance && !instance.isNaN;
  }

  @override
  bool isValid(double instance) {
    {
      final min = this.min;
      if (min != null) {
        if (isExclusiveMin) {
          if (instance <= min) {
            return false;
          }
        } else {
          if (instance < min) {
            return false;
          }
        }
      }
    }
    {
      final max = this.max;
      if (max != null) {
        if (isExclusiveMax) {
          if (instance >= max) {
            return false;
          }
        } else {
          if (instance > max) {
            return false;
          }
        }
      }
    }
    return super.isValid(instance);
  }

  @override
  double newInstance() {
    return 0.0;
  }

  @override
  List<double> newList(int length, {bool growable = true}) {
    if (!growable) {
      return _typedDataFactory(length);
    }
    return super.newList(length, growable: growable);
  }

  @override
  double permute(double instance) {
    if (instance.isInfinite) {
      if (instance.isNegative) {
        return min ?? minWhenFloat64;
      } else {
        return double.nan;
      }
    } else if (instance.isNaN) {
      return double.negativeInfinity;
    }
    var next = instance + 1.0;
    if (next > instance) {
      return next;
    }
    next = 2 * instance;
    if (next > instance) {
      return next;
    }
    return double.infinity;
  }

  @override
  String toString() {
    return kindForKind.debugString(this);
  }

  static FloatKind _walk(Mapper f, FloatKind t) {
    if (f.isGeneratingSource) {
      if (t.negativeZeroes == true && t.nonFinite == true) {
        if (t.bits == 32) {
          f.setConstructorIdentifier('float32');
          f.setDefaultValue('bits', 32);
          f.setDefaultValue('nonFinite', true);
          f.setDefaultValue('negativeZeroes', true);
        } else if (t.bits == 64) {
          f.setConstructorIdentifier('float64');
          f.setDefaultValue('nonFinite', true);
          f.setDefaultValue('negativeZeroes', true);
        }
      }
    }
    final bits = f(t.bits, 'bits', defaultConstant: 64);
    final nonFinite = f(t.nonFinite, 'nonFinite');
    final negativeZeroes = f(t.negativeZeroes, 'negativeZeroes');
    final min = f(t.min, 'min', kind: Kind.forDouble.toNullable());
    final max = f(t.max, 'max', kind: Kind.forDouble.toNullable());
    final isExclusiveMin = f(t.isExclusiveMin, 'isExclusiveMin');
    final isExclusiveMax = f(t.isExclusiveMax, 'isExclusiveMax');
    if (f.canReturnSame) {
      return t;
    }
    return FloatKind._(
      bits: bits,
      min: min,
      max: max,
      isExclusiveMin: isExclusiveMin,
      isExclusiveMax: isExclusiveMax,
      nonFinite: nonFinite,
      negativeZeroes: negativeZeroes,
      typedDataFactory: Float64List.new,
      // It won't have the expected typedDataFactory :(
    );
  }
}
