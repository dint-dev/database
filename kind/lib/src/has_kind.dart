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

/// Interface for classes that can tell their [Kind].
///
/// If you extend [HasKind] you should override [runtimeKind] to return the
/// [Kind] of the class. This is used by [HasKind] to implement [hashCode],
/// [operator ==], and [toString].
///
/// ## Example
/// ```
/// import 'package:kind/kind.dart';
///
/// void main() {
///   // HasKind mixin gives you `==` and `hashCode`
///   final person = Person(name: 'Bob');
///   assert(person == Person(name: 'Bob'));
///   assert(person.hashCode == Person(name: 'Bob').hashCode);
///
///   // HasKind mixin gives you `toString()`
///   print(person.toString());
/// }
///
/// class Person with HasKind {
///   static const kind = ImmutableKind<Person>.withConstant(
///     name: 'Example',
///     blank: const Person(name: ''),
///     copy: _copy,
///   );
///
///   final String name;
///
///   Kind<Person> get runtimeKind => kind;
///
///   const Person({
///     required this.name,
///   });
///
///   static Person _copy(Mapper f, Person t) {
///     final name = f<String>.required(t.name, 'name');
///     if (f.canReturnSame) {
///       return t;
///     }
///     return Person(
///       name: name,
///     );
///   }
/// }
/// ```
abstract mixin class HasKind {
  const HasKind();

  @override
  int get hashCode {
    return InstanceMirror.of(this, kind: runtimeKind).hashCode;
  }

  /// [Kind] of this object.
  Kind<Object> get runtimeKind;

  @override
  bool operator ==(other) {
    if (other is! HasKind) {
      return false;
    }
    final kind = runtimeKind;
    if (!identical(kind, other.runtimeKind)) {
      return false;
    }
    final mirror = InstanceMirror.of(this, kind: kind);
    final otherMirror = InstanceMirror.of(other, kind: kind);
    return mirror == otherMirror;
  }

  @override
  String toString() {
    return runtimeKind.debugString(this);
  }
}
