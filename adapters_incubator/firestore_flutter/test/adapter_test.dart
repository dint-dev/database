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

import 'dart:io';

import 'package:database_adapter_firestore_flutter/adapter.dart';

import 'copy_of_database_test_suite.dart';

void main() {
  final newDatabase = () async {
    const idEnv = 'TEST_GOOGLE_FIRESTORE_ID';
    const secretEnv = 'TEST_GOOGLE_FIRESTORE_SECRET';
    final id = Platform.environment[idEnv] ?? '';
    final secret = Platform.environment[secretEnv] ?? '';
    if (id == '' || secret == '') {
      print(
        'SKIPPING: Google Cloud Firestore: environmental variables $idEnv / $secretEnv are undefined.',
      );
      return null;
    }
    return FirestoreFlutter(
      appId: id,
      apiKey: secret,
    );
  };
  return DatabaseTestSuite(newDatabase).run();
}
