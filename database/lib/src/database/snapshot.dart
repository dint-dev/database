// Copyright 2019 Gohilla Ltd.
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
import 'package:database/database.dart';
import 'package:meta/meta.dart';

/// Builds a [Snapshot].
class SnaphotBuilder {
  /// Document that produced this snapshot.
  Document document;

  bool exists;

  String versionId;

  /// Optional data of the snapshot.
  Map<String, Object> data;

  Object vendorData;

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
      vendorData: vendorData,
    );
  }
}

/// A snapshot of a [Document] version.
///
/// An example of getting a snapshot:
///     final document = database.collection('recipes').document('tiramisu');
///     final snapshot = await document.get();
///
/// You can also build a snapshot with [SnaphotBuilder].
class Snapshot {
  static const _deepEquality = DeepCollectionEquality();

  /// Document that produced this snapshot.
  final Document document;

  /// Whether the document exists.
  final bool exists;

  /// Optional version ID. Only some databases return version IDs.
  final String versionId;

  /// Optional data of the snapshot.
  final Map<String, Object> data;

  /// Optional vendor-specific data received from the database.
  /// For example, a database adapter for Elasticsearch could expose JSON
  /// response received from the REST API of Elasticsearch.
  final Object vendorData;

  Snapshot({
    @required this.document,
    @required this.data,
    this.exists = true,
    this.versionId,
    this.vendorData,
  })  : assert(document != null),
        assert(exists != null);

  Snapshot.notFound(this.document, {Object vendorData})
      : exists = false,
        data = null,
        versionId = null,
        vendorData = vendorData;

  @override
  int get hashCode =>
      document.hashCode ^
      exists.hashCode ^
      _deepEquality.hash(data) ^
      const DeepCollectionEquality().hash(vendorData);

  @override
  bool operator ==(other) =>
      other is Snapshot &&
      document == other.document &&
      exists == other.exists &&
      versionId == other.versionId &&
      _deepEquality.equals(data, other.data) &&
      const DeepCollectionEquality().equals(vendorData, other.vendorData);

  SnaphotBuilder toBuilder() {
    return SnaphotBuilder()
      ..document = document
      ..exists = exists
      ..versionId = versionId
      ..data = data
      ..vendorData = vendorData;
  }

  @override
  String toString() => 'Snapshot(document:$document, data:$data, ...)';
}
