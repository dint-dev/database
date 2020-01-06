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

import 'package:datastore/datastore.dart';
import 'package:meta/meta.dart';

abstract class Transaction {
  Future<void> delete(Document document);
  Future<void> deleteIfExists(Document document);
  Future<Snapshot> get(Document document);
  Future<void> insert(Document document, {@required Map<String, Object> data});
  Future<void> update(Document document, {@required Map<String, Object> data});
  Future<void> upsert(Document document, {@required Map<String, Object> data});
}

abstract class WriteBatch {
  WriteBatch();

  factory WriteBatch.simple() = _WriteBatch;

  /// Completes with value [:null] when the transaction is committed. Completes
  /// with error [TransactionFailureException] if the transaction is rolled back.
  Future<void> get done;

  /// Commits the transaction (if possible).
  Future<void> commit();

  void deleteIfExists(Document document);
  void update(Document document, {@required Map<String, Object> data});
  void upsert(Document document, {@required Map<String, Object> data});
}

class _WriteBatch extends WriteBatch {
  final _list = <Future<void> Function()>[];
  final _completer = Completer();

  @override
  Future<void> get done => _completer.future;

  @override
  Future<void> commit() async {
    if (!_completer.isCompleted) {
      final future = Future.wait(_list.map((item) => item()));
      _completer.complete(future);
    }
    return done;
  }

  @override
  void deleteIfExists(Document document) {
    _list.add(() {
      return document.deleteIfExists();
    });
  }

  @override
  void update(Document document, {Map<String, Object> data}) {
    _list.add(() {
      return document.update(data: data);
    });
  }

  @override
  void upsert(Document document, {Map<String, Object> data}) {
    _list.add(() {
      return document.upsert(data: data);
    });
  }
}
