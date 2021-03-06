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
import 'package:database/filter.dart';

/// A filter that contains an SQL query.
///
/// ```
/// import 'package:database/filters.dart';
///
/// final filter = SqlFilter('price BETWEEN 0 AND ?', [maxPrice]);
/// final results = await database.collection('product').query(
///   query: Query(
///     filter: filter,
///   ),
/// );
/// ```
class SqlFilter extends Filter {
  /// SQL expression. Arguments should be replaced with '?'.
  final String source;

  /// Arguments for [source].
  final List arguments;

  const SqlFilter(this.source, this.arguments)
      : assert(source != null),
        assert(arguments != null);

  @override
  int get hashCode => source.hashCode ^ const ListEquality().hash(arguments);

  @override
  bool operator ==(other) =>
      other is SqlFilter &&
      source == other.source &&
      ListEquality().equals(arguments, other.arguments);

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitSqlFilter(this, context);
  }
}
