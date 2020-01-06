///
//  Generated code. Do not modify.
//  source: datastore.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class WriteType extends $pb.ProtobufEnum {
  static const WriteType unspecifiedWriteType = WriteType._(0, 'unspecifiedWriteType');
  static const WriteType delete = WriteType._(1, 'delete');
  static const WriteType deleteIfExists = WriteType._(2, 'deleteIfExists');
  static const WriteType insert = WriteType._(3, 'insert');
  static const WriteType update = WriteType._(4, 'update');
  static const WriteType upsert = WriteType._(5, 'upsert');

  static const $core.List<WriteType> values = <WriteType> [
    unspecifiedWriteType,
    delete,
    deleteIfExists,
    insert,
    update,
    upsert,
  ];

  static final $core.Map<$core.int, WriteType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static WriteType valueOf($core.int value) => _byValue[value];

  const WriteType._($core.int v, $core.String n) : super(v, n);
}

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode unspecifiedError = ErrorCode._(0, 'unspecifiedError');
  static const ErrorCode exists = ErrorCode._(1, 'exists');
  static const ErrorCode doesNotExist = ErrorCode._(2, 'doesNotExist');

  static const $core.List<ErrorCode> values = <ErrorCode> [
    unspecifiedError,
    exists,
    doesNotExist,
  ];

  static final $core.Map<$core.int, ErrorCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ErrorCode valueOf($core.int value) => _byValue[value];

  const ErrorCode._($core.int v, $core.String n) : super(v, n);
}

