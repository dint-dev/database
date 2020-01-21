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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

@sealed
class DocumentBatchRequest extends Request<Future<DocumentBatchResponse>> {
  final List<DocumentDeleteRequest> documentDeleteRequests;
  final List<DocumentDeleteBySearchRequest> documentDeleteBySearchRequests;
  final List<DocumentInsertRequest> documentInsertRequests;
  final List<DocumentReadRequest> documentReadRequests;
  final List<DocumentReadWatchRequest> documentReadWatchRequests;
  final List<DocumentSearchRequest> documentSearchRequests;
  final List<DocumentSearchWatchRequest> documentSearchWatchRequests;
  final List<DocumentUpdateBySearchRequest> documentUpdateBySearchRequests;
  final List<DocumentUpdateRequest> documentUpdateRequests;
  final List<DocumentUpsertRequest> documentUpsertRequests;

  DocumentBatchRequest({
    this.documentDeleteRequests = const [],
    this.documentDeleteBySearchRequests = const [],
    this.documentInsertRequests = const [],
    this.documentReadRequests = const [],
    this.documentReadWatchRequests = const [],
    this.documentSearchRequests = const [],
    this.documentSearchWatchRequests = const [],
    this.documentUpdateBySearchRequests = const [],
    this.documentUpdateRequests = const [],
    this.documentUpsertRequests = const [],
  });

  @override
  Future<DocumentBatchResponse> delegateTo(DatabaseAdapter adapter) {
    return adapter.performDocumentBatch(this);
  }
}

class DocumentBatchResponse {
  final List<Future<void>> documentDeleteResponses;
  final List<Future<void>> documentDeleteBySearchResponses;
  final List<Future<void>> documentInsertResponses;
  final List<Stream<Snapshot>> documentReadResponses;
  final List<Stream<Snapshot>> documentReadWatchResponses;
  final List<Stream<QueryResult>> documentSearchResponses;
  final List<Stream<QueryResult>> documentSearchWatchResponses;
  final List<Future<void>> documentUpdateBySearchResponses;
  final List<Future<void>> documentUpdateResponses;
  final List<Future<void>> documentUpsertResponses;

  DocumentBatchResponse({
    this.documentDeleteResponses = const [],
    this.documentDeleteBySearchResponses = const [],
    this.documentInsertResponses = const [],
    this.documentReadResponses = const [],
    this.documentReadWatchResponses = const [],
    this.documentSearchResponses = const [],
    this.documentSearchWatchResponses = const [],
    this.documentUpdateBySearchResponses = const [],
    this.documentUpdateResponses = const [],
    this.documentUpsertResponses = const [],
  });
}
