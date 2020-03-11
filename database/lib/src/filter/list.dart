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

import 'package:database/filter.dart';

/// A filter for lists.
class ListFilter extends Filter {
  final Filter items;

  const ListFilter({this.items});

  @override
  Iterable<Filter> get children sync* {
    yield (items);
  }

  @override
  int get hashCode => items.hashCode;

  @override
  bool operator ==(other) => other is ListFilter && items == other.items;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitListFilter(this, context);
  }
}
