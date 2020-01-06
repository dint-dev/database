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

import 'package:charcode/ascii.dart';

/// Simplifies the text for the first stage of substring search.
///
/// Examples:
///   * "Élysée" --> " elysee "
///   * "Joe's coffee" --> " joe coffee "
///   * "hello,\n  world" --> " hello world "
///
/// The supported transformations are:
///   * Replaces uppercase characters with lowercase characters.
///   * Replaces certain extended latin characters with ASCII characters.
///     * Enables people to search without writing special characters like "í".
///     * Exact matches can be still prioritized in later stages of the search.
///   * Replaces special characters (",", etc.) and some word suffixes ("'s",
///     etc.) with whitespace.
///     * We don't care about punctuation, etc.
///   * Replaces consecutive whitespace characters with a single space
///     character.
///   * Ensures that the text starts and ends with a space.
class CanineTextSimplifier {
  /// Special rules for some non-ASCII characters.
  static const Map<String, String> _mappedRunes = {
    //
    // Vowels
    //
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'å': 'a',

    'é': 'e',
    'è': 'e',
    'ë': 'e',

    'í': 'i',
    'ì': 'i',

    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',

    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'ů': 'u',

    'ý': 'y',

    //
    // Consonants
    //
    'ç': 'c',
    'č': 'c',
    'ď': 'd',
    'ň': 'n',
    'ř': 'r',
    'ß': 'ss',
    'ž': 'z',

    //
    // Special characters
    //
    '¿': '',
    '¡': '',
  };

  const CanineTextSimplifier();

  String transform(String s, {bool isKeyword = false}) {
    // A special case
    if (s.isEmpty) {
      return '';
    }

    // We may add a space before and after the string.
    //
    // We don't do this if the argument is a keyword and some characters are not
    // latin-like. This is because in some languages words are not separated by
    // spaces.
    //
    final padded = !isKeyword || s.runes.every((r) => r < 1024);

    final sb = StringBuffer();
    if (padded) {
      sb.write(' ');
    }

    var previousIsWhitespace = true;
    for (var i = 0; i < s.length; i++) {
      var substring = s.substring(i, i + 1);
      final c = substring.codeUnitAt(0);

      if (c < 0x80) {
        //
        // ASCII
        //
        if ((c >= $a && c <= $z) ||
            (c >= $0 && c <= $9) ||
            c == $_ ||
            c == $dollar ||
            c == $hash) {
          //
          // One of the following:
          //   * A lowercase letter
          //   * A digit
          //   * '_'
          //   * '$'
          //   * '#'
          //
          sb.write(substring);
          previousIsWhitespace = false;
          continue;
        } else if (c >= $A && c <= $Z) {
          //
          // An upper-case letter
          //
          // We just convert it to lower-case.
          sb.write(substring.toLowerCase());
          previousIsWhitespace = false;
          continue;
        } else {
          //
          // Something else.
          // Replaced with a space.
          //
          // The exception is "'", which can be part of word in languages such
          // as English.
          //
          if (previousIsWhitespace) {
            continue;
          } else if (substring == "'" && _wordHasSuffix(s, 's', i + 1)) {
            // "joe's" --> "joe"
            i += 1;
            continue;
          }
          sb.write(' ');
          previousIsWhitespace = true;
          continue;
        }
      }

      //
      // Non-ASCII
      //
      substring = substring.toLowerCase();
      final mapped = _mappedRunes[substring];
      if (mapped != null) {
        substring = mapped;
      }
      previousIsWhitespace = false;
      sb.write(mapped);
      continue;
    }
    if (padded && !previousIsWhitespace) {
      sb.write(' ');
    }

    // Produce string
    return sb.toString();
  }

  static bool _wordHasSuffix(String s, String substring, int i) {
    if (!s.startsWith(substring, i)) {
      return false;
    }
    final end = i + substring.length;
    if (end == s.length) {
      return true;
    }
    final c = s.codeUnitAt(end);
    return c <= $space || c == $close_parenthesis || c == $dot || c == $comma;
  }
}
