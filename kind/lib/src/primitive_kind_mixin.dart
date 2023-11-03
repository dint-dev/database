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

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../kind.dart';

/// Mixin for [Kind] classes of primitive values.
mixin PrimitiveKindMixin<T> on Kind<T> {
  @override
  @nonVirtual
  InstanceMirror get defaultValueMirror => InstanceMirror.forPrimitive;

  @override
  Equality get equality => const DefaultEquality();

  @override
  @nonVirtual
  bool get isPrimitive => true;

  @override
  int memorySize(T value) {
    return 8;
  }

  @override
  @nonVirtual
  void memorySizeWith(MemoryCounter counter, value) {
    counter.add(memorySize(value));
  }

  @override
  List<T> newList(int length, {bool growable = true}) {
    return List<T>.filled(length, newInstance(), growable: growable);
  }
}
