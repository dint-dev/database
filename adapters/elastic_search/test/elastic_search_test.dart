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

import 'package:database_adapter_elastic_search/database_adapter_elastic_search.dart';

import 'copy_of_database_test_suite.dart';

void main() async {
  final newDatabase = () async {
    final database = ElasticSearch(
      host: 'localhost',
      port: 9200,
    );
    try {
      await database.checkHealth(timeout: const Duration(milliseconds: 500));
    } catch (error) {
      print(
        'ElasticSearch is not running at port 9200.\nTo run it with Docker, use script: ./tool/elastic_search/docker_run.sh',
      );
      return null;
    }
    ;
    return database;
  };

  DatabaseTestSuite(newDatabase).run();
}
