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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/filter.dart';
import 'package:search/search.dart';

/// A slightly more complex [DocumentScoring] implementation than the normal
/// one.
///
/// The main features are:
///   * [CanineTextSimplifier] is used for simplifying keywords and documents.
///   * Exact matches affect the score.
///   * Keyword sequence matches affect the score.
///   * The total number of matches affects the score.
///
/// The implementation uses [CanineTextSimplifier].
class CanineDocumentScoring extends DocumentScoring {
  final CanineTextSimplifier textSimplifier;

  const CanineDocumentScoring({
    this.textSimplifier = const CanineTextSimplifier(),
  });

  @override
  _CanineDocumentScoringState newState(Filter filter) {
    return _CanineDocumentScoringState(
      this,
      filter,
    );
  }
}

/// State for [CanineDocumentScoring].
class _CanineDocumentScoringState extends DocumentScoringStateBase {
  final Map<String, String> _normalizedKeywordMap = <String, String>{};

  /// Contains a normalized version of each string in the document.
  ///
  /// The map is cleared after document has been visited.
  final Map<String, String> _normalizedInputMap = <String, String>{};

  /// Contains a lower-case version of each string in the document.
  ///
  /// The map is cleared after document has been visited.
  final Map<String, String> _lowerCasedInputMap = <String, String>{};

  /// Scoring configuration.
  final CanineDocumentScoring scoring;

  _CanineDocumentScoringState(this.scoring, Filter filter)
      : assert(filter != null),
        super(filter);

  CanineTextSimplifier get textSimplifier => scoring.textSimplifier;

  @override
  double evaluateSnapshot(Snapshot snapshot) {
    if (filter == null) {
      return 1.0;
    }
    final score = filter.accept(this, snapshot.data);
    _normalizedInputMap.clear();
    _lowerCasedInputMap.clear();
    return score;
  }

  /// Tells whether the string is in a language that uses whitespace for
  /// separating words.
  bool languageUsesWhitespaceSeparator(String s) {
    return s.codeUnits.every((c) => c < 1024);
  }

  @override
  double visitAndFilter(AndFilter filter, Object context) {
    //
    // Goal:
    // We return sum of scores.
    //

    // Sum of all children
    var totalScore = 0.0;

    var matches = 0;
    for (final filter in filter.filters) {
      final score = filter.accept(this, context);
      totalScore += score;
      if (score > 0.0) {
        matches++;
      }
    }
    if (matches < 2) {
      return totalScore;
    }

    // Get keyword strings
    var keywords = filter.filters
        .whereType<KeywordFilter>()
        .map((f) => f.value)
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    // Try different concatenation lengths
    var concatLength = 2;
    while (true) {
      final n = keywords.length - concatLength;
      if (n < 0) {
        return totalScore;
      }
      var sum = 0.0;
      for (var i = 0; i < n; i++) {
        final joined = keywords.skip(i).take(concatLength).join(' ');
        final newKeyword = ' $joined ';
        final newFilter = KeywordFilter(newKeyword);
        sum += newFilter.accept(this, context);
      }
      if (sum == 0.0) {
        // No concatenation matched
        return totalScore;
      }

      // Update total score
      totalScore += sum;

      // Try with a longer concatenation length
      concatLength++;
    }
  }

  @override
  double visitKeywordFilter(KeywordFilter filter, Object originalInput) {
    if (originalInput is String) {
      return _calculateScore(originalInput, filter.value);
    }
    if (originalInput is Iterable) {
      var max = 0.0;
      for (var item in originalInput) {
        final r = visitKeywordFilter(filter, item);
        if (r > max) {
          max = r;
        }
      }
      return max;
    }
    if (originalInput is Map) {
      var max = 0.0;
      for (var item in originalInput.values) {
        final r = visitKeywordFilter(filter, item);
        if (r > max) {
          max = r;
        }
      }
      return max;
    }
    return 0.0;
  }

  @override
  double visitListFilter(ListFilter filter, Object context) {
    var sum = 0.0;
    final itemsFilter = filter.items;
    if (itemsFilter != null && context is List) {
      for (var item in context) {
        sum += sum += itemsFilter.accept(this, item);
      }
    }
    return sum;
  }

