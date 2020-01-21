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

/// Enables describing graph schema. The main use cases are validation and
/// GraphQL-like subgraph selections.
import 'package:database/schema.dart';
import 'package:meta/meta.dart';

/// Schema for [DateTime] values.
@sealed
class DateSchema extends PrimitiveSchema<DateTime> {
  static const String nameForJson = 'datetime';

  const DateSchema();

  @override
  int get hashCode => (DateSchema).hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) => other is DateSchema;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDateSchema(this, context);
  }
}
