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

import 'package:charcode/ascii.dart';
import 'package:database/search_query_parsing.dart';

const int _eof = -1;

/// Source scanner used by [SearchQueryParser].
class Scanner {
  static final _propertyNameRegExp = RegExp(r'^[a-zA-Z_$@][a-zA-Z_$@-]*');

  const Scanner();

  void scan(ScannerState state) {
    var infiniteLoopCheckIndex = state.index - 1;
    loop:
    while (true) {
      // Check that we don't have an infinite loop
      if (state.index == infiniteLoopCheckIndex) {
        throw StateError('Infinite loop');
      }
      infiniteLoopCheckIndex = state.index;

      final c = state.current();
      if (_isWhitespace(c)) {
        _scanWhitespace(state);
        continue;
      }
      switch (c) {
        case _eof:
          return;
        case $open_parenthesis:
          state.emitTokenAndAdvance(TokenType.leftParenthesis, '(');
          continue loop;
        case $open_bracket:
          state.emitTokenAndAdvance(TokenType.leftSquareBracket, '[');
          continue loop;
        case $open_brace:
          state.emitTokenAndAdvance(TokenType.leftCurlyBracket, '{');
          continue loop;
        case $close_parenthesis:
          state.emitTokenAndAdvance(TokenType.rightParenthesis, ')');
          continue loop;
        case $close_bracket:
          state.emitTokenAndAdvance(TokenType.rightSquareBracket, ']');
          continue loop;
        case $close_brace:
          state.emitTokenAndAdvance(TokenType.rightCurlyBracket, '}');
          continue loop;
        case $ampersand:
          if (state.preview(1) == $ampersand) {
            state.emitTokenAndAdvance(TokenType.operatorAnd, '&&');
            continue loop;
          }
          break;
        case $bar:
          if (state.preview(1) == $bar) {
            state.emitTokenAndAdvance(TokenType.operatorAnd, '||');
            continue loop;
          }
          break;
        case $quote:
          _scanQuotedString(state);
          continue loop;
        case $dash:
          final c = state.preview(1);
          if (!(c >= $0 && c <= $9)) {
            state.emitTokenAndAdvance(TokenType.operatorNot, '-');
            continue loop;
          }
          break;
      }
      _scanString(state);
    }
  }

  List<Token> scanString(String s) {
    final state = ScannerState(Source(s));
    scan(state);
    return state.tokens;
  }

  bool _isOperatorType(TokenType type) {
    switch (type) {
      case TokenType.colon:
        return true;
      case TokenType.equal:
        return true;
      case TokenType.lessThan:
        return true;
      case TokenType.lessThanEqual:
        return true;
      case TokenType.greaterThan:
        return true;
      case TokenType.greaterThanEqual:
        return true;
      default:
        return false;
    }
  }

  void _scanQuotedString(ScannerState state) {
    final sb = StringBuffer();
    var infiniteLoopCheckIndex = state.index - 1;
    loop:
    while (true) {
      // Check that we don't have an infinite loop
      if (state.index == infiniteLoopCheckIndex) {
        throw StateError('Infinite loop');
      }

      infiniteLoopCheckIndex = state.index;
      final c = state.advance();
      switch (c) {
        case _eof:
          break loop;
        case $backslash:
          final c = state.advance();
          if (c != _eof) {
            sb.writeCharCode(c);
          }
          break;
        case $quote:
          break loop;
        default:
          sb.writeCharCode(c);
          break;
      }
    }
    final value = sb.toString();
    if (state.current() == $quote) {
      state.advance();
    }
    state.tokens.add(Token(TokenType.quotedString, value));
  }

