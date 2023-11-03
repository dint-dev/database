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

/// Counts memory usage.
///
/// ## Example
/// ```
/// import 'package:kind/kind.dart';
///
/// ```
class MemoryCounter {
  final _set = Set<Object>.identity();
  var _sum = 0;

  /// Mapper that can used by [Kind]s to visit their fields.
  late final Mapper mapper = _MemoryEstimatingMapper(this);

  /// Memory usage in bytes.
  int get memoryUsageInBytes {
    return _sum;
  }

  /// Adds [n] bytes to the sum.
  void add(int n) {
    _sum += n;
  }

  /// Adds memory needed by reference to [value] and the object itself (unless
  /// it has been visited already).
  ///
  /// If [kind] is not given, it is inferred from [value].
  void addObject<E>(E value, {required Kind? kind}) {
    kind ??= Kind.find(instance: value);
    _sum += 8;
    if (value == null || value is bool || value is num || !_set.add(value)) {
      return;
    }
    kind.memorySizeWith(this, value);
  }

  /// Tells whether [value] has been visited already.
  bool contains(Object value) {
    return _set.contains(value);
  }
}

class _MemoryEstimatingMapper extends Mapper {
  final MemoryCounter _builder;

  _MemoryEstimatingMapper(this._builder);

  @override
  V handle<V>({
    required ParameterType parameterType,
    required V value,
    required String name,
    Kind? kind,
    V? defaultConstant,
    String? jsonName,
    List<Trait>? tags,
  }) {
    _builder.addObject(value, kind: kind);
    return value;
  }
}
