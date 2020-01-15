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
  final Document document;
  final int code;
  final String name;
  final String message;
  final Object error;

  const DatabaseException.custom({
    this.document,
    @required this.code,
    @required this.name,
    this.message,
    this.error,
  });

  const DatabaseException.found(
    Document document, {
    String message,
    Object error,
  }) : this.custom(
          document: document,
          code: DatabaseExceptionCodes.found,
          name: 'found',
          message: message,
          error: error,
        );

  const DatabaseException.internal({
    Document document,
    String message,
    Object error,
  }) : this.custom(
          document: document,
          code: DatabaseExceptionCodes.internal,
          name: 'internal',
          message: message,
          error: error,
        );

  const DatabaseException.notFound(
    Document document, {
    String message,
    Object error,
  }) : this.custom(
          document: document,
          code: DatabaseExceptionCodes.notFound,
          name: 'not_found',
          message: message,
          error: error,
        );

  const DatabaseException.transactionUnsupported({
    Document document,
    String message,
    Object error,
  }) : this.custom(
          document: document,
          code: DatabaseExceptionCodes.transactionUnsupported,
          name: 'transaction_unsupported',
          message: message,
          error: error,
        );

  const DatabaseException.unavailable({
    Document document,
    String message,
    Object error,
  }) : this.custom(
          document: document,
          code: DatabaseExceptionCodes.unavailable,
          name: 'unavailable',
          message: message,
          error: error,
        );

  bool get isUnavailable => code == DatabaseExceptionCodes.unavailable;

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('Database exception $code ("$name")');
    final message = this.message;
    if (message != null) {
      sb.write('\n  message = ');
      sb.write(message.replaceAll('\n', '\n    '));
    }
    final document = this.document;
    if (document != null) {
      sb.write('\n  document = ');
      sb.write(document.toString().replaceAll('\n', '\n    '));
    }
    final error = this.error;
    if (error != null) {
      sb.write('\n  error = ');
      sb.write(error.toString().replaceAll('\n', '\n    '));
    }
    return sb.toString();
  }
}

// TODO: Better define exceptions.
class DatabaseExceptionCodes {
  static const unavailable = 1;
  static const found = 2;
  static const notFound = 3;
  static const transactionUnsupported = 4;
  static const internal = 5;
}
