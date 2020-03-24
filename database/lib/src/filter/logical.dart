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

/// Logical AND.
///
/// ```
/// import 'package:database/filters.dart';
///
/// // Distance to both San Francisco and Oakland must be less than 50 kilometers.
/// final locationFilter = MapFilter(
///   'location': AndFilter([
///     GeoPointFilter(
///       near: sanFrancisco,
///       maxDistance: 50,
///     ),
///     GeoPointFilter(
///       near: oakland,
///       maxDistance: 50,
///     ),
///   ]),
/// );
/// ```
class AndFilter extends Filter {
  final List<Filter> filters;
  final bool isImplicit;

  AndFilter(this.filters, {this.isImplicit = true})
      : assert(filters != null),
        assert(isImplicit != null);

  @override
  Iterable<Filter> get children sync* {
    yield* (filters);
  }

  @override
  int get hashCode =>
      ListEquality<Filter>().hash(filters) ^ isImplicit.hashCode;

  @override
  bool operator ==(other) =>
      other is AndFilter &&
      const ListEquality<Filter>().equals(filters, other.filters) &&
      isImplicit == other.isImplicit;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitAndFilter(this, context);
  }

  @override
  Filter simplify() {
    final oldFilters = filters;
    if (oldFilters.isEmpty) {
      return null;
    }
    if (oldFilters.length == 1) {
      return oldFilters.single.simplify();
    }
    final result = <Filter>[];
    for (var oldFilter in oldFilters) {
      final newFilter = oldFilter.simplify();

      // Eliminated entirely?
      if (newFilter == null) {
        continue;
      }

      // AndFilter?
      if (newFilter is AndFilter) {
        result.addAll(newFilter.filters);
        continue;
      }

      // Some other filter
      result.add(newFilter);
    }
    if (result.isEmpty) {
      return null;
    }
    if (result.length == 1) {
      return result.single;
    }
    return AndFilter(result);
  }
}

/// Logical NOT.
class NotFilter extends Filter {
  final Filter filter;

  NotFilter(this.filter) : assert(filter != null);

  @override
  Iterable<Filter> get children sync* {
    yield (filter);
  }

  @override
  int get hashCode => filter.hashCode;

  @override
  bool operator ==(other) => other is NotFilter && filter == other.filter;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitNotFilter(this, context);
  }

  @override
  Filter simplify() {
    final oldFilter = filter;
    final newFilter = oldFilter.simplify();
    if (identical(newFilter, oldFilter)) {
      return this;
    }
    return NotFilter(newFilter);
  }
}

/// Logical OR.
///
/// ```
/// import 'package:database/filters.dart';
///
/// // Distance to either San Francisco or Oakland must be less than 50 kilometers.
/// final locationFilter = MapFilter(
///   'location': OrFilter([
///     GeoPointFilter(
///       near: sanFrancisco,
///       maxDistance: 50,
///     ),
///     GeoPointFilter(
///       near: oakland,
///       maxDistance: 50,
///     ),
///   ]),
/// );
/// ```
class OrFilter extends Filter {
  final List<Filter> filters;

  OrFilter(this.filters) : assert(filters != null);

  @override
  Iterable<Filter> get children sync* {
    yield* (filters);
  }

  @override
  int get hashCode => ListEquality<Filter>().hash(filters);

  @override
  bool operator ==(other) =>
      other is OrFilter &&
      const ListEquality<Filter>().equals(filters, other.filters);

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitOrFilter(this, context);
  }

  @override
  Filter simplify() {
    final oldFilters = filters;
    if (oldFilters.isEmpty) {
      return null;
    }
    if (oldFilters.length == 1) {
      return oldFilters.single.simplify();
    }
    final result = <Filter>[];
    for (var oldFilter in oldFilters) {
      final newFilter = oldFilter.simplify();

      // Eliminated entirely?
      if (newFilter == null) {
        continue;
      }

      // AndFilter?
      if (newFilter is OrFilter) {
        result.addAll(newFilter.filters);
        continue;
      }

      // Some other filter
      result.add(newFilter);
    }
    if (result.isEmpty) {
      return null;
    }
    if (result.length == 1) {
      return result.single;
    }
    return OrFilter(result);
  }
}
