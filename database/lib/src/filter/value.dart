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
import 'package:database/filter.dart';

/// Defines exact value.
class ValueFilter extends Filter {
  static const _equality = DeepCollectionEquality();

  final Object value;

  ValueFilter(this.value);

  @override
  int get hashCode => _equality.hash(value);

  @override
  bool operator ==(other) =>
      other is ValueFilter && _equality.equals(value, other.value);

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitValueFilter(this, context);
  }
}
