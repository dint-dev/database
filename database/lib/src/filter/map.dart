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

/// A filter for maps.
///
/// ```
/// import 'package:database/filters.dart';
///
/// final filter = MapFilter({
///   'ingredients': ListFilter(
///     items: AndFilter([StringFilter('chicken'), StringFilter('rice')])
///   ),
/// });
/// ```
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
