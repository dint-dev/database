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

/// Adapters for various document databases.
library datastore.adapters;

export 'src/adapters/algolia.dart';
export 'src/adapters/azure_cognitive_search.dart';
export 'src/adapters/azure_cosmos_db.dart';
export 'src/adapters/browser_datastore.dart';
export 'src/adapters/caching_datastore.dart';
export 'src/adapters/elastic_search.dart';
export 'src/adapters/google_cloud_datastore.dart';
export 'src/adapters/google_cloud_firestore.dart';
export 'src/adapters/grpc_datastore.dart';
export 'src/adapters/grpc_datastore_server.dart';
export 'src/adapters/memory_datastore.dart';
