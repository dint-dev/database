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

/// Base class for delegating kind implementations such as [AliasKind].
abstract base class DelegatingKind<T> implements Kind<T> {
  final Kind<T> wrappedKind;

  const DelegatingKind(this.wrappedKind);

  @override
  Type get dartType => wrappedKind.dartType;

  @override
  InstanceMirror get defaultValueMirror => wrappedKind.defaultValueMirror;

  @override
  Equality get equality => wrappedKind.equality;

  @override
  Iterable<T> get examples => wrappedKind.examples;

  @override
  Iterable<T> get examplesThatAreInvalid => wrappedKind.examplesThatAreInvalid;

  @override
  Iterable<T> get examplesWithoutValidation =>
      wrappedKind.examplesWithoutValidation;

  @override
  int get hashCode => wrappedKind.hashCode;

  @override
  bool get isNullable => wrappedKind.isNullable;

  @override
  bool get isPrimitive => wrappedKind.isPrimitive;

  @override
  String? get jsonName => wrappedKind.jsonName;

  @override
  String get name => wrappedKind.name;

  @override
  List<Trait> get traits => wrappedKind.traits;

  @override
  bool operator ==(other) {
    return other is DelegatingKind<T> && wrappedKind == other.wrappedKind;
  }

  @override
  T asType(Object? value) {
    return wrappedKind.asType(value);
  }

  @override
  void checkDeclaration() {
    wrappedKind.checkDeclaration();
  }

  @override
  void checkInstance(Object? value) {
    wrappedKind.checkInstance(value);
  }

  @override
  void checkValid(T instance) {
    wrappedKind.checkValid(instance);
  }

  @override
  @nonVirtual
  void checkValidDynamic(Object? instance) {
    wrappedKind.checkValidDynamic(instance);
  }

  @override
  T clone(T instance) {
    return wrappedKind.clone(instance);
  }

  @override
  int compare(T left, T right) {
    return wrappedKind.compare(left, right);
  }

  @override
  String debugString(T instance) {
    return wrappedKind.debugString(instance);
  }

  @override
  T decodeJsonTree(Object? json) {
    return wrappedKind.decodeJsonTree(json);
  }

  @override
  T decodeString(String string) {
    return wrappedKind.decodeString(string);
  }

  @override
  Object? encodeJsonTree(T instance) {
    return wrappedKind.encodeJsonTree(instance);
  }

  @override
  String encodeString(T instance) {
    return wrappedKind.encodeString(instance);
  }

  @override
  bool isDefaultValue(Object? instance) {
    return wrappedKind.isDefaultValue(instance);
  }

  @override
  bool isInstance(Object? instance) {
    return wrappedKind.isInstance(instance);
  }

  @override
  bool isInstanceOfList(Object? instance) {
    return wrappedKind.isInstanceOfList(instance);
  }

  @override
  bool isInstanceOfSet(Object? instance) {
    return wrappedKind.isInstanceOfSet(instance);
  }

  @override
  bool isNullableSubKind(Kind other, {bool andNotEqual = true}) {
    return wrappedKind.isNullableSubKind(other, andNotEqual: andNotEqual);
  }

  @override
  bool isSubKind(Kind other, {bool andNotEqual = true}) {
    return wrappedKind.isSubKind(other, andNotEqual: andNotEqual);
  }

  @override
  bool isValid(T instance) {
    return wrappedKind.isValid(instance);
  }

  @override
  @nonVirtual
  bool isValidDynamic(Object? instance) {
    return wrappedKind.isValidDynamic(instance);
  }

  @override
  int memorySize(T instance) {
    return wrappedKind.memorySize(instance);
  }

  @override
  void memorySizeWith(MemoryCounter counter, T instance) {
    return wrappedKind.memorySizeWith(counter, instance);
  }

  @override
  T newInstance() {
    return wrappedKind.newInstance();
  }

  @override
  List<T> newList(int length, {bool growable = true}) {
    return wrappedKind.newList(length, growable: growable);
  }

  @override
  List<T> newListFrom(Iterable<T> iterable, {bool growable = true}) {
    return wrappedKind.newListFrom(iterable, growable: growable);
  }

  @override
  T permute(T instance) {
    return wrappedKind.permute(instance);
  }

  @override
  void register() {
    wrappedKind.register();
  }

  @override
  Kind<List<T>> toList() {
    return ListKind(elementKind: this);
  }

  @override
  Kind<T> toNonNullable() {
    return this;
  }

  @override
  Kind<T?> toNullable() {
    return NullableKind(this);
  }

  @override
  PolymorphicKind<T> toPolymorphic() {
    return PolymorphicKind<T>(
      name: name,
      defaultKinds: [this],
    );
  }

  @override
  Kind<Set<T>> toSet() {
    return SetKind(elementKind: this);
  }

  @override
  String toString() {
    return wrappedKind.toString();
  }
}
