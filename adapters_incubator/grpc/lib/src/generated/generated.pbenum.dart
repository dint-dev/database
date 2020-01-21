///
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class DocumentWriteType extends $pb.ProtobufEnum {
  static const DocumentWriteType unspecifiedDocumentWriteType =
      DocumentWriteType._(0, 'unspecifiedDocumentWriteType');
  static const DocumentWriteType delete = DocumentWriteType._(1, 'delete');
  static const DocumentWriteType deleteIfExists =
      DocumentWriteType._(2, 'deleteIfExists');
  static const DocumentWriteType insert = DocumentWriteType._(3, 'insert');
  static const DocumentWriteType update = DocumentWriteType._(4, 'update');
  static const DocumentWriteType upsert = DocumentWriteType._(5, 'upsert');

  static const $core.List<DocumentWriteType> values = <DocumentWriteType>[
    unspecifiedDocumentWriteType,
    delete,
    deleteIfExists,
    insert,
    update,
    upsert,
  ];

  static final $core.Map<$core.int, DocumentWriteType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  const DocumentWriteType._($core.int v, $core.String n) : super(v, n);

  static DocumentWriteType valueOf($core.int value) => _byValue[value];
}

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
