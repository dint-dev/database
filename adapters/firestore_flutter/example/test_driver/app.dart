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

import 'dart:async';

import 'package:database_adapter_firestore_flutter/database_adapter_firestore_flutter.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'copy_of_database_adapter_tester.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(
    handler: (_) {
      return completer.future;
    },
  );
  tearDownAll(() {
    completer.complete(null);
  });

  final tester = DatabaseAdapterTester(() => FirestoreFlutter());
  tester.run();
}
