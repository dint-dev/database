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

import 'package:database_adapter_postgre/database_adapter_postgre.dart';

import 'copy_of_database_adapter_tester.dart';

void main() {
  // To start PostgreSQL in a Docker container, run:
  //   ./tool/docker_run.sh

  final tester = SqlDatabaseAdapterTester(() {
    return Postgre(
      host: 'localhost',
      port: 5432,
      user: 'database_test_user',
      password: 'database_test_password',
      databaseName: 'test',
    );
  });

  tester.run();
}
