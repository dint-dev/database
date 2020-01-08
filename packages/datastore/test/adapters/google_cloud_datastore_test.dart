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

@TestOn('vm')
library _;

import 'package:datastore/adapters.dart';
import 'package:test_io/test_io.dart';
import 'package:test/test.dart';

import '../datastore_test_suite.dart';

Future<void> main() async {
  final newDatastore = () async {
    final env = await getEnvironmentalVariables();
    const idEnv = 'TEST_GOOGLE_DATASTORE_ID';
    const secretEnv = 'TEST_GOOGLE_DATASTORE_SECRET';
    final id = env[idEnv] ?? '';
    final secret = env[secretEnv] ?? '';
    if (id == '' || secret == '') {
      print(
        'SKIPPING: Google Cloud Datastore: environmental variables $idEnv / $secretEnv are undefined.',
      );
      return null;
    }
    return GoogleCloudDatastoreDatastore.withApiKey(
      apiKey: secret,
      projectId: id,
    );
  };

  DatastoreTestSuite(newDatastore).run();
}
