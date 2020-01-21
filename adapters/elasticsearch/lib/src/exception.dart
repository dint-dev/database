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

import 'dart:convert';

class ElasticSearchError {
  final Object detailsJson;

  ElasticSearchError.fromJson(this.detailsJson);

  String get reason {
    final detailsJson = this.detailsJson;
    if (detailsJson is Map) {
      return detailsJson['reason'] as String;
    }
    return null;
  }

  String get type {
    final detailsJson = this.detailsJson;
    if (detailsJson is Map) {
      return detailsJson['type'] as String;
    }
    return null;
  }

  @override
  String toString() {
    final details = const JsonEncoder.withIndent('  ')
        .convert(detailsJson)
        .replaceAll('\n', '\n  ');
    return 'ElasticSearch returned an error of type "$type".\n\nDetails:\n  $details';
  }
}
