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

import 'package:database_adapter_firestore_browser/database_adapter_firestore_browser.dart';
import 'package:test_io/test_io.dart';

import 'copy_of_database_adapter_tester.dart';

Future<void> main() async {
  final tester = DatabaseAdapterTester(() async {
    final env = await getEnvironmentalVariables();
    const idEnv = 'TEST_GOOGLE_FIREBASE_ID';
    const secretEnv = 'TEST_GOOGLE_FIREBASE_SECRET';
    final id = env[idEnv] ?? '';
    final secret = env[secretEnv] ?? '';
    if (id == '' || secret == '') {
      print('  "firebase_browser" tests are skipped.');
      print(
          '  If you want to run the tests, define the environmental variables:');
      print('    * $idEnv');
      print('    * $secretEnv');
      return null;
    }
    return FirestoreBrowser.initialize(
      appId: id,
      apiKey: secret,
      projectId: id,
    ).database();
  });
  tester.run();
}
