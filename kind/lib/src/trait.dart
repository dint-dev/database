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

import 'package:kind/kind.dart';
import 'package:meta/meta.dart';

/// Field metadata that you can attach when you use [ImmutableKind] or similar
/// kind.
@immutable
abstract class Trait<T> {
  /// Marks a field as a confidential value.
  ///
  /// The field will be ignored during [Kind.debugString].
  static const Trait confidential = _TagTrait._('confidential');

  /// Ignores a field during serialization.
  static const Trait noSerialization = _TagTrait._(
    'no_serialization',
    identifier: 'noSerialization',
  );

  /// Ignores a field during operator `==`, `hashCode`, and [Kind.compare].
  static const Trait noEquality = _TagTrait._(
    'no_equality',
    identifier: 'noEquality',
  );

  /// Constructor for subclasses.
  const Trait.constructor();

  @literal
  const factory Trait.tag(String tag) = _TagTrait<T>;

  String get name;

  void checkDeclarationWhenKind(Kind kind) {
    assert(kind is Kind<T>);
  }
}

class _TagTrait<T> extends Trait<T> {
  @override
  final String name;
  final String? _identifier;

  const _TagTrait(this.name)
      : _identifier = null,
        super.constructor();

  const _TagTrait._(this.name, {String? identifier})
      : _identifier = identifier ?? name,
        super.constructor();

  @override
  int get hashCode => (Trait).hashCode ^ name.hashCode;

  @override
  bool operator ==(other) => other is _TagTrait && name == other.name;

  @override
  String toString() {
    final identifier = _identifier;
    if (identifier != null) {
      return 'Tag.$identifier';
    }
    return 'Trait.tag("$name")';
  }
}
