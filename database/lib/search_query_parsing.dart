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

/// Parses a search query language which is very similar to
/// [Lucene query language](https://lucene.apache.org/core/6_6_2/queryparser/org/apache/lucene/queryparser/classic/package-summary.html).
///
/// Examples of supported queries:
///   * `Norwegian Forest cat`
///     * Matches keywords "Norwegian", "Forest", and "cat".
///   * `"Norwegian Forest cat"`
///     * A quoted keyword ensures that the words must appear as a sequence.
///   * `color:brown`
///     * Color matches keyword "brown".
///
/// For more details, see [SearchQueryParser].
///
library database.search_query_parsing;

import 'src/search_query_parsing/parser.dart';

export 'src/search_query_parsing/parser.dart';
export 'src/search_query_parsing/printer.dart';
export 'src/search_query_parsing/scanner.dart';
