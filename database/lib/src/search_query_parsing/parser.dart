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

import 'dart:convert';

import 'package:database/database.dart';
import 'package:database/search_query_parsing.dart';

/// Parser for the search query syntax supported by 'package:database'.
class SearchQueryParser {
  const SearchQueryParser();

  /// Parses all remaining tokens in the state.
  Filter parseFilter(SearchQueryParserState state) {
    return _parseFilter(state);
  }

  /// Parses the string.
  Filter parseFilterFromString(String s) {
    final scannerState = ScannerState(Source(s));
    const Scanner().scan(scannerState);
    final filter = parseFilter(SearchQueryParserState(scannerState.tokens));
    return filter.simplify();
  }

  Filter _parseFilter(SearchQueryParserState state, {bool isRoot = true}) {
    final filters = <Filter>[];
    var previousIndex = state.index - 1;
    loop:
    while (true) {
      // SAFETY CHECKUP:
      // Check that we are not in an infinite loop
      if (state.index == previousIndex) {
        throw StateError('Infinite loop');
      }
      previousIndex = state.index;

      // Skip whitespace
      state.skipWhitespace();

      // Get first token
      final token = state.get(0);
      if (token == null) {
        break loop;
      }

      // Switch token type
      switch (token.type) {
        //
        // Operators
        //

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

        //
        // Terminating tokens
        //

        case TokenType.rightParenthesis:
          if (isRoot) {
            // Error
            state.advance();
            continue loop;
          }

          // End the filter
          break loop;

        case TokenType.rightSquareBracket:
          if (isRoot) {
            // Error
            state.advance();
            continue loop;
          }

          // End the filter
          break loop;

        case TokenType.rightCurlyBracket:
          if (isRoot) {
            // Error
            state.advance();
            continue loop;
          }

          // End the filter
          break loop;

        //
        // Otherwise
        //
        default:

          // Pare simple filter
          final filter = _parseSimpleFilter(state);
          if (filter != null) {
            filters.add(filter);
          }
          break;
      }
    }
    return AndFilter(filters, isImplicit: true);
  }

  Filter _parseRangeFilter(SearchQueryParserState state) {
    // '[' or '{'
    final startIndex = state.index;
    final isExclusiveMin = state.get(0).type == TokenType.leftCurlyBracket;
    state.advance();
    state.skipWhitespace();

    // Min value
    final min = _parseValue(state, supportStar: true);
    state.skipWhitespace();

    // TO
    final to = state.get(0);
    state.advance();
    state.skipWhitespace();
    if (to.type != TokenType.string || to.value != 'TO') {
      // Go back and handle initial '[' / '{' as keyword
      state.index = startIndex;
      final value = state.get(0).value;
      state.advance();
      return KeywordFilter(value);
    }

    // Max value
    final max = _parseValue(state, supportStar: true);
    state.skipWhitespace();

    // ']' or '}'
    final isExclusiveMax = state.get(0).type == TokenType.rightCurlyBracket;
    state.advance();
    state.skipWhitespace();

    return RangeFilter(
      min: min,
      max: max,
      isExclusiveMin: isExclusiveMin,
      isExclusiveMax: isExclusiveMax,
    );
  }

  /// Parse a filter without attempting to handle operators like AND/OR after
  /// the filter.
  Filter _parseSimpleFilter(SearchQueryParserState state) {
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

      case TokenType.equal:
        state.advance();
        return ValueFilter(_parseValue(state));

      case TokenType.greaterThan:
        state.advance();
        return RangeFilter(min: _parseValue(state), isExclusiveMin: true);

      case TokenType.greaterThanEqual:
        state.advance();
        return RangeFilter(min: _parseValue(state));

      case TokenType.lessThan:
        state.advance();
        return RangeFilter(max: _parseValue(state), isExclusiveMax: true);

      case TokenType.lessThanEqual:
        state.advance();
        return RangeFilter(max: _parseValue(state));

      case TokenType.quotedString:
        state.advance();
        return KeywordFilter(token.value);

      case TokenType.string:
        if (state.get(1)?.type == TokenType.colon) {
          // This part of a MapFilter
          //
          // Examples:
          //   'name:'
          //   'name:value'
          //
          final name = token.value;
          state.advance();
          state.advance();
          final oldIsProperty = state.isProperty;
          state.isProperty = true;

          // Parse value
          final value = _parseSimpleFilter(state);
          state.isProperty = oldIsProperty;
          return MapFilter({name: value});
        }

        state.advance();
        return KeywordFilter(token.value);

      //
      // Token that always result in null.
      //
      case TokenType.rightParenthesis:
        return null;

      case TokenType.rightSquareBracket:
        return null;

      case TokenType.rightCurlyBracket:
        return null;

      default:
        throw StateError('Unexpected token: $token');
    }
  }

  /// Parses a value. We deviate from Lucene syntax features here.
  ///
  /// Examples:
  ///   * example --> "example"
  ///   * true --> true
  ///   * "true" --> "true"
  ///   * 3 --> 3
  ///   * 3.14 --> 3.14
  ///   * 2020-12-31 --> Date(2020, 12, 31)
  Object _parseValue(SearchQueryParserState state, {bool supportStar = false}) {
    // Skip whitespace before the token
    state.skipWhitespace();

    // Get token
    final token = state.get(0);
    state.advance();

    // Skip whitespace after the token
    state.skipWhitespace();

    // Interpret value
    final value = token.value;

    if (token.type == TokenType.string) {
      // Special constant?
      switch (value) {
        case 'null':
          return null;
        case 'false':
          return false;
        case 'true':
          return true;
        case '*':
          if (supportStar) {
            return null;
          }
        // TODO: 'undefined'?
      }

      // Int?
      {
        final x = int.tryParse(value);
        if (x != null) {
          return x;
        }
      }

      // Double?
      {
        final x = double.tryParse(value);
        if (x != null) {
          return x;
        }
      }

      // Date?
      {
        final x = Date.tryParse(value);
        if (x != null) {
          return x;
        }
      }

      // DateTime?
      {
        final x = DateTime.tryParse(value);
        if (x != null) {
          return x;
        }
      }

      // Bytes
      const prefix = 'base64:';
      if (value.startsWith(prefix)) {
        try {
          return base64Decode(value.substring(prefix.length));
        } on FormatException {
          // Ignore
        }
      }
    }

    // Not a special value.
    // Return the token value.
    return value;
  }
}

/// State parameter used by [SearchQueryParser].
class SearchQueryParserState {
  final List<Token> tokens;
  int index = 0;
  bool isProperty = false;

  SearchQueryParserState(this.tokens);

  /// Discards the current token and moves to the next one.
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

  /// Returns the token the index. Calling `get(0)` gives the current.
  Token get(int i) {
    final tokens = this.tokens;
    final index = this.index + i;
    if (index < 0 || index >= tokens.length) {
      return null;
    }
    return tokens[index];
  }

  /// Skips possible whitespace at the current token.
  void skipWhitespace() {
    var token = get(0);
    while (token?.type == TokenType.whitespace) {
      token = advance();
    }
  }
}
