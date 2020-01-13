// Copyright 2019 terrier989@gmail.com.
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

import 'dart:core';
import 'dart:core' as $core;

import 'package:database/mapper.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:test/test.dart';

void main() {
  group('ProtobufMapper', () {
    test('rawGraphFrom()', () {
      final mapper = ProtobufMapper(
        factoriesByTypeName: {},
        factoriesBySpecifiedType: {},
        throwOnDecodingFailure: true,
      );

      final document = Document()
        ..collectionId = 'a'
        ..documentId = 'b';

      expect(
        mapper.rawGraphFrom(document),
        {
          'collectionId': 'a',
          'documentId': 'b',
        },
      );
    });

    test('rawGraphTo(), given type name', () {
      final mapper = ProtobufMapper(
        factoriesByTypeName: {
          'Document': () => Document(),
        },
        factoriesBySpecifiedType: {},
        throwOnDecodingFailure: true,
      );

      final rawGraph = {
        'collectionId': 'a',
        'documentId': 'b',
      };

      final document = Document()
        ..collectionId = 'a'
        ..documentId = 'b';

      expect(
        mapper.rawGraphTo(rawGraph, typeName: 'Document'),
        document,
      );
    });

    test('rawGraphTo(), given specified type', () {
      final mapper = ProtobufMapper(
        factoriesBySpecifiedType: {
          FullType(Document): () => Document(),
        },
        factoriesByTypeName: {},
        throwOnDecodingFailure: true,
      );

      final rawGraph = {
        'collectionId': 'a',
        'documentId': 'b',
      };

      final document = Document()
        ..collectionId = 'a'
        ..documentId = 'b';

      expect(
        mapper.rawGraphTo(rawGraph, specifiedType: FullType(Document)),
        document,
      );
    });
  }, skip: 'Not implemented yet');
}

class Document extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo('Document', createEmptyInstance: create)
        ..aOS(1, 'databaseId', protoName: 'databaseId')
        ..aOS(2, 'collectionId', protoName: 'collectionId')
        ..aOS(3, 'documentId', protoName: 'documentId')
        ..hasRequiredFields = false;

  static Document _defaultInstance;
  factory Document() => create();
  factory Document.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Document.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  Document._() : super();
  @$pb.TagNumber(2)
  $core.String get collectionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set collectionId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(1)
  $core.String get databaseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set databaseId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(3)
  $core.String get documentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set documentId($core.String v) {
    $_setString(2, v);
  }

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$pb.TagNumber(2)
  void clearCollectionId() => clearField(2);
  @$pb.TagNumber(1)
  void clearDatabaseId() => clearField(1);

  @$pb.TagNumber(3)
  void clearDocumentId() => clearField(3);
  @$core.override
  Document clone() => Document()..mergeFromMessage(this);

  @$core.override
  Document copyWith(void Function(Document) updates) =>
      super.copyWith((message) => updates(message as Document));
  @$core.override
  Document createEmptyInstance() => create();

  @$pb.TagNumber(2)
  $core.bool hasCollectionId() => $_has(1);
  @$pb.TagNumber(1)
  $core.bool hasDatabaseId() => $_has(0);

  @$pb.TagNumber(3)
  $core.bool hasDocumentId() => $_has(2);
  @$core.pragma('dart2js:noInline')
  static Document create() => Document._();

  static $pb.PbList<Document> createRepeated() => $pb.PbList<Document>();
  @$core.pragma('dart2js:noInline')
  static Document getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Document>(create);
}
