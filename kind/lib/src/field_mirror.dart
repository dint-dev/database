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

import '../kind.dart';

/// Information about a field.
///
/// Use [InstanceMirror] for access to fields of an instance.
class FieldMirror<T> extends HasKind with Walkable {
  static const _kind = ImmutableKind<FieldMirror>.walkable(
    blank: FieldMirror(
      name: '',
      jsonName: '',
      kind: BoolKind(),
      defaultValue: false,
    ),
  );

  /// Name of the field.
  final String name;

  /// JSON name.
  final String jsonName;

  /// [Kind] of the field.
  final Kind kind;

  /// Default value.
  final T defaultValue;

  /// Tags of the field.
  final List<Trait> traits;

  const FieldMirror({
    required this.name,
    required this.jsonName,
    required this.kind,
    required this.defaultValue,
    this.traits = const [],
  });

  @override
  int get hashCode =>
      name.hashCode ^
      jsonName.hashCode ^
      kind.hashCode ^
      kind.equality.hash(defaultValue) ^
      const ListEquality().hash(traits);

  @override
  Kind<Object> get runtimeKind => _kind;

  @override
  bool operator ==(other) =>
      other is FieldMirror &&
      name == other.name &&
      jsonName == other.jsonName &&
      kind == other.kind &&
      kind.equality.equals(defaultValue, other.defaultValue) &&
      const ListEquality().equals(traits, other.traits);

  @override
  FieldMirror<T> walk(Mapper f) {
    final name = f(
      this.name,
      'name',
      kind: const StringKind.singleLineShort(),
    );
    final jsonName = f(
      this.jsonName,
      'jsonName',
      kind: const StringKind.singleLineShort(),
    );
    final kind = f(
      this.kind,
      'kind',
      superKind: Kind.forKindInDebugMode,
    );
    final defaultValue = f(this.defaultValue, 'defaultValue');
    if (f.canReturnSame) {
      return this;
    }
    return FieldMirror<T>(
      name: name,
      jsonName: jsonName,
      kind: kind,
      defaultValue: defaultValue,
    );
  }
}
