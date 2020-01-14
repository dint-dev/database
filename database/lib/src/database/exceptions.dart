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
import 'package:meta/meta.dart';

class DatabaseException implements Exception {
  final int code;
  final String name;
  final String message;

  const DatabaseException.custom({
    @required this.code,
    @required this.name,
    this.message,
  });

  const DatabaseException.found(Document document)
      : this.custom(
          code: DatabaseExceptionCodes.found,
          name: 'found',
        );

  const DatabaseException.notFound(Document document)
      : this.custom(
          code: DatabaseExceptionCodes.notFound,
          name: 'not_found',
        );

  const DatabaseException.transactionUnsupported()
      : this.custom(
          code: DatabaseExceptionCodes.transactionUnsupported,
          name: 'transaction_unsupported',
        );

  const DatabaseException.unavailable()
      : this.custom(
          code: DatabaseExceptionCodes.unavailable,
          name: 'unavailable',
        );

  bool get isUnavailable => code == DatabaseExceptionCodes.unavailable;

  @override
  String toString() {
    return 'Database exception $code ("$name"): "$message")';
  }
}

// TODO: Better define exceptions.
class DatabaseExceptionCodes {
  static const unavailable = 1;
  static const found = 2;
  static const notFound = 3;
  static const transactionUnsupported = 4;
}
