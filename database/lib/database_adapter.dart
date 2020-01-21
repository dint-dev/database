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

/// Classes used by database adapters.
///
/// Import:
/// ```
/// import 'package:database/database_adapter.dart';
/// ```
library database.adapter;

export 'src/database_adapter/database_adapter.dart';
export 'src/database_adapter/delegating_database_adapter.dart';
export 'src/database_adapter/document_database_adapter.dart';
export 'src/database_adapter/read_only_database_adapter_mixin.dart';
export 'src/database_adapter/requests/document_batch_request.dart';
export 'src/database_adapter/requests/document_delete_by_search_request.dart';
export 'src/database_adapter/requests/document_delete_request.dart';
export 'src/database_adapter/requests/document_insert_request.dart';
export 'src/database_adapter/requests/document_read_request.dart';
export 'src/database_adapter/requests/document_read_watch_request.dart';
export 'src/database_adapter/requests/document_search_chunked_request.dart';
export 'src/database_adapter/requests/document_search_request.dart';
export 'src/database_adapter/requests/document_search_watch_request.dart';
export 'src/database_adapter/requests/document_transaction_request.dart';
export 'src/database_adapter/requests/document_update_by_search_request.dart';
export 'src/database_adapter/requests/document_update_request.dart';
export 'src/database_adapter/requests/document_upsert_request.dart';
export 'src/database_adapter/requests/extension_request.dart';
export 'src/database_adapter/requests/request.dart';
export 'src/database_adapter/requests/schema_read_request.dart';
export 'src/database_adapter/requests/sql_query_request.dart';
export 'src/database_adapter/requests/sql_statement_request.dart';
export 'src/database_adapter/requests/sql_transaction_request.dart';
export 'src/database_adapter/scoring/default_comparator.dart';
export 'src/database_adapter/scoring/document_scoring.dart';
export 'src/database_adapter/scoring/document_scoring_base.dart';
export 'src/database_adapter/security_adapter.dart';
export 'src/database_adapter/sql_database_adapter.dart';
