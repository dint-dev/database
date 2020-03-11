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

import 'dart:typed_data';

/// Enables describing graph schema. The main use cases are validation and
/// GraphQL-like subgraph selections.
import 'package:database/schema.dart';
import 'package:meta/meta.dart';

/// A schema for [Uint8List] values.
@sealed
class BytesSchema extends PrimitiveSchema<Uint8List> {
  static const String nameForJson = 'bytes';

  final int maxLength;

  const BytesSchema({this.maxLength});

  @override
  int get hashCode => (BytesSchema).hashCode ^ maxLength.hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is BytesSchema && maxLength == other.maxLength;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBytesSchema(this, context);
  }
}
