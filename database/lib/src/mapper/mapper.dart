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

import 'package:built_value/serializer.dart';

export 'package:built_value/serializer.dart' show FullType;

/// Describes how serialize values.
abstract class Mapper {
  const Mapper();

  Object rawGraphFrom(
    Object value, {
    String typeName,
    FullType specifiedType,
    MapperEncodeContext context,
  });

  Object rawGraphTo(
    Object value, {
    String typeName,
    FullType specifiedType,
    MapperDecodeContext context,
  });
}

class MapperDecodeContext {
  final Mapper _orm;

  MapperDecodeContext(this._orm) {
    ArgumentError.checkNotNull(_orm);
  }

  Object decode(
    Object value, {
    String typeName,
    FullType specifiedType,
  }) {
    return _orm.rawGraphTo(
      value,
      typeName: typeName,
      specifiedType: specifiedType,
      context: this,
    );
  }
}

class MapperEncodeContext {
  final Mapper _objectMapper;

  MapperEncodeContext(this._objectMapper) {
    ArgumentError.checkNotNull(_objectMapper);
  }

  Object encode(
    Object value, {
    String typeName,
    FullType specifiedType,
  }) {
    return _objectMapper.rawGraphFrom(
      value,
      typeName: typeName,
      specifiedType: specifiedType,
      context: this,
    );
  }
}
