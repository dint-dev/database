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

import 'package:collection/collection.dart';
import 'package:datastore/datastore.dart';

int defaultComparator(Object left, Object right) {
  if (left == right) {
    return 0;
  }

  // null
  if (left == null) {
    return -1;
  }
  if (right == null) {
    return 1;
  }

  // bool
  if (left is bool) {
    if (right is bool) {
      return left == false ? -1 : 1;
    }
    return -1;
  }
  if (right is bool) {
    return 1;
  }

  // int
  if (left is num) {
    if (right is num) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is num) {
    return 1;
  }

  // DateTime
  if (left is DateTime) {
    if (right is DateTime) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is DateTime) {
    return 1;
  }

  // String
  if (left is String) {
    if (right is String) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is String) {
    return 1;
  }

  // Default
  return -1;
}

/// Assesses how well documents match a filter. The choice of algorithm only
/// affects queries with non-exact filters such as natural language keywords.
class DocumentScoring {
  const DocumentScoring();

  DocumentScoringState newState(Filter filter) {
    return DocumentScoringAlgorithmBase(filter);
  }
}

/// Default implementation of [DocumentScoring].
class DocumentScoringAlgorithmBase extends DocumentScoringState
    implements FilterVisitor<double, Object> {
  static const _deepEquality = DeepCollectionEquality();

  final Filter filter;

  DocumentScoringAlgorithmBase(this.filter);

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
    // TODO: Implementation
    return 1.0;
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
  double visitValueFilter(ValueFilter filter, Object context) {
    return _deepEquality.equals(filter.value, context) ? 1.0 : 0.0;
  }
}

/// State constructed by [DocumentScoring] for each query.
abstract class DocumentScoringState {
  /// Returns a positive number if the document snapshot matches the filter.
  /// Otherwise returns 0.0.
  double evaluateSnapshot(Snapshot snapshot);
}
