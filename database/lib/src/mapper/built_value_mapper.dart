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

import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/src/big_int_serializer.dart';
import 'package:built_value/src/bool_serializer.dart';
import 'package:built_value/src/built_list_multimap_serializer.dart';
import 'package:built_value/src/built_list_serializer.dart';
import 'package:built_value/src/built_map_serializer.dart';
import 'package:built_value/src/built_set_multimap_serializer.dart';
import 'package:built_value/src/built_set_serializer.dart';
import 'package:built_value/src/double_serializer.dart';
import 'package:built_value/src/duration_serializer.dart';
import 'package:built_value/src/int64_serializer.dart';
import 'package:built_value/src/int_serializer.dart';
import 'package:built_value/src/json_object_serializer.dart';
import 'package:built_value/src/num_serializer.dart';
import 'package:built_value/src/regexp_serializer.dart';
import 'package:built_value/src/string_serializer.dart';
import 'package:built_value/src/uri_serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:database/database.dart';
import 'package:database/mapper.dart';

final databaseSerializers = (SerializersBuilder()
      ..addPlugin(StandardJsonPlugin(discriminator: '@type'))
      ..add(BigIntSerializer())
      ..add(BoolSerializer())
      ..add(BuiltListSerializer())
      ..add(BuiltListMultimapSerializer())
      ..add(BuiltMapSerializer())
      ..add(BuiltSetSerializer())
      ..add(BuiltSetMultimapSerializer())
      ..add(Iso8601DateTimeSerializer())
      ..add(DurationSerializer())
      ..add(IntSerializer())
      ..add(Int64Serializer())
      ..add(DoubleSerializer())
      ..add(JsonObjectSerializer())
      ..add(NumSerializer())
      ..add(RegExpSerializer())
      ..add(StringSerializer())
      ..add(UriSerializer())
      ..add(_DateSerializer())
      ..add(_DocumentSerializer())
      ..addBuilderFactory(const FullType(BuiltList, [FullType.object]),
          () => ListBuilder<Object>())
      ..addBuilderFactory(
          const FullType(BuiltListMultimap, [FullType.object, FullType.object]),
          () => ListMultimapBuilder<Object, Object>())
      ..addBuilderFactory(
          const FullType(BuiltMap, [FullType.object, FullType.object]),
          () => MapBuilder<Object, Object>())
      ..addBuilderFactory(const FullType(BuiltSet, [FullType.object]),
          () => SetBuilder<Object>())
      ..addBuilderFactory(
          const FullType(BuiltSetMultimap, [FullType.object, FullType.object]),
          () => SetMultimapBuilder<Object, Object>()))
    .build();

class BuiltValueSerializationConfig extends Mapper {
  final Serializers _serializers;

  BuiltValueSerializationConfig(this._serializers);

  @override
  Object rawGraphFrom(
    Object value, {
    String typeName,
    FullType specifiedType,
    MapperEncodeContext context,
  }) {
    if (specifiedType == null && typeName != null) {
      final serializer = _serializers.serializerForWireName(typeName);
      specifiedType = FullType(serializer.types.first);
    }
    return _serializers.serialize(value, specifiedType: specifiedType);
  }

  @override
  Object rawGraphTo(
    Object value, {
    String typeName,
    FullType specifiedType,
    MapperDecodeContext context,
  }) {
    if (specifiedType == null && typeName != null) {
      final serializer = _serializers.serializerForWireName(typeName);
      specifiedType = FullType(serializer.types.first);
    }
    return _serializers.deserialize(value, specifiedType: specifiedType);
  }
}

class _DateSerializer extends PrimitiveSerializer<Date> {
  @override
  Iterable<Type> get types => const [Date];

  @override
  String get wireName => 'date';

  @override
  Date deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    if (serialized is String) {
      return Date.parse(serialized);
    }
    throw ArgumentError.value(serialized);
  }

  @override
  Object serialize(Serializers serializers, Date object,
      {FullType specifiedType = FullType.unspecified}) {
    return object.toString();
  }
}

class _DocumentSerializer extends PrimitiveSerializer<Document> {
  _DocumentSerializer();

  @override
  Iterable<Type> get types => const [Document];

  @override
  String get wireName => 'document';

  @override
  Document deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    if (serialized == null) {
      return null;
    }
    return serialized as Document;
  }

  @override
  Document serialize(Serializers serializers, Document object,
      {FullType specifiedType = FullType.unspecified}) {
    return object;
  }
}
