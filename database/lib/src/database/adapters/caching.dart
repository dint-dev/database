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

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

/// An adapter that enables caching of data (for example, in local memory).
///
/// ## Example
/// ```
/// import 'package:database/database.dart';
///
/// void main() {
///   final database = CachingDatabaseAdapter(
///     master: BrowserDatabaseAdapter(),
///     cache: MemoryDatabaseAdapter(),
///   ).database();
/// }
/// ```
class CachingDatabaseAdapter extends DelegatingDatabaseAdapter {
  /// Master [Database].
  final DatabaseAdapter master;

  /// Cache [Database].
  final DatabaseAdapter cache;

  /// Whether to ignore [UnavailableException] from master and use cache
  /// results (or error) when this happen. The default is true.
  final bool useCacheWhenMasterUnavailable;

  CachingDatabaseAdapter({
    @required this.master,
    @required this.cache,
    this.useCacheWhenMasterUnavailable = true,
  }) : super(master) {
    ArgumentError.checkNotNull(master, 'master');
    ArgumentError.checkNotNull(cache, 'cache');
  }

  @override
  Future<void> performDocumentDelete(DocumentDeleteRequest request) {
    cache.performDocumentDelete(request).catchError((_) {});
    return super.performDocumentDelete(request);
  }

  @override
  Future<void> performDocumentDeleteBySearch(
      DocumentDeleteBySearchRequest request) {
    cache.performDocumentDeleteBySearch(request).catchError((_) {});
    return super.performDocumentDeleteBySearch(request);
  }

  @override
  Stream<Snapshot> performDocumentRead(
    DocumentReadRequest request,
  ) async* {
    // Start master read
    final masterFuture = super.performDocumentRead(request).last;

    // Read from cache and yield it
    Snapshot cacheSnapshot;
    try {
      cacheSnapshot = await request.delegateTo(cache).last;
    } on DatabaseException {
      // Ignore
    }
    if (cacheSnapshot != null && cacheSnapshot.exists) {
      yield (cacheSnapshot);
    }

    // Finish master read and yield it
    final masterSnapshot = await masterFuture;
    yield (masterSnapshot);

    try {
      if (masterSnapshot.exists) {
        if (!const DeepCollectionEquality()
            .equals(cacheSnapshot?.data, masterSnapshot.data)) {
          // Master and cache snapshots are different.
          // Update cached version.
          await DocumentUpsertRequest(
            document: request.document,
            data: masterSnapshot.data,
            reach: request.reach,
          ).delegateTo(cache);
        }
      } else if (cacheSnapshot?.exists ?? false) {
        // Remove cached version.
        await DocumentDeleteRequest(
          document: request.document,
          mustExist: false,
          reach: request.reach,
        ).delegateTo(cache);
      }
    } on DatabaseException {
      // Ignore
    }
  }

  @override
  Stream<QueryResult> performDocumentSearch(
    DocumentSearchRequest request,
  ) async* {
    final masterFuture = request.delegateTo(master);
    final cacheSnapshot = await request.delegateTo(cache).last;
    yield (cacheSnapshot);
    final masterSnapshot = await masterFuture.last;
    yield (masterSnapshot);
  }

  @override
  Future<void> performDocumentTransaction(DocumentTransactionRequest request) {
    throw DatabaseException.transactionUnsupported();
  }

  @override
  Future<void> performDocumentUpdate(DocumentUpdateRequest request) {
    DocumentDeleteRequest(
      document: request.document,
      mustExist: false,
      reach: request.reach,
    ).delegateTo(cache).catchError((_) {});
    return super.performDocumentUpdate(request);
  }

  @override
  Future<void> performDocumentUpdateBySearch(
      DocumentUpdateBySearchRequest request) {
    DocumentDeleteBySearchRequest(
      collection: request.collection,
      query: request.query,
      reach: request.reach,
    ).delegateTo(cache).catchError((_) {});
    return super.performDocumentUpdateBySearch(request);
  }

  @override
  Future<void> performDocumentUpsert(DocumentUpsertRequest request) {
    DocumentDeleteRequest(
      document: request.document,
      mustExist: false,
      reach: request.reach,
    ).delegateTo(cache).catchError((_) {});
    return super.performDocumentUpsert(request);
  }
}