  void _scanString(ScannerState state) {
    final valueStart = state.index;
    var infiniteLoopCheckIndex = state.index - 1;
    loop:
    while (true) {
      // Check that we don't have an infinite loop
      if (state.index == infiniteLoopCheckIndex) {
        throw StateError('Infinite loop');
      }
      infiniteLoopCheckIndex = state.index;

      final c = state.advance();
      if (_isWhitespace(c)) {
        break loop;
      }
      switch (c) {
        //
        // Special characters
        //
        case $colon:
          final tokens = state.tokens;
          if (tokens.isEmpty) {
            // OK
          } else if (tokens.isNotEmpty && _isOperatorType(tokens.last.type)) {
            break;
          }
          final propertyName = state.sourceString.substring(
            valueStart,
            state.index,
          );
          if (!_propertyNameRegExp.hasMatch(propertyName)) {
            break;
          }
          break loop;
        case $equal:
          final c = state.preview(1);
          if (c != _eof && !_isWhitespace(c)) {
            final tokens = state.tokens;
            if (tokens.isNotEmpty && tokens.last.type == TokenType.colon) {
              break loop;
            }
          }
          break;
        case $ampersand:
          if (state.preview(1) == $ampersand) {
            break loop;
          }
          break;
        case $bar:
          if (state.preview(1) == $bar) {
            break loop;
          }
          break;

        //
        // Characters that end the string
        //
        case _eof:
          break loop;
        case $close_parenthesis:
          break loop;
        case $close_brace:
          break loop;
        case $close_bracket:
          break loop;
      }
    }
    if (valueStart == state.index) {
      throw Error();
    }
    final value = state.sourceString.substring(
      valueStart,
      state.index,
    );
    if (value == 'AND' &&
        state.tokens.isNotEmpty &&
        state.tokens.last.type == TokenType.whitespace) {
      state.tokens.add(Token(TokenType.operatorAnd, 'AND'));
      return;
    }
    if (value == 'OR' &&
        state.tokens.isNotEmpty &&
        state.tokens.last.type == TokenType.whitespace) {
      state.tokens.add(Token(TokenType.operatorOr, 'OR'));
      return;
    }
    state.tokens.add(Token(TokenType.string, value));

    // ':'?
    if (state.current() == $colon) {
      state.emitTokenAndAdvance(TokenType.colon, ':');

      // '='
      if (state.current() == $equal) {
        state.emitTokenAndAdvance(TokenType.equal, '=');
      }

      // '>', '>='
      if (state.current() == $greater_than) {
        if (state.preview(1) == $equal) {
          state.emitTokenAndAdvance(TokenType.greaterThanEqual, '>=');
        } else {
          state.emitTokenAndAdvance(TokenType.greaterThan, '>');
        }
      }

      // '<', '<='
      if (state.current() == $less_than) {
        if (state.preview(1) == $equal) {
          state.emitTokenAndAdvance(TokenType.lessThanEqual, '<=');
        } else {
          state.emitTokenAndAdvance(TokenType.lessThan, '<');
        }
      }
    }
  }

  void _scanWhitespace(ScannerState state) {
    final start = state.index;
    while (true) {
      final c = state.advance();
      if (c == _eof || !_isWhitespace(c)) {
        state.emitTokenFrom(TokenType.whitespace, start);
        return;
      }
    }
  }

  static bool _isWhitespace(int c) {
    return (c <= $space && c >= 0) || c == 0x7F;
  }
}

class ScannerState {
  final List<Token> tokens = <Token>[];
  final String sourceString;
  int index = 0;
  final Source source;
  bool isPossibleProperty = false;

  ScannerState(this.source) : sourceString = source.value;

  int advance() {
    final value = sourceString;
    final index = this.index + 1;
    if (index >= value.length) {
      this.index = value.length;
      return _eof;
    }
    this.index = index;
    return value.codeUnitAt(index);
  }

  int current() => preview(0);

  void emitTokenAndAdvance(TokenType tokenType, String value) {
    tokens.add(Token(tokenType, value));
    index += value.length;
  }

  void emitTokenFrom(TokenType tokenType, int index) {
    tokens.add(Token(tokenType, sourceString.substring(index, this.index)));
  }

  int preview(int i) {
    final value = sourceString;
    final index = this.index + i;
    if (index >= value.length) {
      return _eof;
    }
    return value.codeUnitAt(index);
  }
}

/// Source used by [Scanner].
class Source {
  final Uri uri;
  final int line;
  final int column;
  final String value;

  const Source(
    this.value, {
    this.uri,
    this.line = 0,
    this.column = 0,
  });

  @override
  int get hashCode =>
      value.hashCode ^ uri.hashCode ^ line.hashCode ^ column.hashCode;

  @override
  bool operator ==(other) =>
      other is Source &&
      value == other.value &&
      uri == other.uri &&
      line == other.line &&
      column == other.column;

  @override
  String toString() {
    if (uri == null) {
      return value;
    }
    return '"$uri" line $line column $column: $value';
  }
}

/// A token scanned by [Scanner].
class Token {
  final TokenType type;
  final String value;

  const Token(this.type, this.value);

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  bool operator ==(other) =>
      other is Token && type == other.type && value == other.value;

  @override
  String toString() => '$type(`$value`)';
}

/// Type of a scanned [Token].
enum TokenType {
  whitespace,

  /// "abc"
  string,

  /// '"a b c"'
  quotedString,

  /// ":"
  colon,

  /// "="
  equal,

  /// "<"
  lessThan,

  /// "<="
  lessThanEqual,

  /// ">"
  greaterThan,

  /// ">="
  greaterThanEqual,

  /// "-"
  operatorNot,

  /// "&&"
  operatorAnd,

  /// "||"
  operatorOr,

  /// "("
  leftParenthesis,

  /// ")"
  rightParenthesis,

  /// "["
  leftSquareBracket,

  /// "]"
  rightSquareBracket,

  /// "{"
  leftCurlyBracket,

  /// "}"
  rightCurlyBracket,
}
