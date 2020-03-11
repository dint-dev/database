import 'package:database/database.dart';

/// A database column.
///
/// An example:
///
///     final ratingColumn = database.collection('recipes').column('rating');
///
abstract class Column<T> implements ColumnQueryHelper<T> {
  Column();

  factory Column.fromCollection(Collection collection, String propertyName) =
      _ColumnQueryHelper<T>._;

  Collection get collection;
}

/// A helper for building columnar queries.
///
/// An example:
///
///     final column = database.collection('recipes').column('rating');
///
///     // Use ColumnQueryHelper
///     final top10Ratings = column.descending().take(10).toList();
///
abstract class ColumnQueryHelper<T> {
  Future<int> get length => toStream().length;

  ColumnQueryHelper<T> ascending();

  ColumnQueryHelper<T> descending();

  ColumnQueryHelper<T> skip(int n);

  ColumnQueryHelper<T> take(int n);

  Future<List<T>> toList() => toStream().toList();

  Stream<T> toStream();

  ColumnQueryHelper<T> where(bool Function(T) f);

  ColumnQueryHelper<T> whereEqual(T value) => where((item) => item == value);
}

class _ColumnQueryHelper<T> extends Column<T> with ColumnQueryHelper<T> {
  @override
  final Collection collection;
  final String _propertyName;
  final bool Function(T value) _where;
  final bool _isAscending;
  final int _skip;
  final int _take;

  _ColumnQueryHelper(
    this.collection,
    this._propertyName, [
    this._where,
    this._isAscending,
    this._skip,
    this._take,
  ]);

  _ColumnQueryHelper._(Collection collection, String propertyName)
      : this(
          collection,
          propertyName,
          null,
          null,
          null,
        );

  @override
  ColumnQueryHelper<T> ascending() {
    return _ColumnQueryHelper(
      collection,
      _propertyName,
      _where,
      true,
      _skip,
      _take,
    );
  }

  @override
  ColumnQueryHelper<T> descending() {
    return _ColumnQueryHelper(
      collection,
      _propertyName,
      _where,
      false,
      _skip,
      _take,
    );
  }

  @override
  ColumnQueryHelper<T> skip(int n) {
    if (n < 0) {
      throw ArgumentError.value(n);
    }
    return _ColumnQueryHelper(
      collection,
      _propertyName,
      _where,
      _isAscending,
      _skip + n,
      _take,
    );
  }

  @override
  ColumnQueryHelper<T> take(int n) {
    if (n < 0) {
      throw ArgumentError.value(n);
    }
    var take = _take;
    if (take == null || n < take) {
      take = n;
    }
    return _ColumnQueryHelper(
      collection,
      _propertyName,
      _where,
      _isAscending,
      _skip,
      take,
    );
  }

  @override
  Stream<T> toStream() async* {
    if (_isAscending != null) {
      final list = await toList();
      if (_isAscending) {
        list.sort();
      } else {
        list.sort();
      }
      for (var item in list) {
        yield (item);
      }
      return;
    }
    var skip = _skip;
    var take = _take;
    if (take == 0) {
      return;
    }
    await for (var chunk in collection.searchChunked()) {
      for (var item in chunk.snapshots) {
        final value = item.data[_propertyName];
        final where = _where;
        if (where != null && !where(value)) {
          continue;
        }
        if (skip > 0) {
          skip--;
          continue;
        }
        yield (value);
        take--;
        if (take == 0) {
          return;
        }
      }
    }
  }

  @override
  ColumnQueryHelper<T> where(bool Function(T) func) {
    final oldFunc = _where;
    final newFunc = (value) => oldFunc(value) && func(value);
    return _ColumnQueryHelper(
      collection,
      _propertyName,
      newFunc,
      _isAscending,
      _skip,
      _take,
    );
  }
}
