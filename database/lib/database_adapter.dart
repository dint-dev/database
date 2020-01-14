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

/// Classes used by database adapters.
///
/// Import:
/// ```
/// import 'package:database/database_adapter.dart';
/// ```
library database.adapter;

export 'src/database_adapter/database_adapter.dart';
export 'src/database_adapter/default_comparator.dart';
export 'src/database_adapter/delegating_database_adapter.dart';
export 'src/database_adapter/document_scoring.dart';
export 'src/database_adapter/read_only_database_adapter_mixin.dart';
export 'src/database_adapter/requests/extension_request.dart';
export 'src/database_adapter/requests/read_request.dart';
export 'src/database_adapter/requests/search_request.dart';
export 'src/database_adapter/requests/write_request.dart';
