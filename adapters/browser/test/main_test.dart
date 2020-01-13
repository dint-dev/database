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

import 'package:database_adapters/database_adapter_browser.dart';
import 'package:test/test.dart';
import 'package:universal_html/html.dart' as html;

import 'copy_of_database_test_suite.dart';

void main() {
  group('BrowserDatabase:', () {
    tearDown(() {
      html.window.localStorage.clear();
    });
    DatabaseTestSuite(() => BrowserDatabase()).run();
  });

  group('BrowserLocalStorage:', () {
    tearDown(() {
      html.window.localStorage.clear();
    });
    DatabaseTestSuite(() => BrowserLocalStorageDatabase()).run();
  });
}
