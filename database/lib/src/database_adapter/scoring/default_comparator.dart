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

import 'dart:typed_data';

import 'package:database/database.dart';
import 'package:fixnum/fixnum.dart';

/// Compares any support primitives.
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

  // Int64
  if (left is Int64) {
    if (right is Int64) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is Int64) {
    return 1;
  }

  // int / double
  if (left is num) {
    if (right is num) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is num) {
    return 1;
  }

  // Date
  if (left is Date) {
    if (right is Date) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is Date) {
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

  // Timestamp
  if (left is Timestamp) {
    if (right is Timestamp) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is Timestamp) {
    return 1;
  }

  // GeoPoint
  if (left is GeoPoint) {
    if (right is GeoPoint) {
      return left.compareTo(right);
    }
    return -1;
  }
  if (right is GeoPoint) {
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

  if (left is Uint8List) {
    if (right is Uint8List) {
      final leftLength = left.length;
      final rightLength = right.length;
      final minLength = leftLength < rightLength ? leftLength : rightLength;
      for (var i = 0; i < minLength; i++) {
        final r = left[i].compareTo(right[i]);
        if (r != 0) {
          return r;
        }
      }
      return leftLength.compareTo(rightLength);
    }
  }
  if (right is Uint8List) {
    return 1;
  }

  // Default
  return -1;
}
