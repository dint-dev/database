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

/// Function that constructs a new instance by mapping constructor arguments
/// of an existing instance.
///
/// ## Example
///
/// See [ImmutableKind].
typedef WalkFunction<T> = T Function(Mapper f, T t);

/// A class that has [walk] for mapping its fields.
///
/// This is required for using [ImmutableKind.walkable].
abstract mixin class Walkable {
  const Walkable();

  /// Copies this instance, mapping each field with [f].
  ///
  /// ## Example
  /// ```
  /// import 'package:kind/kind.dart';
  ///
  /// class Person with HasKind, HasMapping {
  ///   static const kind = ImmutableKind<Person>.withMapperMethod(
  ///     blank: const Person(),
  ///   );
  ///
  ///   final String name;
  ///
  ///   const Person({this.name=''});
  ///
  ///   @override
  ///   Kind<Person> runtimeKind => kind;
  ///
  ///   @override
  ///   Person mapper(Mapper f) {
  ///     return Person(
  ///       f(name, 'name', kind: const StringKind()),
  ///     );
  ///   }
  /// }
  /// ```
  Object walk(Mapper f);
}
