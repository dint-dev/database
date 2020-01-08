///
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode unspecifiedError = ErrorCode._(0, 'unspecifiedError');
  static const ErrorCode exists = ErrorCode._(1, 'exists');
  static const ErrorCode doesNotExist = ErrorCode._(2, 'doesNotExist');

  static const $core.List<ErrorCode> values = <ErrorCode>[
    unspecifiedError,
    exists,
    doesNotExist,
  ];

  static final $core.Map<$core.int, ErrorCode> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  const ErrorCode._($core.int v, $core.String n) : super(v, n);

  static ErrorCode valueOf($core.int value) => _byValue[value];
}

class WriteType extends $pb.ProtobufEnum {
  static const WriteType unspecifiedWriteType =
      WriteType._(0, 'unspecifiedWriteType');
  static const WriteType delete = WriteType._(1, 'delete');
  static const WriteType deleteIfExists = WriteType._(2, 'deleteIfExists');
  static const WriteType insert = WriteType._(3, 'insert');
  static const WriteType update = WriteType._(4, 'update');
  static const WriteType upsert = WriteType._(5, 'upsert');

  static const $core.List<WriteType> values = <WriteType>[
    unspecifiedWriteType,
    delete,
    deleteIfExists,
    insert,
    update,
    upsert,
  ];

  static final $core.Map<$core.int, WriteType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  const WriteType._($core.int v, $core.String n) : super(v, n);

  static WriteType valueOf($core.int value) => _byValue[value];
}
