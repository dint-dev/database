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

/// A schema for [String] values.
class StringSchema extends PrimitiveSchema<String> {
  static const String nameForJson = 'string';

  final int maxLengthInUtf8;
  final int maxLengthInUtf16;

  const StringSchema({this.maxLengthInUtf8, this.maxLengthInUtf16});

  @override
  int get hashCode =>
      (StringSchema).hashCode ^
      maxLengthInUtf8.hashCode ^
      maxLengthInUtf16.hashCode;

  @override
  String get name => nameForJson;

  @override
  bool operator ==(other) =>
      other is StringSchema &&
      maxLengthInUtf8 == other.maxLengthInUtf8 &&
      maxLengthInUtf16 == other.maxLengthInUtf16;

  @override
  R acceptVisitor<R, C>(SchemaVisitor<R, C> visitor, C context) {
    return visitor.visitStringSchema(this, context);
  }

  @override
  bool isValidTree(Object argument, {List cycleDetectionStack}) {
    if (argument == null) {
      return true;
    }
    if (argument is String) {
      if (maxLengthInUtf16 != null && argument.length > maxLengthInUtf16) {
        return false;
      }
      return true;
    }
    return false;
  }
}
