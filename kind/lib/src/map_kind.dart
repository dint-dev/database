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

import 'dart:collection';
import 'dart:math';

import '../kind.dart';

/// [Kind] for [Map].
final class MapKind<K, V> extends Kind<Map<K, V>> {
  /// [Kind] of list elements.
  final Kind<K> keyKind;

  /// [Kind] of list elements.
  final Kind<V> valueKind;

  const MapKind({
    super.name = 'Map',
    required this.keyKind,
    required this.valueKind,
    super.traits,
  }) : super.constructor();

  @override
  Iterable<Map<K, V>> get examplesWithoutValidation {
    return [
      {},
      {keyKind.newInstance(): valueKind.newInstance()},
      {keyKind.newInstance(): valueKind.newInstance()},
      {keyKind.newInstance(): valueKind.newInstance()},
    ];
  }

  @override
  int get hashCode => Object.hash(
        MapKind,
        keyKind,
        valueKind,
        super.hashCode,
      );

  @override
  bool operator ==(Object other) =>
      other is MapKind &&
      keyKind == other.keyKind &&
      valueKind == other.valueKind &&
      super == other;

  @override
  void checkValid(Map<K, V> instance) {
    for (var key in instance.keys) {
      keyKind.checkValid(key);
    }
    for (var value in instance.values) {
      valueKind.checkValid(value);
    }
    super.checkValid(instance);
  }

  @override
  Map<K, V> clone(Map<K, V> instance) {
    final result = <K, V>{};
    instance.forEach((key, value) {
      result[keyKind.clone(key)] = valueKind.clone(value);
    });
    if (instance is UnmodifiableMapView<K, V>) {
      return UnmodifiableMapView<K, V>(result);
    }
    return result;
  }

  @override
  int compare(Map<K, V> left, Map<K, V> right) {
    if (equality.equals(left, right)) {
      return 0;
    }
    final leftEntries = left.entries.toList();
    leftEntries.sort((a, b) {
      return keyKind.compare(a.key, b.key);
    });
    final rightEntries = right.entries.toList();
    rightEntries.sort((a, b) {
      return keyKind.compare(a.key, b.key);
    });
    final minLength = min<int>(leftEntries.length, rightEntries.length);
    for (var i = 0; i < minLength; i++) {
      final a = leftEntries[i];
      final b = rightEntries[i];
      final r = keyKind.compare(a.key, b.key);
      if (r != 0) {
        return r;
      }
      final r2 = valueKind.compare(a.value, b.value);
      if (r2 != 0) {
        return r2;
      }
    }
    return leftEntries.length.compareTo(rightEntries.length);
  }

  @override
  String debugString(Map<K, V> instance) {
    final sb = StringBuffer();
    sb.write('<');
    sb.write(keyKind.dartType);
    sb.write(', ');
    sb.write(valueKind.dartType);
    sb.write('>{');
    sb.write(ListKind.debugStringForIterableElements<MapEntry<K, V>>(
      iterable: instance.entries,
      debugString: (entry) {
        final key = keyKind.debugString(entry.key);
        final value = valueKind.debugString(entry.value);
        return '$key: $value';
      },
      onTooLarge: (map) => '...${map.length} entries...',
    ));
    sb.write('}');
    return sb.toString();
  }

  @override
  Map<K, V> decodeJsonTree(Object? json) {
    if (json is Map<String, dynamic>) {
      return json.map((key, value) {
        return MapEntry<K, V>(
          keyKind.decodeString(key),
          valueKind.decodeJsonTree(value),
        );
      });
    }
    throw JsonDecodingError.expectedObject(json);
  }

  @override
  Object? encodeJsonTree(Map<K, V> instance) {
    return instance.map((key, value) {
      return MapEntry<String, dynamic>(
        keyKind.encodeString(key),
        valueKind.encodeJsonTree(value),
      );
    });
  }

  @override
  bool isDefaultValue(Object? instance) {
    return instance is Map<K, V> && instance.isEmpty;
  }

  @override
  bool isValid(Map<K, V> instance) {
    if (!instance.keys.every(keyKind.isValid)) {
      return false;
    }
    if (!instance.values.every(valueKind.isValid)) {
      return false;
    }
    return super.isValid(instance);
  }

  @override
  void memorySizeWith(MemoryCounter counter, Map<K, V> instance) {
    counter.add(32);
    for (var entry in instance.entries) {
      counter.add(16);
      counter.addObject(entry.key, kind: keyKind);
      counter.addObject(entry.value, kind: valueKind);
    }
  }

  @override
  Map<K, V> newInstance() {
    return <K, V>{};
  }

  @override
  Map<K, V> permute(Map<K, V> instance) {
    return Map<K, V>.fromEntries(
      instance.entries.map((entry) {
        return MapEntry<K, V>(
          keyKind.permute(entry.key),
          valueKind.permute(entry.value),
        );
      }),
    );
  }
}
