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
import 'package:database/filter.dart';
import 'package:meta/meta.dart';

/// A [Filter] that matches [GeoPoint] values near a specified location.
///
/// ```
/// import 'package:database/filters.dart';
///
/// final filter = GeoPointFilter(
///   near: GeoPoint(0.0, 0.0),
///   maxDistanceInMeters: 5000,
/// );
/// ```
class GeoPointFilter extends Filter {
  /// Geographic point that defines valid [GeoPoint] values.
  final GeoPoint near;

  /// Maximum distance to [near] in meters.
  final double maxDistanceInMeters;

  const GeoPointFilter({
    @required this.near,
    @required this.maxDistanceInMeters,
  })  : assert(near != null),
        assert(maxDistanceInMeters != null);

  @Deprecated('Use `GeoPointFilter(near:_, maxDistanceInMeters:_)`')
  const GeoPointFilter.withMaxDistance(GeoPoint near, double maxDistance)
      : this(near: near, maxDistanceInMeters: maxDistance);

  @override
  Iterable<Filter> get children sync* {}

  @override
  int get hashCode => near.hashCode ^ maxDistanceInMeters.hashCode;

  @Deprecated('Use `maxDistanceInMeters`')
  double get maxDistance => maxDistanceInMeters;

  @override
  bool operator ==(other) =>
      other is GeoPointFilter &&
      near == other.near &&
      maxDistanceInMeters == other.maxDistanceInMeters;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitGeoPointFilter(this, context);
  }

  @override
  Filter simplify() {
    return this;
  }
}
