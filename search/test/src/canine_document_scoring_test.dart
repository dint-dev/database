import 'package:database/database_adapter.dart';
import 'package:database/filter.dart';
import 'package:search/search.dart';
import 'package:test/test.dart';

void main() {
  group('SimpleScoreCalculator:', () {
    group('KeywordFilter', () {
      double Function(String s) f;
      void useKeyword(String keyword) {
        final filter = KeywordFilter(keyword);
        final visitor = const CanineDocumentScoring().newState(filter);
        f = (s) => (filter.accept(visitor, s) * 100).round() / 100;
      }

      test('"bc"', () {
        useKeyword('bc');

        // Match
        expect(f('bc'), 1.08);
        expect(f('BC'), 1.08);
        expect(f(' bc '), 1.08);
        expect(f('a bc '), 1.08);
        expect(f('a bc d'), 1.08);

        // No match
        expect(f(''), 0.0);
        expect(f('ab'), 0.0);
        expect(f('cd'), 0.0);
      });

      test('" bc "', () {
        useKeyword(' bc ');

        // Match
        expect(f('bc'), 1.08);
        expect(f('BC'), 1.08);
        expect(f(' bc '), 1.08);
        expect(f('a bc '), 1.08);
        expect(f('a bc d'), 1.08);

        // No match
        expect(f(''), 0.0);
        expect(f('ab'), 0.0);
        expect(f('cd'), 0.0);
      });

      test('"b c"', () {
        useKeyword('b c');

        // Match
        expect(f('b c'), 1.11);
        expect(f('B C'), 1.11);
        expect(f(' b c '), 1.11);
        expect(f('a b c '), 1.11);
        expect(f('a b c d'), 1.11);

        // No match
        expect(f(''), 0.0);
        expect(f('ab'), 0.0);
        expect(f('abc'), 0.0);
        expect(f('b'), 0.0);
        expect(f('bc'), 0.0);
        expect(f('b '), 0.0);
      });

      test('''".,()[]"'Bc?!"''', () {
        final keyword = '''.,()[]"'Bc?!''';
        useKeyword(keyword);

        // Match
        expect(f('bc'), 1.32);
        expect(f('BC'), 1.32);
        expect(f('Bc'), 1.32);
        expect(f(keyword), 1.38);

        // No match
        expect(f('a b c d'), 0.0);
      });
    });

    test('RegExpFilter', () {
      final filter = RegExpFilter(RegExp(r'^.*bc.*$'));
      final visitor = const CanineDocumentScoring().newState(filter);

      // Match
      expect(filter.accept(visitor, 'abc'), 1.0);
      expect(filter.accept(visitor, 'abcd'), 1.0);
      expect(filter.accept(visitor, 'bcd'), 1.0);

      // No match
      expect(filter.accept(visitor, ''), 0.0);
      expect(filter.accept(visitor, 'ab'), 0.0);
      expect(filter.accept(visitor, 'cd'), 0.0);
    });

    test('MapFilter', () {
      final filter = MapFilter({'pi': KeywordFilter('3.14')});
      final visitor = const CanineDocumentScoring().newState(filter);

      // Match
      expect(filter.accept(visitor, {'pi': '3.14'}), 1.15);
      expect(filter.accept(visitor, {'pi': '3.14', 'other': 'value'}), 1.15);
      expect(filter.accept(visitor, {'pi': 'prefix 3.14 suffix'}), 1.15);
      expect(
        filter.accept(visitor, {
          'pi': ['prefix 3.14 suffix']
        }),
        1.15,
      );
      expect(
        filter.accept(visitor, {
          'pi': {'k': 'prefix 3.14 suffix'}
        }),
        1.15,
      );

      // No match
      expect(filter.accept(visitor, {'pi': 'other'}), 0.0);
      expect(filter.accept(visitor, {'pi': null}), 0.0);
      expect(filter.accept(visitor, {}), 0.0);
      expect(filter.accept(visitor, null), 0.0);
    });

    test('RangeFilter', () {
      final filter = RangeFilter(
        min: 2.0,
        max: 3.0,
      );
      final visitor = const CanineDocumentScoring().newState(filter);

      expect(defaultComparator(2.0, 1.5), 1);
      expect(defaultComparator(2.0, 2.0), 0);
      expect(defaultComparator(2.0, 2.5), -1);

      // Match
      expect(filter.accept(visitor, 2.0), 1.0);
      expect(filter.accept(visitor, 2.5), 1.0);
      expect(filter.accept(visitor, 3.0), 1.0);
      expect(filter.accept(visitor, 3.0), 1.0);

      // No match
      expect(filter.accept(visitor, 1.9), 0.0);
      expect(filter.accept(visitor, 3.1), 0.0);
      expect(filter.accept(visitor, null), 0.0);
    });

    test('NotFilter', () {
      final filter = NotFilter(KeywordFilter('x'));
      final visitor = const CanineDocumentScoring().newState(filter);

      // Match
      expect(filter.accept(visitor, 'x'), 0.0);

      // No match
      expect(filter.accept(visitor, 'other'), 1.0);
    });

    test('AndFilter', () {
      final filter = AndFilter([
        KeywordFilter('b'),
        KeywordFilter('c'),
      ]);
      final visitor = const CanineDocumentScoring().newState(filter);
      double f(String s) {
        return (filter.accept(visitor, s) * 100).round() / 100;
      }

      // Match
      expect(f('a b'), 1.04);
      expect(f('a b c'), 2.08);
      expect(f('a b c d'), 2.08);

      // No match
      expect(f(''), 0.0);
      expect(f('a'), 0.0);
    });

    test('OrFilter', () {
      final filter = OrFilter([
        KeywordFilter('b'),
        KeywordFilter('c'),
      ]);
      final visitor = const CanineDocumentScoring().newState(filter);
      double f(String s) {
        return (filter.accept(visitor, s) * 100).round() / 100;
      }

      // Match
      expect(f('a b'), 1.04);
      expect(f('a b c'), 1.04);
      expect(f('a b c d'), 1.04);
      expect(f('b'), 1.04);

      // No match
      expect(f(''), 0.0);
      expect(f('a'), 0.0);
      expect(f('a d'), 0.0);
      expect(f('d'), 0.0);
    });
  });
}
