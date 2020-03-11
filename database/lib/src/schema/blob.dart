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

import 'package:database/database.dart';

/// Enables describing graph schema. The main use cases are validation and
/// GraphQL-like subgraph selections.
import 'package:database/schema.dart';
import 'package:meta/meta.dart';

/// A schema for [Blob] values.
@sealed
class BlobSchema extends PrimitiveSchema<Blob> {
  static const String nameForJson = 'blob';

  const BlobSchema();

  @override
  int get hashCode => (BlobSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is BlobSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitBlobSchema(this, context);
  }
}
