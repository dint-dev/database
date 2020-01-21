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

import 'package:database/filter.dart';

/// A [Filter] which requires that the context contains the natural language
/// keyword in some form or another. The exact semantics are unspecified.
class KeywordFilter extends Filter {
  final String value;

  const KeywordFilter(this.value) : assert(value != null);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(other) => other is KeywordFilter && value == other.value;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitKeywordFilter(this, context);
  }
}
