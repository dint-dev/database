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

import 'package:database/schema.dart';
import 'package:meta/meta.dart';

/// Schema for [double] values.
@sealed
class DoubleSchema extends PrimitiveSchema<double> {
  static const String nameForJson = 'double';

  final bool supportSpecialValues;

  const DoubleSchema({this.supportSpecialValues = false});

  @override
  int get hashCode => (DoubleSchema).hashCode ^ supportSpecialValues.hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is DoubleSchema &&
      supportSpecialValues == other.supportSpecialValues;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitDoubleSchema(this, context);
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
    return argument == null ||
        (argument is double &&
            ((!argument.isNaN && !argument.isInfinite) ||
                supportSpecialValues));
  }
}
