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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

/// An adapter that enables caching of data (for example, in local memory).
///
/// An example:
/// ```
/// import 'package:database/adapters.dart';
/// import 'package:database/database.dart';
///
/// void main() {
///   Database.freezeDefaultInstance(
///     CachingDatabase(
///       master: BrowserDatabase(),
///       cache: MemoryDatabase(),
///     ),
///   );
///   // ...
/// }
/// ```
class CachingDatabase extends DatabaseAdapter {
  /// Master [Database].
  final DatabaseAdapter master;

  /// Cache [Database].
  final DatabaseAdapter cache;

  /// Whether to ignore [UnavailableException] from master and use cache
  /// results (or error) when this happen. The default is true.
  final bool useCacheWhenMasterUnavailable;

  CachingDatabase({
    @required this.master,
    @required this.cache,
    this.useCacheWhenMasterUnavailable = true,
  }) {
    ArgumentError.checkNotNull(master, 'master');
    ArgumentError.checkNotNull(cache, 'cache');
  }

  @override
  Stream<Snapshot> performRead(
    ReadRequest request,
  ) {
    return _mergeStreams(
      (service, request) => service.performRead(request),
      request,
    );
  }

  @override
  Stream<QueryResult> performSearch(
    SearchRequest request,
  ) {
    return _mergeStreams(
      (service, request) => service.performSearch(request),
      request,
    );
  }

  @override
  Future<void> performWrite(
    WriteRequest request,
  ) {
    // Send write to the master.
    return master.performWrite(request).then((_) {
      // Send write to the cache. Ignore any possible error.
      // ignore: unawaited_futures
      cache.performWrite(request);
    });
  }

  Stream<Resp> _mergeStreams<Req, Resp>(
      Stream<Resp> Function(DatabaseAdapter service, Req request) f,
      Req request) {
    final result = StreamController<Resp>();
    final masterStream = f(master, request);
    final cacheStream = f(cache, request);
    StreamSubscription<Resp> masterSubscription;
    StreamSubscription<Resp> cacheSubscription;
    result.onListen = () {
      Object cacheError;
      StackTrace cacheStackTrace;
      var masterIsUnavailable = false;
      masterSubscription = masterStream.listen((event) {
        // Cancel cache subscription
        if (cacheSubscription != null) {
          cacheSubscription.cancel();
          cacheSubscription = null;
        }

        // Add this event to the merged stream
        result.add(event);
      }, onError: (error, stackTrace) {
        if (useCacheWhenMasterUnavailable && error.isUnavailable) {
          // Master is unavailable.
          masterIsUnavailable = true;

          // Emit possible earlier cache error
          if (cacheError != null) {
            result.addError(cacheError, cacheStackTrace);
          }
        } else {
          // Cancel cache subscription
          if (cacheSubscription != null) {
            cacheSubscription.cancel();
            cacheSubscription = null;
          }

          // Add this error to the merged stream
          result.addError(error, stackTrace);
        }

        // Cancel master subscription
        masterSubscription.cancel();
      }, onDone: () {
        masterSubscription = null;
        if (cacheSubscription == null) {
          result.close();
        }
      });

      //
      // Listen cache
      //
      cacheSubscription = cacheStream.listen(
        (event) {
          // If we haven't received anything from the master
          if (cacheSubscription != null) {
            result.add(event);
          }
        },
        onError: (error, stackTrace) {
          if (masterIsUnavailable) {
            result.addError(cacheError, cacheStackTrace);
          } else {
            cacheError = error;
            cacheStackTrace = stackTrace;
          }
        },
        onDone: () {
          cacheSubscription = null;
          if (masterSubscription == null) {
            result.close();
          }
        },
      );
    };
    result.onPause = () {
      cacheSubscription?.pause();
      masterSubscription?.pause();
    };
    result.onResume = () {
      cacheSubscription?.resume();
      masterSubscription?.resume();
    };
    result.onCancel = () {
      cacheSubscription?.cancel();
      masterSubscription?.cancel();
    };
    return result.stream;
  }
}
