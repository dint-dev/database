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

import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:meta/meta.dart';

/// Describes a snippet of the document in [QueryResultItem].
class Snippet {
  /// Text of the snippet.
  final String text;

  /// Optional highlighted spans.
  final List<SnippetSpan> highlightedSpans;

  /// Optional line number. The first line has index 1.
  final int line;

  Snippet(
    this.text, {
    this.highlightedSpans = const <SnippetSpan>[],
    this.line,
  });

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(other) =>
      other is Snippet &&
      text == other.text &&
      const ListEquality().equals(highlightedSpans, other.highlightedSpans) &&
      line == other.line;
}

/// Describes a span in a [Snippet].
class SnippetSpan {
  /// Start of the span.
  final int start;

  /// Length of the span.
  final int length;

  SnippetSpan({
    @required this.start,
    @required this.length,
  });

  @override
  int get hashCode => start.hashCode ^ length.hashCode;

  @override
  bool operator ==(other) =>
      other is SnippetSpan && start == other.start && length == other.length;
}
