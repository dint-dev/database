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

import 'package:datastore/datastore.dart';
import 'package:meta/meta.dart';

class DatastoreException implements Exception {
  final int code;
  final String name;
  final String message;

  const DatastoreException.custom({
    @required this.code,
    @required this.name,
    this.message,
  });

  const DatastoreException.found(Document document)
      : this.custom(
          code: DatastoreExceptionCodes.found,
          name: 'found',
        );

  const DatastoreException.notFound(Document document)
      : this.custom(
          code: DatastoreExceptionCodes.notFound,
          name: 'not_found',
        );

  const DatastoreException.unavailable()
      : this.custom(
          code: DatastoreExceptionCodes.unavailable,
          name: 'unavailable',
        );

  bool get isUnavailable => code == DatastoreExceptionCodes.unavailable;

  @override
  String toString() {
    return 'Datastore exception $code ("$name"): "$message")';
  }
}

// TODO: Better define exceptions.
class DatastoreExceptionCodes {
  static const unavailable = 1;
  static const found = 2;
  static const notFound = 3;
}
