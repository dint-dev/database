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
import 'package:database/database.dart';

class GeoPointFilter extends Filter {
  final GeoPoint near;
  final RangeFilter range;

  GeoPointFilter.withDistance(this.near, this.range)
      : assert(near != null),
        assert(range != null);

  GeoPointFilter.withNear(this.near)
      : assert(near != null),
        range = null;

  GeoPointFilter._({this.near, this.range});

  @override
  Iterable<Filter> get children sync* {
    if (range != null) {
      yield (range);
    }
  }

  @override
  int get hashCode => near.hashCode ^ range.hashCode;

  @override
  bool operator ==(other) =>
      other is GeoPointFilter && near == other.near && range == other.range;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitGeoPointFilter(this, context);
  }

  @override
  Filter simplify() {
    return GeoPointFilter._(near: near, range: range?.simplify());
  }
}

class ListFilter extends Filter {
  final Filter items;

  const ListFilter({this.items});

  @override
  Iterable<Filter> get children sync* {
    yield (items);
  }

  @override
  int get hashCode => items.hashCode;

  @override
  bool operator ==(other) => other is ListFilter && items == other.items;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitListFilter(this, context);
  }
}

/// A [Filter] which requires that the context has a specific property and
/// value of the property matches a filter.
class MapFilter extends Filter {
  final Map<String, Filter> properties;

  MapFilter(this.properties) {
    ArgumentError.checkNotNull(properties, 'properties');
  }

  @override
  Iterable<Filter> get children sync* {
    final properties = this.properties;
    if (properties != null) {
      for (var filter in properties.values) {
        yield (filter);
      }
    }
  }

  @override
  int get hashCode => const MapEquality<String, Filter>().hash(properties);

  @override
  bool operator ==(other) =>
      other is MapFilter &&
      const MapEquality<String, Filter>().equals(properties, other.properties);

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitMapFilter(this, context);
  }
}

/// A [Filter] which requires that the context is inside a range of valid values.
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

/// A [Filter] which requires that the context matches a regular expression.
class RegExpFilter extends Filter {
  final RegExp regExp;

  RegExpFilter(this.regExp) {
    if (regExp == null) {
      throw ArgumentError.notNull();
    }
  }

  @override
  int get hashCode => regExp.pattern.hashCode;

  @override
  bool operator ==(other) =>
      other is RegExpFilter && regExp.pattern == other.regExp.pattern;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitRegExpFilter(this, context);
  }
}

/// A [Filter] which requires the context is equal to a specific value.
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
