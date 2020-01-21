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
import 'package:meta/meta.dart';

/// Sorts values according to multiple criteria.
@sealed
class MultiSorter extends Sorter {
  final List<Sorter> sorters;

  const MultiSorter(this.sorters);

  @override
  int get hashCode => const ListEquality<Sorter>().hash(sorters);

  @override
  bool operator ==(other) =>
      other is MultiSorter &&
      const ListEquality<Sorter>().equals(sorters, other.sorters);

  @override
  int compare(Object left, Object right, {Comparator comparator}) {
    for (var sorter in sorters) {
      final result = sorter.compare(left, right, comparator: comparator);
      if (result != 0) {
        return result;
      }
    }
    return 0;
  }

  @override
  Sorter simplify() {
    var oldSorters = sorters;
    if (oldSorters.isEmpty) {
      return null;
    }
    if (oldSorters.length == 1) {
      return oldSorters.single.simplify();
    }
    List<Sorter> newSorters;
    for (var i = 0; i < oldSorters.length; i++) {
      final oldSorter = oldSorters[i];
      final newSorter = oldSorter.simplify();
      if (!identical(newSorter, oldSorter) || newSorter is MultiSorter) {
        if (newSorters == null) {
          newSorters = <Sorter>[];
          newSorters.addAll(oldSorters.take(i));
        }
        if (newSorter == null) {
          // Ignore
        } else if (newSorter is MultiSorter) {
          newSorters.addAll(newSorter.sorters);
        } else {
          newSorters.add(newSorter);
        }
      }
    }
    if (newSorters == null) {
      return this;
    }
    if (newSorters.isEmpty) {
      return null;
    }
    return MultiSorter(
      List<Sorter>.unmodifiable(newSorters),
    );
  }

  @override
  String toString() => sorters.join(', ');
}

/// Sorts values according to value of a map property.
@sealed
class PropertySorter extends Sorter {
  final String name;
  final bool isDescending;

  const PropertySorter(this.name, {this.isDescending = false});
  const PropertySorter.descending(String name) : this(name, isDescending: true);

  @override
  int get hashCode => name.hashCode ^ isDescending.hashCode;

  @override
  bool operator ==(other) =>
      other is PropertySorter &&
      name == other.name &&
      isDescending == other.isDescending;

  @override
  int compare(Object left, Object right, {Comparator comparator}) {
    if (left is Map<String, Object>) {
      if (right is Map<String, Object>) {
        final leftValue = left[name];
        final rightValue = right[name];
        comparator ??= defaultComparator;
        final result = comparator(leftValue, rightValue);
        return isDescending ? -result : result;
      }
    }
    return -2;
  }

  @override
  String toString() => '${isDescending ? '>' : '<'} $name';
}

/// Sorts values.
abstract class Sorter {
  const Sorter();

  int compare(Object left, Object right, {Comparator comparator});

  int compareSnapshot(
    Snapshot left,
    Snapshot right, {
    Comparator comparator,
  }) {
    return compare(left.data, right.data, comparator: comparator);
  }

  Sorter simplify() => this;
}
