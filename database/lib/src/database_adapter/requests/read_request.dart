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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:meta/meta.dart';

/// A request to perform a read in the storage.
@sealed
class ReadRequest {
  /// Document that is read.
  Document document;

  /// If non-null, the stream is infinite. New items are generated are updated
  /// using polling or some more efficient method.
  ///
  /// For performance reasons, an item should not be added to the stream if it's
  /// the equal to the previous added item.
  WatchSettings watchSettings;

  Schema schema;

  ReadRequest({
    @required this.document,
    this.watchSettings,
    this.schema,
  });

  bool get isPolling => watchSettings != null;

  Stream<Snapshot> delegateTo(Database database) {
    // ignore: invalid_use_of_protected_member
    return (database as DatabaseAdapter).performRead(this);
  }
}

/// Polling settings for [SearchRequest] and [ReadRequest].
class WatchSettings {
  /// Period between two polling events. The implementation does not need to
  /// honor this property.
  final Duration interval;
  const WatchSettings({this.interval});

  @override
  int get hashCode => interval.hashCode;

  @override
  bool operator ==(other) =>
      other is WatchSettings && interval == other.interval;
}
