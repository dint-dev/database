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

import 'dart:io';

import 'package:database_adapter_postgre/database_adapter_postgre.dart';
import 'package:test/test.dart';

import 'copy_of_database_adapter_tester.dart';

void main() {
  // To start PostgreSQL in a Docker container, run:
  //   ./tool/docker_run.sh

  var dockerCommandExists = false;
  const dockerId = 'some-postgres';
  Process dockerProcess;

  setUpAll(() async {
    try {
      // Remove possible previous instance
      Process.runSync('docker', ['docker', 'stop', dockerId]);
      Process.runSync('docker', ['docker', 'rm', dockerId]);

      // Wait 500 ms
      await Future.delayed(const Duration(milliseconds: 500));

      dockerProcess = await Process.start('docker', [
        'run',
        '--name',
        dockerId,
        '-p',
        '5432:5432',
        '-e',
        'POSTGRES_USER=database_test_user',
        '-e',
        'POSTGRES_PASSWORD=database_test_password',
        '-e',
        'POSTGRES_DB=test',
        '-d',
        'postgres'
      ]);
    } catch (error) {
      print('Starting Docker failed: $error');
      return;
    }
    dockerCommandExists = true;

    // ignore: unawaited_futures
    dockerProcess.exitCode.whenComplete(() {
      dockerProcess = null;
    });
    addTearDown(() {
      dockerProcess?.kill();
    });

    // ignore: unawaited_futures
    dockerProcess.stderr.listen((data) {
      stdout.add(data);
    });
    // ignore: unawaited_futures
    dockerProcess.stdout.listen((data) {
      stderr.add(data);
    });

    // Wait 500 ms
    await Future.delayed(const Duration(milliseconds: 500));
  });

  tearDownAll(() {
    if (dockerCommandExists) {
      Process.runSync('docker', ['docker', 'stop', dockerId]);
      Process.runSync('docker', ['docker', 'rm', dockerId]);
    }
  });

  final tester = SqlDatabaseAdapterTester(() {
    if (dockerProcess == null) {
      print('  Skipping tests because of a Docker failure.');
      return null;
    }
    return Postgre(
      host: 'localhost',
      port: 5432,
      user: 'database_test_user',
      password: 'database_test_password',
      databaseName: 'test',
    ).database();
  });

  tester.run();
}
