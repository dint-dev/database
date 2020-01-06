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

@TestOn('vm || browser')
library _;

import 'package:datastore/adapters.dart';
import 'package:datastore/datastore.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

void main() {
  test('basic usage', () async {
    final serviceId = Platform.environment[serviceIdVar];
    final apiKey = Platform.environment[apiKeyVar];
    if (serviceId == null || apiKey == null) {
      print(
        'Skipping test: Environmental variables $serviceIdVar / $apiKeyVar are undefined.',
      );
      return;
    }

    Datastore.defaultInstance = Algolia(
      credentials: AlgoliaCredentials(
        appId: serviceId,
        apiKey: apiKey,
      ),
    );

    final collection = Datastore.defaultInstance.collection(
      'exampleCollection',
    );
    addTearDown(() async {
      await collection.searchAndDelete();
    });
    final document = collection.document('exampleDocument');

    // Read non-existing
    {
      final snapshot = await document.get();
      expect(snapshot, isNull);
    }

    // Insert
    await document.insert(data: {
      'k0': 'v0',
      'k1': 'v1',
    });

    // Read
    {
      final snapshot = await document.get();
      expect(snapshot.data, {
        'k0': 'v0',
        'k1': 'v1',
      });
    }

    // Search
    {
      final response = await collection.search();
      expect(response.snapshots, hasLength(1));
    }

    // Delete
    await document.deleteIfExists();

    // Read non-existing
    {
      final snapshot = await document.get();
      expect(snapshot, isNull);
    }
  });
}

const apiKeyVar = 'ALGOLIA_API_KEY';

const serviceIdVar = 'ALGOLIA_SERVICE_ID';
