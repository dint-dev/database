import 'package:search/search.dart';
import 'package:test/test.dart';

void main() {
  group('TextSimplifier:', () {
    final s = CanineTextSimplifier();
    test('extended lating --> basic latin', () {
      expect(s.transform('Å'), ' a ');
      expect(s.transform(' å '), ' a ');
    });
    test('"Joe\'s" --> " joe "', () {
      expect(s.transform('Joe\'s'), ' joe ');
      expect(s.transform(' joe\'s '), ' joe ');
    });
    test('"example.com" --> " example com "', () {
      expect(s.transform('example.com'), ' example com ');
      expect(s.transform(' example.com '), ' example com ');
    });
  });
}
