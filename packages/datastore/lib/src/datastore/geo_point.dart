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

import 'dart:math';

/// A geographic point on Earth.
///
/// Both latitude and longitude should be between -180.0 (inclusive) and 180.0
/// (inclusive).
class GeoPoint implements Comparable<GeoPoint> {
  /// GeoPoint(0.0, 0.0).
  static const GeoPoint zero = GeoPoint(0.0, 0.0);

  /// Latitude. Should be in the range -180.0 <= value <= 180.0.
  final double latitude;

  /// Longitude. Should be in the range -180.0 <= value <= 180.0.
  final double longitude;

  /// Constructs a geographical point with latitude and longitude.
  ///
  /// Example:
  /// ```dart
  /// final sanFrancisco = GeoPoint(37.7749, -122.4194);
  /// ```
  const GeoPoint(this.latitude, this.longitude)
      : assert(latitude != null),
        assert(latitude >= -180.0),
        assert(latitude <= 180.0),
        assert(longitude != null),
        assert(longitude >= -180.0),
        assert(longitude <= 180.0);

  @override
  int get hashCode => latitude.hashCode << 2 ^ longitude.hashCode;

  /// Tells whether the geographical point appears to be valid.
  bool get isValid {
    return _isValidComponent(latitude) && _isValidComponent(longitude);
  }

  @override
  bool operator ==(other) =>
      other is GeoPoint &&
      latitude == other.latitude &&
      longitude == other.longitude;

  @override
  int compareTo(GeoPoint other) {
    var r = latitude.compareTo(other.latitude);
    if (r != 0) {
      return r;
    }
    return longitude.compareTo(other.longitude);
  }

  /// Calculates distance (in meters) to another geographical point.
  ///
  /// Example:
  /// ```dart
  /// final sanFrancisco = GeoPoint(37.7749, -122.4194);
  /// final london = GeoPoint(51.5074, -0.1278);
  /// final distanceInMeters = london.distanceTo(sanFrancisco);
  /// final distanceInKilometers = distanceInMeters ~/ 1000;
  /// ```
  double distanceTo(GeoPoint other) {
    final lat0 = _toRadians(latitude);
    final lon0 = _toRadians(longitude);
    final lat1 = _toRadians(other.latitude);
    final lon1 = _toRadians(other.longitude);
    final dlon = lon1 - lon0;
    final dlat = lat1 - lat0;
    final a = pow(sin(dlat / 2), 2.0) +
        cos(lat0) * cos(lat1) * pow(sin(dlon / 2), 2.0);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    const _radius = 6378137.0;
    return c * _radius;
  }

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';

  static bool _isValidComponent(double value) {
    return value != null && value.isFinite && value >= -180.0 && value <= 180.0;
  }

  static double _toRadians(double value) => (value / 180) * pi;
}
