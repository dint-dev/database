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

import 'package:os/os.dart';

import '../kind.dart';

/// [Kind] for [Duration].
final class DurationKind extends Kind<Duration>
    with PrimitiveKindMixin<Duration>, ComparableKindMixin<Duration> {
  static const _million = 1000 * 1000;

  const DurationKind({
    super.name = 'Duration',
    super.traits,
  }) : super.constructor();

  @override
  Iterable<Duration> get examplesWithoutValidation {
    return const [
      Duration.zero,
      Duration(seconds: 42),
      Duration(seconds: -42),
    ];
  }

  @override
  int get hashCode => (DurationKind).hashCode ^ super.hashCode;

  @override
  bool operator ==(other) => other is DurationKind && super == other;

  @override
  Duration decodeJsonTree(Object? json) {
    if (json is String) {
      return decodeString(json);
    }
    throw JsonDecodingError.expectedString(json);
  }

  @override
  Duration decodeString(String string) {
    if (string.endsWith('s')) {
      final seconds = double.parse(string.substring(0, string.length - 1));
      return Duration(microseconds: (seconds * _million).toInt());
    }
    throw ArgumentError.value(string);
  }

  @override
  Object? encodeJsonTree(Duration instance) {
    return encodeString(instance);
  }

  @override
  String encodeString(Duration instance) {
    var string = (instance.inMicroseconds / _million).toString();
    if (isRunningInJs && !string.contains('.')) {
      string = '$string.0';
    }
    return '${string}s';
  }

  @override
  Duration newInstance() {
    return Duration.zero;
  }

  @override
  Duration permute(Duration instance) {
    return instance + const Duration(seconds: 1);
  }
}
