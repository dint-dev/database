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
import 'package:test/test.dart';

void main() {
  group('MultiSorter:', () {
    test('"==" / hashCode', () {
      final value = MultiSorter([PropertySorter('p')]);
      final clone = MultiSorter([PropertySorter('p')]);
      final other = MultiSorter([PropertySorter('other')]);
      expect(value, clone);
      expect(value, isNot(other));
      expect(value.hashCode, clone.hashCode);
      expect(value.hashCode, isNot(other.hashCode));
    });
  });

  group('PropertySorter:', () {
    test('"==" / hashCode', () {
      final value = PropertySorter('p');
      final clone = PropertySorter('p');
      final other0 = PropertySorter('other');
      final other1 = PropertySorter.descending('p');
      expect(value, clone);
      expect(value, isNot(other0));
      expect(value, isNot(other1));
      expect(value.hashCode, clone.hashCode);
      expect(value.hashCode, isNot(other0.hashCode));
      expect(value.hashCode, isNot(other1.hashCode));
    });
  });
}
