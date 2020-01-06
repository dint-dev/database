import 'package:datastore/datastore.dart';
import 'package:test/test.dart';

void main() {
  group('GeoPoint:', () {
    final sanFrancisco = GeoPoint(37.7749, -122.4194);
    final london = GeoPoint(51.5074, -0.1278);
    final sydney = GeoPoint(-33.8688, 151.2093);

    test('"==" / hashCode', () {
      final value = GeoPoint(1.2, 3.4);
      final clone = GeoPoint(1.2, 3.4);
      final other0 = GeoPoint(1.2, 3); // Other latitude
      final other1 = GeoPoint(1, 3.4); // Other longitude
      expect(value, clone);
      expect(value, isNot(other0));
      expect(value, isNot(other1));
      expect(value.hashCode, clone.hashCode);
      expect(value.hashCode, isNot(other0.hashCode));
      expect(value.hashCode, isNot(other1.hashCode));
    });

    test('distanceTo(..): London - London --> 0 km', () {
      expect(london.distanceTo(london), 0);
    });

    test('distanceTo(..): London - San Francisco --> 8,626 km', () {
      expect(london.distanceTo(sanFrancisco) ~/ 1000, 8626);
      expect(sanFrancisco.distanceTo(london) ~/ 1000, 8626);
    });

    test('distanceTo(..): San Francisco - Sydney --> 11,961 km', () {
      expect(sanFrancisco.distanceTo(sydney) ~/ 1000, 11961);
      expect(sydney.distanceTo(sanFrancisco) ~/ 1000, 11961);
    });
  });
}
