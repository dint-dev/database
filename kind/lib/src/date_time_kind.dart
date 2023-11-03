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

/// [Kind] for [DateTime].
///
/// You should choose one of the following:
///   * [DateTimeKind.utc] ("Use UTC")
///   * [DateTimeKind.local] ("Use local time zone, except when encoding")
///   * [DateTimeKind.localLeaking] ("Use local time zone, no exceptions")
final class DateTimeKind extends Kind<DateTime>
    with PrimitiveKindMixin<DateTime>, ComparableKindMixin<DateTime> {
  /// The default value.
  static final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Whether to convert values to UTC before encoding.
  final bool encodeUtc;

  /// Whether to convert values to UTC after decoding.
  final bool decodeUtc;

  /// [DateTimeKind] that converts values to UTC before encoding and to local
  /// time zone after decoding.
  const DateTimeKind.local({
    super.name = 'DateTime',
    this.encodeUtc = true,
    super.traits,
  })  : decodeUtc = false,
        super.constructor();

  /// [DateTimeKind] that uses local time zone for both encoded and decoded
  /// values.
  ///
  /// This could leak user's time zone information, which could be bad for
  /// privacy.
  const DateTimeKind.localLeaking({
    super.name = 'DateTime',
    super.traits,
  })  : encodeUtc = false,
        decodeUtc = false,
        super.constructor();

  /// [DateTimeKind] that always uses UTC.
  const DateTimeKind.utc({
    super.name = 'DateTime',
    this.encodeUtc = true,
    this.decodeUtc = true,
    super.traits,
  }) : super.constructor();

  @override
  Iterable<DateTime> get examplesWithoutValidation {
    return [
      epoch,
      epoch.toLocal(),
      DateTime.now().toUtc(),
      DateTime.now(),
      DateTime.now().subtract(const Duration(hours: 48)),
      DateTime.now().subtract(const Duration(hours: 36)),
      DateTime.now().subtract(const Duration(hours: 24)),
      DateTime.now().subtract(const Duration(hours: 12)),
      DateTime.now().add(const Duration(hours: 12)),
      DateTime.now().add(const Duration(hours: 24)),
      DateTime.now().add(const Duration(hours: 36)),
      DateTime.now().add(const Duration(hours: 48)),
    ];
  }

  @override
  int get hashCode =>
      Object.hash(DateTimeKind, encodeUtc, decodeUtc) ^ super.hashCode;

  @override
  bool operator ==(other) =>
      other is DateTimeKind &&
      encodeUtc == other.encodeUtc &&
      decodeUtc == other.decodeUtc &&
      super == other;

  @override
  String debugString(DateTime instance) {
    instance = _convertDecoded(instance);
    final sb = StringBuffer();
    sb.write('DateTime');
    if (instance.isUtc) {
      sb.write('.utc');
    }
    sb.write('(');
    sb.write(instance.year);
    sb.write(', ');
    sb.write(instance.month);
    sb.write(', ');
    sb.write(instance.day);
    final hour = instance.hour;
    final minute = instance.minute;
    final second = instance.second;
    final millisecond = instance.millisecond;
    final microsecond = instance.microsecond;
    if (hour != 0 ||
        minute != 0 ||
        second != 0 ||
        millisecond != 0 ||
        microsecond != 0) {
      sb.write(', ');
      sb.write(instance.hour);
      sb.write(', ');
      sb.write(instance.minute);
      sb.write(', ');
      sb.write(instance.second);
      if (millisecond != 0 || microsecond != 0) {
        sb.write(', ');
        sb.write(instance.millisecond);
        if (microsecond != 0) {
          sb.write(', ');
          sb.write(instance.microsecond);
        }
      }
    }
    sb.write(')');
    return sb.toString();
  }

  @override
  DateTime decodeJsonTree(Object? json) {
    if (json is String) {
      return decodeString(json);
    }
    if (json is num) {
      final intValue = json.toInt();
      return _convertDecoded(
        DateTime.fromMillisecondsSinceEpoch(intValue, isUtc: true),
      );
    }
    throw JsonDecodingError.expectedString(json);
  }

  @override
  DateTime decodeString(String string) {
    final result = DateTime.tryParse(string);
    if (result != null) {
      return _convertDecoded(result);
    }
    final intValue = int.tryParse(string);
    if (intValue != null) {
      return _convertDecoded(
        DateTime.fromMicrosecondsSinceEpoch(intValue, isUtc: true),
      );
    }
    throw ArgumentError.value(string);
  }

  @override
  Object? encodeJsonTree(DateTime instance) {
    return encodeString(instance);
  }

  @override
  String encodeString(DateTime instance) {
    return _convertEncoded(instance).toIso8601String();
  }

  @override
  int memorySize(DateTime value) {
    return 48;
  }

  @override
  DateTime newInstance() {
    return epoch;
  }

  @override
  DateTime permute(DateTime instance) {
    return instance.add(Duration(hours: 24));
  }

  DateTime _convertDecoded(DateTime dateTime) {
    if (decodeUtc) {
      return dateTime.toUtc();
    } else {
      return dateTime.toLocal();
    }
  }

  DateTime _convertEncoded(DateTime dateTime) {
    if (encodeUtc) {
      return dateTime.toUtc();
    } else {
      return dateTime.toLocal();
    }
  }
}
