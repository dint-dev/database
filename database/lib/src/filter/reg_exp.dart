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

/// A regular expression matching filter.
///
/// ```
/// import 'package:database/filters.dart';
///
/// final filter = RegExpFilter(RegExp('[a-z]+'));
/// ```
class RegExpFilter extends Filter {
  final RegExp regExp;

  RegExpFilter(this.regExp) {
    if (regExp == null) {
      throw ArgumentError.notNull();
    }
  }

  @override
  int get hashCode => regExp.pattern.hashCode;

  @override
  bool operator ==(other) =>
      other is RegExpFilter && regExp.pattern == other.regExp.pattern;

  @override
  T accept<T, C>(FilterVisitor<T, C> visitor, C context) {
    return visitor.visitRegExpFilter(this, context);
  }
}
