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

import 'dart:typed_data';

import 'package:database/mapper.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart' as pb;
import 'package:protobuf/src/protobuf/mixins/well_known.dart' as pb;

class ProtobufMapper extends Mapper {
  static const int _bitForBool = 0x10;
  static const int _bitForBytes = 0x20;
  static const int _bitForString = 0x40;
  static const int _bitForFirstDouble = 0x80;
  static const int _bitForLastDouble = 0x100;
  static const int _bitForIntFirstInt = 0x800;
  static const int _bitForLastInt = 0x100000;

  /// [pb.GeneratedMessage] factories by name.
  final Map<String, pb.GeneratedMessage Function()> factoriesByTypeName;

  /// [pb.GeneratedMessage] factories by [FullType].
  final Map<FullType, pb.GeneratedMessage Function()> factoriesBySpecifiedType;

  /// If true, this mapper will throw on failure.
  final bool throwOnDecodingFailure;

  /// If non-null, the mapper will receive the inputs which this mapper can't
  /// handle.
  final Mapper nextMapper;

  const ProtobufMapper({
    @required this.factoriesByTypeName,
    @required this.factoriesBySpecifiedType,
    @required this.throwOnDecodingFailure,
    this.nextMapper,
  })  : assert(factoriesByTypeName != null || factoriesBySpecifiedType != null),
        assert(throwOnDecodingFailure != null);

  @override
  Object rawGraphFrom(
    Object value, {
    String typeName,
    FullType specifiedType,
    MapperEncodeContext context,
  }) {
    if (value == null) {
      return null;
    } else if (value is pb.GeneratedMessage) {
      final fieldInfosByName = value.info_.byName;
      final result = <String, Object>{};
      for (var fieldName in fieldInfosByName.keys) {
        final fieldInfo = fieldInfosByName[fieldName];
        result[fieldName] = _dartToPb(value, fieldInfo);
      }
      return result;
    } else {
      throw ArgumentError.value(
        value,
        'value',
        'Should be a "package:protobuf" GeneratedMessage',
      );
    }
  }

  @override
  Object rawGraphTo(
    Object value, {
    String typeName,
    FullType specifiedType,
    MapperDecodeContext context,
  }) {
    if (value == null) {
      return null;
    } else if (value is Map<String, Object>) {
      //
      // This should be a GeneratedMessage
      //
      if (typeName == null && specifiedType == null) {
        //
        // We can't choose the right GeneratedMessage without type information
        //
        final nextMapper = this.nextMapper;
        if (nextMapper != null) {
          return nextMapper.rawGraphTo(
            value,
            typeName: typeName,
            specifiedType: specifiedType,
            context: context,
          );
        }
        throw ArgumentError(
          'Either `typeName` or `specifiedType` must be non-null.',
        );
      }

      //
      // Construct GeneratedMessage
      //
      final message = _newMessage(
        typeName: typeName,
        specifiedType: specifiedType,
      );
      if (message == null) {
        final nextMapper = this.nextMapper;
        if (nextMapper != null) {
          return nextMapper.rawGraphTo(
            value,
            typeName: typeName,
            specifiedType: specifiedType,
            context: context,
          );
        }
        throw ArgumentError(
          'Could not find factory for: $value',
        );
      }

      //
      // Set fields of the GeneratedMessage
      //
      final fieldInfosByName = message.info_.byName;
      for (var fieldName in fieldInfosByName.keys) {
        final fieldInfo = fieldInfosByName[fieldName];
        message.setField(
          fieldInfo.tagNumber,
          _dartFromPb(value, fieldInfo),
        );
      }

      // The GeneratedMessage is ready
      return message;
    } else {
      throw ArgumentError.value(
        value,
        'value',
        'Should be a Map<String,Object>',
      );
    }
  }

  /// Converts a Protocol Buffers value to Dart value.
  Object _dartFromPb(Object value, pb.FieldInfo fieldInfo) {
    if (value == null) {
      return fieldInfo.readonlyDefault;
    }
    final tagNumber = (fieldInfo.type >> 4) << 4;
    if (value is bool) {
      if (tagNumber == _bitForBool) {
        return value;
      }
    } else if (value is num) {
      if (tagNumber >= _bitForFirstDouble && tagNumber <= _bitForLastDouble) {
        return value.toDouble();
      } else if (tagNumber >= _bitForIntFirstInt &&
          tagNumber <= _bitForLastInt) {
        return value.toInt();
      }
    } else if (value is String) {
      if (tagNumber == _bitForString) {
        return value;
      }
    } else if (value is Uint8List) {
      if (tagNumber == _bitForBytes) {
        return value;
      }
    }
    throw ArgumentError.value(
      value,
      'value',
      'Failed to convert Protocol Buffers value (tagNumber:$tagNumber, type: ${value.runtimeType}) to Dart.',
    );
  }

  /// Converts Dart value to a Protocol Buffers value.
  Object _dartToPb(Object value, pb.FieldInfo fieldInfo) {
    if (value == null) {
      return fieldInfo.readonlyDefault;
    }
    final type = (fieldInfo.type >> 4) << 4;
    if (value is bool) {
      if (type == _bitForBool) {
        return value;
      }
    } else if (value is num) {
      if (type >= _bitForFirstDouble && type <= _bitForLastDouble) {
        return value.toDouble();
      } else if (type >= _bitForIntFirstInt && type <= _bitForLastInt) {
        return value.toInt();
      }
    } else if (value is DateTime) {
      if (fieldInfo.isGroupOrMessage) {
        final message = fieldInfo.subBuilder();
        Object messageObject = message;
        if (messageObject is pb.TimestampMixin) {
          pb.TimestampMixin.setFromDateTime(messageObject, value);
        }
        throw ArgumentError(
          'Message "${message.info_.messageName}" does not implement TimestampMixin',
        );
      }
    } else if (value is String) {
      if (type == _bitForString) {
        return value;
      }
    } else if (value is Uint8List) {
      if (type == _bitForBytes) {
        return value;
      }
    }
    throw ArgumentError.value(
      value,
      'value',
      'Failed to convert Dart type ${value.runtimeType} to Protocol Buffers (tagNumber:$type).',
    );
  }

  pb.GeneratedMessage _newMessage({String typeName, FullType specifiedType}) {
    if (specifiedType != null) {
      if (factoriesBySpecifiedType != null) {
        final f = factoriesBySpecifiedType[specifiedType];
        if (f != null) {
          return f();
        }
        if (specifiedType.parameters.isNotEmpty) {
          final f = factoriesBySpecifiedType[FullType(specifiedType.root)];
          if (f != null) {
            return f();
          }
        }
      }
    }
    if (typeName != null) {
      if (factoriesByTypeName != null) {
        final f = factoriesByTypeName[typeName];
        if (f != null) {
          return f();
        }
      }
    }
    return null;
  }
}
