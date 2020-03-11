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

/// Matches [GeoPoint] values that are near a specified location.
class GeoPointFilter extends Filter {
  final GeoPoint near;
  final double maxDistance;

  GeoPointFilter.withMaxDistance(this.near, this.maxDistance)
      : assert(near != null),
        assert(maxDistance != null);

  @override
  Iterable<Filter> get children sync* {}

  @override
  int get hashCode => near.hashCode ^ maxDistance.hashCode;

  @override
  bool operator ==(other) =>
      other is GeoPointFilter &&
      near == other.near &&
      maxDistance == other.maxDistance;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitGeoPointFilter(this, context);
  }

  @override
  Filter simplify() {
    return this;
  }
}
