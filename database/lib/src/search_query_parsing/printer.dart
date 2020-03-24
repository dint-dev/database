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

import 'package:database/filter.dart';
import 'package:database/search_query_parsing.dart';
import 'package:meta/meta.dart';

/// Prints [Filter] trees in our search query language.
///
/// The language is very similar to [Lucene query language](https://lucene.apache.org/core/6_6_2/queryparser/org/apache/lucene/queryparser/classic/package-summary.html).
/// For a description of the language, see [SearchQueryParser].
///
/// ```
/// final printer = SearchQueryPrinter();
/// filter.acceptVisitor(printer);
/// final source = printer.toString();
/// ```
class SearchQueryPrinter extends FilterVisitor<void, Null> {
  static const _specialSubstrings = [
    '+',
    '-',
    '&&',
    '||',
    '!',
    '(',
    ')',
    '{',
    '}',
    '[',
    ']',
    '^',
    '"',
    '~',
    '*',
    '?',
    ':',
    '\\',
  ];

  final _sb = StringBuffer();

  @override
  String toString() => _sb.toString();

  @override
  void visitAndFilter(AndFilter filter, Null context) {
    var isFirst = true;
    for (var filter in filter.filters) {
      if (isFirst) {
        isFirst = false;
      } else {
        _sb.write(' AND ');
      }
      final parenthesis = filter is AndFilter || filter is OrFilter;
      if (parenthesis) {
        _sb.write('(');
      }
      filter.accept(this, context);
      if (parenthesis) {
        _sb.write(')');
      }
    }
  }

  @override
  void visitGeoPointFilter(GeoPointFilter filter, Null context) {
    // TODO: What syntax we should use?
    _sb.write('(near ');
    _sb.write(filter.near.latitude.toStringAsFixed(5));
    _sb.write(',');
    _sb.write(filter.near.longitude.toStringAsFixed(5));
    final maxDistance = filter.maxDistanceInMeters;
    if (maxDistance != null) {
      final s = maxDistance.toString();
      _sb.write(' ');
      _sb.write(s);
      if (!s.contains('.') && !s.contains('e') && !s.contains('E')) {
        _sb.write('.0');
      }
    }
    _sb.write(')');
  }

  @override
  void visitKeywordFilter(KeywordFilter filter, Null context) {
    writeStringValue(filter.value);
  }

  @override
  void visitListFilter(ListFilter filter, Null context) {
    filter.items?.accept(this, context);
  }

  @override
  void visitMapFilter(MapFilter filter, Null context) {
    var separator = false;
    for (var entry in filter.properties.entries.toList()..sort()) {
      if (separator) {
        _sb.write(' ');
      }
      separator = true;
      _sb.write(entry.key);
      _sb.write(':');
      entry.value.accept(this, context);
    }
  }

  @override
  void visitNotFilter(NotFilter filter, Null context) {
    _sb.write('-');
    final subfilter = filter.filter;
    final parenthesis = subfilter is AndFilter || subfilter is OrFilter;
    if (parenthesis) {
      _sb.write('(');
    }
    subfilter.accept(this, context);
    if (parenthesis) {
      _sb.write(')');
    }
  }

  @override
  void visitOrFilter(OrFilter filter, Null context) {
    var isFirst = true;
    for (var filter in filter.filters) {
      if (isFirst) {
        isFirst = false;
      } else {
        _sb.write(' OR ');
      }
      final parenthesis = filter is AndFilter || filter is OrFilter;
      if (parenthesis) {
        _sb.write('(');
      }
      filter.accept(this, context);
      if (parenthesis) {
        _sb.write(')');
      }
    }
  }

  @override
  void visitRangeFilter(RangeFilter filter, Null context) {
    final min = filter.min;
    final max = filter.max;
    if (min != null && max != null) {
      _sb.write(filter.isExclusiveMin ? '{' : '[');
      writeValue(min);
      _sb.write(' TO ');
      writeValue(max);
      _sb.write(filter.isExclusiveMax ? '}' : ']');
    } else if (min != null) {
      _sb.write(filter.isExclusiveMin ? '>' : '>=');
      writeValue(min);
    } else if (max != null) {
      _sb.write(filter.isExclusiveMax ? '<' : '<=');
      writeValue(max);
    }
  }

  @override
  void visitRegExpFilter(RegExpFilter filter, Null context) {
    _sb.write('/${filter.regExp.pattern}/');
  }

  @override
  void visitSqlFilter(SqlFilter filter, Null context) {
    _sb.write(filter.source);
  }

  @override
  void visitValueFilter(ValueFilter filter, Null context) {
    _sb.write('=');
    writeValue(filter.value);
  }

  @protected
  void write(Object value) {
    _sb.write(value);
  }

  @protected
  void writeStringValue(String value) {
    // If the value has whitespace, it's quoted
    final isQuoted = value.codeUnits.any((c) => c <= 32 || c == 0x7F) ||
        _specialSubstrings.any((special) => value.contains(special));

    // Escape some characters
    value = value.replaceAll(r'\', r'\\');
    value = value.replaceAll('"', r'\"');

    if (isQuoted) {
      _sb.write('"');
    }
    _sb.write(value);
    if (isQuoted) {
      _sb.write('"');
    }
  }

  @protected
  void writeValue(Object value) {
    if (value is String) {
      writeStringValue(value);
    } else {
      _sb.write(value);
    }
  }
}
