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

import '../kind.dart';

/// A [Mapper] that decodes a JSON object.
///
/// If [jsonObject] does contain some JSON field, the output is a value taken
/// from the input object.
class JsonObjectDecodingMapper extends Mapper {
  final Map jsonObject;

  JsonObjectDecodingMapper(this.jsonObject);

  @override
  V handle<V>({
    required ParameterType parameterType,
    required V value,
    required String name,
    Kind? kind,
    V? defaultConstant,
    String? jsonName,
    List<Trait>? tags,
  }) {
    if (tags != null && tags.contains(Trait.noSerialization)) {
      return value;
    }

    // JSON name defaults to Dart identifier
    jsonName ??= name;

    // Does the JSON object contain the JSON field?
    final jsonObject = this.jsonObject;
    if (!jsonObject.containsKey(jsonName)) {
      // No, use default value.
      return value;
    }

    // Get JSON value
    var jsonValue = this.jsonObject[jsonName];

    // Simple case?
    if (jsonValue is V) {
      return jsonValue;
    }

    // Just in case the JSON tree has `int` rather than `double`,
    // convert it to double for consistency:
    if (jsonValue is int) {
      jsonValue = jsonValue.toDouble();
    }

    // Determine kind.
    //
    // If V is nullable:
    //   No need for toNullable() because already handled `null` case when we
    //   did `jsonValue is V`.
    final actualKind = kind ?? Kind.find<V>();
    return actualKind.decodeJsonTree(jsonValue);
  }
}

/// A [Mapper] that encodes a JSON object.
class JsonObjectEncodingMapper extends Mapper {
  final Map<String, Object?> jsonObject = {};

  @override
  bool get canReturnSame => true;

  @override
  V handle<V>({
    required ParameterType parameterType,
    required V value,
    required String name,
    Kind? kind,
    V? defaultConstant,
    String? jsonName,
    List<Trait>? tags,
  }) {
    if (tags != null && tags.contains(Trait.noSerialization)) {
      return value;
    }

    // JSON name defaults to Dart identifier
    jsonName ??= name;

    if (jsonObject.containsKey(jsonName)) {
      throw StateError(
        'JSON field "$jsonName" was declared twice.',
      );
    }

    if (defaultConstant != null && value == defaultConstant) {
      return value;
    }

    //
    // Handle simple, common cases
    //
    Object? jsonValue;
    if (value == null || value is bool || value is String) {
      jsonValue = value;
    } else if (value is num) {
      jsonValue = value.toDouble();
    } else {
      kind ??= Kind.find<V>();
      jsonValue = kind.encodeJsonTree(value);
    }
    jsonObject[jsonName] = jsonValue;
    return value;
  }
}
