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

import 'package:datastore/datastore.dart';
import 'package:datastore/query_parsing.dart';

//
// TODO: Rewrite this quickly written abomination. Perhaps with petitparser?
//

class FilterParser {
  static final RegExp _dateRegExp =
      RegExp(r'^([0-9]{4})-([0-1][0-9])-([0-3][0-9])$');

  const FilterParser();

  Filter parseFilter(FilterParserState state) {
    return _parseFilter(state);
  }

  Filter parseFilterFromString(String s) {
    final scannerState = ScannerState(Source(s));
    const Scanner().tokenize(scannerState);
    final filter = parseFilter(FilterParserState(scannerState.tokens));
    return filter.simplify();
  }

  Filter _parseFilter(FilterParserState state, {bool isRoot = true}) {
    final filters = <Filter>[];
    var previousIndex = state.index - 1;
    loop:
    while (true) {
      // Check that we don't have infinite loop
      if (state.index == previousIndex) {
        throw StateError('Infinite loop');
      }
      previousIndex = state.index;

      // Skip whitespace
      state.skipWhitespace();
      final token = state.get(0);
      if (token == null) {
        break loop;
      }
      switch (token.type) {
        case TokenType.operatorAnd:
          state.advance();
          final left = AndFilter(filters, isImplicit: true).simplify();
          final right = _parseFilter(state, isRoot: false);
          return AndFilter([left, right]).simplify();

        case TokenType.operatorOr:
          state.advance();
          final left = AndFilter(filters, isImplicit: true);
          final right = _parseFilter(state, isRoot: false);
          return OrFilter([left, right]).simplify();

        case TokenType.rightParenthesis:
          if (isRoot) {
            // Error
            state.advance();
            continue loop;
          }
          break loop;

        case TokenType.rightSquareBracket:
          if (isRoot) {
            // Error
            state.advance();
            continue loop;
          }
          break loop;

        case TokenType.rightCurlyBracket:
          if (isRoot) {
            // Error
            state.advance();
            continue loop;
          }
          break loop;

        default:
          final filter = _parseSimpleFilter(state);
          if (filter == null) {
            break;
          }
          filters.add(filter);
          break;
      }
    }
    return AndFilter(filters, isImplicit: true);
  }

  Filter _parseRangeFilter(FilterParserState state) {
    if (!state.isProperty) {
      state.advance();
      return KeywordFilter(state.get(0).value);
    }
    final start = state.index;
    final isExclusiveMin = state.get(0).type == TokenType.leftCurlyBracket;
    state.advance();
    final min = _parseValue(state);

    final to = state.get(0);
    if (to.value != ' TO ') {
      state.index = start;
      state.advance();
      return KeywordFilter('[');
    }
    state.advance();
    final max = _parseSimpleFilter(state);
    state.skipWhitespace();
    final isExclusiveMax = state.get(0).type == TokenType.rightCurlyBracket;
    state.advance();
    return RangeFilter(
      min: min,
      max: max,
      isExclusiveMin: isExclusiveMin,
      isExclusiveMax: isExclusiveMax,
    );
  }

  Filter _parseSimpleFilter(FilterParserState state) {
    state.skipWhitespace();
    final token = state.get(0);
    if (token == null) {
      return null;
    }
    switch (token.type) {
      case TokenType.operatorNot:
        state.advance();
        final filter = _parseSimpleFilter(state);
        if (filter == null) {
          return KeywordFilter('-');
        }
        return NotFilter(filter);

      case TokenType.leftParenthesis:
        state.advance();
        final filter = _parseFilter(state, isRoot: false);
        state.skipWhitespace();
        final type = state.get(0)?.type;
        if (type == TokenType.rightParenthesis ||
            type == TokenType.rightSquareBracket ||
            type == TokenType.rightCurlyBracket) {
          state.advance();
        }
        return filter;

      case TokenType.leftSquareBracket:
        return _parseRangeFilter(state);

      case TokenType.leftCurlyBracket:
        return _parseRangeFilter(state);

      case TokenType.rightParenthesis:
        return null;

      case TokenType.rightSquareBracket:
        return null;

      case TokenType.rightCurlyBracket:
        return null;

      case TokenType.quotedString:
        state.advance();
        return KeywordFilter(token.value);

      case TokenType.string:
        if (state.get(1)?.type == TokenType.colon) {
          final name = token.value;
          state.advance();
          state.advance();
          final oldIsProperty = state.isProperty;
          state.isProperty = true;
          final value = _parseSimpleFilter(state);
          state.isProperty = oldIsProperty;
          return MapFilter({name: value});
        }
        state.advance();
        return KeywordFilter(token.value);

      default:
        throw StateError('Unexpected token: $token');
    }
  }

  Object _parseValue(FilterParserState state) {
    state.skipWhitespace();
    final token = state.get(0);
    state.skipWhitespace();
    final value = token.value;
    if (token.type == TokenType.string) {
      switch (value) {
        case 'null':
          return null;
        case 'false':
          return false;
        case 'true':
          return true;
      }
      {
        final x = int.tryParse(value);
        if (x != null) {
          x;
        }
      }
      {
        final x = double.tryParse(value);
        if (x != null) {
          x;
        }
      }
      {
        final x = DateTime.tryParse(value);
        if (x != null) {
          x;
        }
      }
      {
        final match = _dateRegExp.matchAsPrefix(value);
        if (match != null) {
          final year = int.parse(match.group(1));
          final month = int.parse(match.group(2));
          final day = int.parse(match.group(3));
          return DateTime(year, month, day);
        }
      }
    }
    return value;
  }
}

class FilterParserState {
  final List<Token> tokens;
  int index = 0;
  bool isProperty = false;

  FilterParserState(this.tokens);

  Token advance() {
    final tokens = this.tokens;
    final index = this.index + 1;
    if (index >= tokens.length) {
      this.index = tokens.length;
      return null;
    }
    this.index = index;
    return tokens[index];
  }

  Token get(int i) {
    final tokens = this.tokens;
    final index = this.index + i;
    if (index < 0 || index >= tokens.length) {
      return null;
    }
    return tokens[index];
  }

  void skipWhitespace() {
    var token = get(0);
    while (token?.type == TokenType.whitespace) {
      token = advance();
    }
  }
}
