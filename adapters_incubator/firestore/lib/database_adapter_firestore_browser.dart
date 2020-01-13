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

/// A browser-only adapter for using [Firestore](https://firebase.google.com/docs/firestore),
/// a commercial cloud service by Google.
library database_adapter_firestore;

import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

import 'src/google_cloud_firestore_impl_vm.dart'
    if (dart.library.html) 'src/google_cloud_firestore_impl_browser.dart';

/// An browser-only adapter for using [Firestore](https://firebase.google.com/docs/firestore),
/// a commercial cloud service by Google.
///
/// An example:
/// ```
/// import 'package:database/adapters.dart';
/// import 'package:database/database.dart';
///
/// void main() {
///   Database.freezeDefaultInstance(
///     GoogleCloudDatastore(
///       appId: 'APP ID',
///       apiKey: 'API KEY',
///     ),
///   );
///   // ...
/// }
/// ```
abstract class Firestore extends DatabaseAdapter {
  factory Firestore({
    @required String apiKey,
    @required String appId,
  }) {
    return FirestoreImpl(
      apiKey: apiKey,
      appId: appId,
    );
  }
}
