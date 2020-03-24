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
import 'package:database/database_adapter.dart';
import 'package:database/filter.dart';

@deprecated
class DocumentScoringAlgorithmBase extends DocumentScoringStateBase {
  DocumentScoringAlgorithmBase(Filter filter) : super(filter);
}

/// Default implementation of [DocumentScoringState].
///
/// Features:
///   * [AndFilter] returns 1.0 if all filter match.
///   * [OrFilter] returns 1.0 if any filter matches.
///   * [GeoPoint] returns 1.0 if any [GeoPoint] in the document is within the
///     specified geographical radius.
///   * [KeywordFilter] returns 1.0 if any string in the document contains the
///     keyword.
class DocumentScoringStateBase extends DocumentScoringState
    implements FilterVisitor<double, Object> {
  static const _deepEquality = DeepCollectionEquality();

  final Filter filter;

  DocumentScoringStateBase(this.filter);

  @override
  double evaluateSnapshot(Snapshot snapshot) {
    if (filter == null) {
      return 1.0;
    }
    return filter.accept(this, snapshot.data);
  }

  @override
  double visitAndFilter(AndFilter filter, Object input) {
    for (final filter in filter.filters) {
      final score = filter.accept(this, input);
      if (score == 0.0) {
        return 0.0;
      }
    }
    return 1.0;
  }

  @override
  double visitGeoPointFilter(GeoPointFilter filter, Object input) {
    if (input is GeoPoint) {
      final max = filter.maxDistanceInMeters;
      if (max is num) {
        final distance = filter.near.distanceTo(input);
        if (distance < max.toDouble()) {
          return 1.0;
        }
      }
      return 0.0;
    }
    if (input is Iterable) {
      for (var item in input) {
        final r = visitGeoPointFilter(filter, item);
        if (r != 0.0) {
          return 1.0;
        }
      }
      return 0.0;
    }

    if (input is Map) {
      for (var item in input.values) {
        final r = visitGeoPointFilter(filter, item);
        if (r != 0.0) {
          return 1.0;
        }
      }
      return 0.0;
    }

    return 0.0;
  }

  @override
  double visitKeywordFilter(KeywordFilter filter, Object input) {
    if (input is String) {
      return input.contains(filter.value) ? 1.0 : 0.0;
    }

    if (input is Iterable) {
      for (var item in input) {
        final r = visitKeywordFilter(filter, item);
        if (r != 0.0) {
          return 1.0;
        }
      }
      return 0.0;
    }

    if (input is Map) {
      for (var item in input.values) {
        final r = visitKeywordFilter(filter, item);
        if (r != 0.0) {
          return 1.0;
        }
      }
      return 0.0;
    }
    return 0.0;
  }

  @override
  double visitListFilter(ListFilter filter, Object context) {
    return filter.items?.accept(this, context) ?? 1.0;
  }

  @override
  double visitMapFilter(MapFilter filter, Object input) {
    if (input is Map) {
      var sumScore = 0.0;
      for (var entry in filter.properties.entries) {
        final name = entry.key;
        final value = input[name];
        final propertyScore = entry.value.accept(this, value);
        if (propertyScore == 0.0) {
          return 0.0;
        }
        sumScore += propertyScore;
      }
      return sumScore;
    }
    return 0.0;
  }

  @override
  double visitNotFilter(NotFilter filter, Object input) {
    final isMatch = filter.filter.accept(this, input);
    return isMatch == 0.0 ? 1.0 : 0.0;
  }

  @override
  double visitOrFilter(OrFilter filter, Object input) {
    for (final filter in filter.filters) {
      final score = filter.accept(this, input);
      if (score != 0.0) {
        return 1.0;
      }
    }
    return 0.0;
  }

  @override
  double visitRangeFilter(RangeFilter filter, Object input) {
    {
      final min = filter.min;
      if (min != null) {
        final r = defaultComparator(input, min);
        if (filter.isExclusiveMin) {
          if (r <= 0) {
            return 0.0;
          }
        } else {
          if (r < 0) {
            return 0.0;
          }
        }
      }
    }
    {
      final max = filter.max;
      if (max != null) {
        final r = defaultComparator(input, max);
        if (filter.isExclusiveMax) {
          if (r >= 0) {
            return 0.0;
          }
        } else {
          if (r > 0) {
            return 0.0;
          }
        }
      }
    }
    return 1.0;
  }

  @override
  double visitRegExpFilter(RegExpFilter filter, Object input) {
    if (input is String) {
      return filter.regExp.hasMatch(input) ? 1.0 : 0.0;
    }
    if (input is List) {
      for (var item in input) {
        final r = visitRegExpFilter(filter, item);
        if (r != 0.0) {
          return 1.0;
        }
      }
      return 0.0;
    }
    if (input is Map) {
      for (var item in input.values) {
        final r = visitRegExpFilter(filter, item);
        if (r != 0.0) {
          return 1.0;
        }
      }
      return 0.0;
    }
    return 0.0;
  }

  @override
  double visitSqlFilter(SqlFilter filter, Object context) {
    return 0.0;
  }

  @override
  double visitValueFilter(ValueFilter filter, Object context) {
    return _deepEquality.equals(filter.value, context) ? 1.0 : 0.0;
  }
}
