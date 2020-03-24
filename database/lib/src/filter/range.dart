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

/// Defines minimum and maximum value.
///
/// ```
/// import 'package:database/filters.dart';
///
/// final filter = RangeFilter(min:0.0, max:1.0, isExclusiveMax:true);
/// ```
class RangeFilter extends Filter {
  final Object min;
  final Object max;
  final bool isExclusiveMin;
  final bool isExclusiveMax;

  RangeFilter({
    this.min,
    this.max,
    this.isExclusiveMin = false,
    this.isExclusiveMax = false,
  }) {
    if (min == null && max == null) {
      throw ArgumentError('RangeFilter must have non-null arguments');
    }
  }

  @override
  int get hashCode =>
      min.hashCode ^
      max.hashCode ^
      isExclusiveMin.hashCode ^
      isExclusiveMax.hashCode;

  @override
  bool operator ==(other) =>
      other is RangeFilter &&
      min == other.min &&
      max == other.max &&
      isExclusiveMin == other.isExclusiveMin &&
      isExclusiveMax == other.isExclusiveMax;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitRangeFilter(this, context);
  }
}
