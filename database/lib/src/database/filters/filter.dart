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

import 'package:database/database.dart';
import 'package:database/search_query_parsing.dart';

/// Describes how to score possible matches.
abstract class Filter {
  const Filter();

  /// Returns all children/.
  Iterable<Filter> get children sync* {}

  /// Returns all descendants.
  Iterable<Filter> get descendants sync* {
    for (var child in children) {
      yield (child);
      yield* (child.descendants);
    }
  }

  /// Calls the relevant visit method in [visitor].
  T accept<T, C>(FilterVisitor<T, C> visitor, C context);

  /// Simplifies the AST tree. For example, nested AND nodes are transformed
  /// into a single AND node.
  Filter simplify() => this;

  /// Returns a string built with [SearchQueryPrinter].
  @override
  String toString() {
    final b = SearchQueryPrinter();
    accept(b, null);
    return b.toString();
  }
}
