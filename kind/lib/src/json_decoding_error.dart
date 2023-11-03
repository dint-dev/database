// Copyright 2021 Gohilla Ltd.
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

import 'dart:convert';

import '../kind.dart';

/// Error that may be thrown by [Kind.decodeJsonTree].
class JsonDecodingError extends ArgumentError {
  JsonDecodingError({
    required Object? value,
    required String? message,
  }) : super.value(value, 'json', message);

  factory JsonDecodingError.expected(Object? json,
      {required String expectedType}) {
    return JsonDecodingError(
      value: json,
      message: 'Expected $expectedType, got: ${jsonEncode(json)}',
    );
  }

  factory JsonDecodingError.expectedBool(Object? json) {
    return JsonDecodingError.expected(json, expectedType: 'a JSON boolean');
  }

  factory JsonDecodingError.expectedList(Object? json) {
    return JsonDecodingError.expected(json, expectedType: 'a JSON array');
  }

  factory JsonDecodingError.expectedNull(Object? json) {
    return JsonDecodingError.expected(json, expectedType: 'a JSON null');
  }

  factory JsonDecodingError.expectedNumber(Object? json) {
    return JsonDecodingError.expected(json, expectedType: 'a JSON number');
  }

  factory JsonDecodingError.expectedNumberOrString(Object? json) {
    return JsonDecodingError.expected(json,
        expectedType: 'a JSON number or string');
  }

  factory JsonDecodingError.expectedObject(Object? json) {
    return JsonDecodingError.expected(json, expectedType: 'a JSON object');
  }

  factory JsonDecodingError.expectedString(Object? json) {
    return JsonDecodingError.expected(json, expectedType: 'a JSON string');
  }
}
