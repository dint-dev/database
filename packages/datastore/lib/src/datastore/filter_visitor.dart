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

/// Visits [Filter] trees.
abstract class FilterVisitor<T, C> {
  const FilterVisitor();
  T visitAndFilter(AndFilter filter, C context);
  T visitGeoPointFilter(GeoPointFilter filter, C context);
  T visitKeywordFilter(KeywordFilter filter, C context);
  T visitListFilter(ListFilter filter, C context);
  T visitMapFilter(MapFilter filter, C context);
  T visitNotFilter(NotFilter filter, C context);
  T visitOrFilter(OrFilter filter, C context);
  T visitRangeFilter(RangeFilter filter, C context);
  T visitRegExpFilter(RegExpFilter filter, C context);
  T visitValueFilter(ValueFilter filter, C context);
}

/// Visits [Filter] trees. Every visitor method has a default implementation
/// that calls [visitFilter].
abstract class GeneralizingFilterVisitor<T, C> extends FilterVisitor<T, C> {
  const GeneralizingFilterVisitor();

  @override
  T visitAndFilter(AndFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  T visitFilter(Filter filter, C context);

  @override
  T visitGeoPointFilter(GeoPointFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  @override
  T visitKeywordFilter(KeywordFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  @override
  T visitListFilter(ListFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  @override
  T visitMapFilter(MapFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  @override
  T visitNotFilter(NotFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  @override
  T visitOrFilter(OrFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  @override
  T visitRangeFilter(RangeFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }

  @override
  T visitRegExpFilter(RegExpFilter filter, C context) {
    return visitFilter(
      filter,
      context,
    );
  }
}
