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

import 'package:datastore/adapters_framework.dart';
import 'package:meta/meta.dart';

import 'google_cloud_firestore_impl_vm.dart'
    if (dart.library.html) 'google_cloud_firestore_impl_browser.dart';

/// An adapter for using [Firestore](https://firebase.google.com/docs/firestore),
/// a commercial cloud service by Google.
///
/// An example:
/// ```
/// import 'package:datastore/adapters.dart';
/// import 'package:datastore/datastore.dart';
///
/// void main() {
///   Datastore.freezeDefaultInstance(
///     GoogleCloudDatastore(
///       appId: 'APP ID',
///       apiKey: 'API KEY',
///     ),
///   );
///   // ...
/// }
/// ```
abstract class Firestore extends DatastoreAdapter {
  factory Firestore({
    @required String apiKey,
    @required String appId,
  }) {
    return FirestoreImpl(apiKey: apiKey, appId: appId);
  }
}
