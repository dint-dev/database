// Copyright 2019 terrier989@gmail.com.
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
import 'package:datastore/datastore.dart';
import 'package:meta/meta.dart';

/// Builds a [Snapshot].
class SnaphotBuilder {
  /// Document that produced this snapshot.
  Document document;

  bool exists;

  /// Optional data of the snapshot.
  Map<String, Object> data;

  @override
  int get hashCode => build().hashCode;

  @override
  bool operator ==(other) =>
      other is SnaphotBuilder && build() == other.build();

  Snapshot build() {
    return Snapshot(
      document: document,
      exists: exists ?? true,
      data: data,
    );
  }
}

/// A snapshot of a [Document] version.
///
/// You can build a snapshot with [SnaphotBuilder].
class Snapshot {
  static const _dataEquality = MapEquality<String, Object>(
    values: DeepCollectionEquality(),
  );

  /// Document that produced this snapshot.
  final Document document;

  /// Whether the document exists.
  final bool exists;

  /// Optional data of the snapshot.
  final Map<String, Object> data;

  Snapshot({
    @required this.document,
    @required this.data,
    this.exists = true,
  })  : assert(document != null),
        assert(exists != null);

  Snapshot.notFound(this.document)
      : exists = false,
        data = null;

  @override
  int get hashCode =>
      document.hashCode ^ exists.hashCode ^ _dataEquality.hash(data);

  @override
  bool operator ==(other) =>
      other is Snapshot &&
      document == other.document &&
      exists == other.exists &&
      _dataEquality.equals(data, other.data);

  SnaphotBuilder toBuilder() {
    return SnaphotBuilder()
      ..document = document
      ..exists = exists
      ..data = data;
  }

  @override
  String toString() => 'Snapshot(document:$document, data:$data, ...)';
}
