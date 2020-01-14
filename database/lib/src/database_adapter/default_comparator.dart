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