  @override
  double visitMapFilter(MapFilter filter, Object context) {
    var sum = 0.0;
    if (context is Map) {
      for (var entry in filter.properties.entries) {
        sum += entry.value.accept(this, context[entry.key]);
      }
    }
    return sum;
  }

  @override
  double visitOrFilter(OrFilter filter, Object context) {
    //
    // Goal:
    // We return max score.
    //

    var max = 0.0;
    for (var filter in filter.filters) {
      final score = filter.accept(this, context);
      if (score > max) {
        max = score;
      }
    }
    return max;
  }

  double _calculateScore(String originalInput, String originalKeyword) {
    if (originalKeyword.isEmpty) {
      return 1.0;
    }

    // A lot scripts (such as Chinese and Japanese) don't use whitespace
    // between words.
    //
    // We add whitespace around the keyword if all characters are latin-like.
    var keywordIsPadded = languageUsesWhitespaceSeparator(originalKeyword);
    var maybePaddedKeyword = originalKeyword;
    if (keywordIsPadded) {
      maybePaddedKeyword = ' $originalKeyword ';
    }

    //
    // Lowercase keyword
    //
    final lowerCaseKeyword = maybePaddedKeyword.toLowerCase();

    //
    // Lowercase context
    //
    final lowerCaseInput = _lowerCasedInputMap.putIfAbsent(
      originalInput,
      () => ' $originalInput '.toLowerCase(),
    );

    //
    // Normalize keyword
    //
    final keyword = _normalizedKeywordMap.putIfAbsent(
      lowerCaseKeyword,
      () => textSimplifier.transform(
        lowerCaseKeyword,
        isKeyword: true,
      ),
    );
    if (keyword.isEmpty) {
      return 1.0;
    }

    //
    // Normalize input
    //
    final context = _normalizedInputMap.putIfAbsent(
      lowerCaseInput,
      () => textSimplifier.transform(
        lowerCaseInput,
        isKeyword: true,
      ),
    );

    //
    // Count normalized substrings
    //
    const maxMatches = 3;
    final matches = _countSubstrings(
      context,
      keyword,
      max: maxMatches,
    );

    // No matches?
    if (matches == 0) {
      return 0.0;
    }

    // Declare score
    var score = 0.0;

    //
    // CRITERIA:
    // More normalized matches is better.
    // Max impact: +0.2
    //
    {
      score += 0.2 * ((matches - 1) / (maxMatches - 1)).clamp(0.0, 1.0);
    }

    //
    // CRITERIA:
    // More lowercase (non-normalized) matches is better
    // Max impact: +0.2
    //
    {
      final n = _countSubstrings(
        lowerCaseInput,
        lowerCaseKeyword,
        max: maxMatches,
      );
      if (maybePaddedKeyword != lowerCaseKeyword) {
        score += 0.2 * (n / maxMatches).clamp(0.0, 1.0);
      }
    }

    //
    // CRITERIA:
    // Matches of longer keywords give higher score.
    // Max impact: +0.4
    //
    // The first 8 code points raise score by max 0.3/8.
    // Subsequent 24 code points raise score by max 24/8.
    {
      const upperBound0 = 8;

      // For first 8 - 32 code points, each raises score only by 0.1/23.
      const upperBound1 = 24;

      final length = originalKeyword.trim().length;
      score += 0.3 * (length / upperBound0).clamp(0.0, 1.0);
      score += 0.1 * ((length - upperBound0) / upperBound1).clamp(0.0, 1.0);
    }

    // We add constant 1.0 for legacy reasons.
    return 1.0 + score.clamp(0.0, 1.0);
  }

  static int _countSubstrings(String context, String substring,
      {int max = -1}) {
    if (context.isEmpty || substring.isEmpty) {
      return 0;
    }
    var start = 0;
    var count = 0;
    final substringLength = substring.length;
    while (true) {
      final i = context.indexOf(substring, start);
      if (i < 0) {
        break;
      }
      count++;
      if (max > 0 && count == max) {
        break;
      }
      start = i + substringLength;
    }
    return count;
  }
}
