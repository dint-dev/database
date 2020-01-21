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

import 'package:database_adapter_azure/cosmos_db.dart';
import 'package:test_io/test_io.dart';

import 'copy_of_database_adapter_tester.dart';

Future<void> main() async {
  final newDatabase = () async {
    final env = await getEnvironmentalVariables();
    const idEnv = 'TEST_AZURE_COSMOS_DB_SEARCH_ID';
    const secretEnv = 'TEST_AZURE_COSMOS_DB_SEARCH_SECRET';
    final id = env[idEnv] ?? '';
    final secret = env[secretEnv] ?? '';
    if (id == '' || secret == '') {
      print(
        'SKIPPING: Azure Cosmos DB: environmental variables $idEnv / $secretEnv are undefined.',
      );
      return null;
    }
    return AzureCosmosDB(
      credentials: AzureCosmosDBCredentials(
        serviceId: id,
        apiKey: secret,
      ),
    ).database();
  };

  DatabaseAdapterTester(newDatabase).run();
}
