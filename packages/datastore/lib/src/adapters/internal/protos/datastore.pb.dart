///
//  Generated code. Do not modify.
//  source: datastore.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'datastore.pbenum.dart';

export 'datastore.pbenum.dart';

class SearchInput extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchInput', createEmptyInstance: create)
    ..aOM<Collection>(1, 'collection', subBuilder: Collection.create)
    ..aOM<Query>(2, 'query', subBuilder: Query.create)
    ..aOB(5, 'isIncremental', protoName: 'isIncremental')
    ..hasRequiredFields = false
  ;

  SearchInput._() : super();
  factory SearchInput() => create();
  factory SearchInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  SearchInput clone() => SearchInput()..mergeFromMessage(this);
  @$core.override
  SearchInput copyWith(void Function(SearchInput) updates) => super.copyWith((message) => updates(message as SearchInput));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SearchInput create() => SearchInput._();
  @$core.override
  SearchInput createEmptyInstance() => create();
  static $pb.PbList<SearchInput> createRepeated() => $pb.PbList<SearchInput>();
  @$core.pragma('dart2js:noInline')
  static SearchInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchInput>(create);
  static SearchInput _defaultInstance;

  @$pb.TagNumber(1)
  Collection get collection => $_getN(0);
  @$pb.TagNumber(1)
  set collection(Collection v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCollection() => $_has(0);
  @$pb.TagNumber(1)
  void clearCollection() => clearField(1);
  @$pb.TagNumber(1)
  Collection ensureCollection() => $_ensure(0);

  @$pb.TagNumber(2)
  Query get query => $_getN(1);
  @$pb.TagNumber(2)
  set query(Query v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasQuery() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuery() => clearField(2);
  @$pb.TagNumber(2)
  Query ensureQuery() => $_ensure(1);

  @$pb.TagNumber(5)
  $core.bool get isIncremental => $_getBF(2);
  @$pb.TagNumber(5)
  set isIncremental($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsIncremental() => $_has(2);
  @$pb.TagNumber(5)
  void clearIsIncremental() => clearField(5);
}

class SearchOutput extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchOutput', createEmptyInstance: create)
    ..aOM<Error>(1, 'error', subBuilder: Error.create)
    ..a<$fixnum.Int64>(2, 'count', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<SearchResultItem>(3, 'items', $pb.PbFieldType.PM, subBuilder: SearchResultItem.create)
    ..hasRequiredFields = false
  ;

  SearchOutput._() : super();
  factory SearchOutput() => create();
  factory SearchOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  SearchOutput clone() => SearchOutput()..mergeFromMessage(this);
  @$core.override
  SearchOutput copyWith(void Function(SearchOutput) updates) => super.copyWith((message) => updates(message as SearchOutput));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SearchOutput create() => SearchOutput._();
  @$core.override
  SearchOutput createEmptyInstance() => create();
  static $pb.PbList<SearchOutput> createRepeated() => $pb.PbList<SearchOutput>();
  @$core.pragma('dart2js:noInline')
  static SearchOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchOutput>(create);
  static SearchOutput _defaultInstance;

  @$pb.TagNumber(1)
  Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error(Error v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => clearField(1);
  @$pb.TagNumber(1)
  Error ensureError() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get count => $_getI64(1);
  @$pb.TagNumber(2)
  set count($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<SearchResultItem> get items => $_getList(2);
}

class SearchResultItem extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SearchResultItem', createEmptyInstance: create)
    ..aOM<Document>(1, 'document', subBuilder: Document.create)
    ..aOM<Value>(2, 'data', subBuilder: Value.create)
    ..a<$core.double>(3, 'score', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  SearchResultItem._() : super();
  factory SearchResultItem() => create();
  factory SearchResultItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchResultItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  SearchResultItem clone() => SearchResultItem()..mergeFromMessage(this);
  @$core.override
  SearchResultItem copyWith(void Function(SearchResultItem) updates) => super.copyWith((message) => updates(message as SearchResultItem));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SearchResultItem create() => SearchResultItem._();
  @$core.override
  SearchResultItem createEmptyInstance() => create();
  static $pb.PbList<SearchResultItem> createRepeated() => $pb.PbList<SearchResultItem>();
  @$core.pragma('dart2js:noInline')
  static SearchResultItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchResultItem>(create);
  static SearchResultItem _defaultInstance;

  @$pb.TagNumber(1)
  Document get document => $_getN(0);
  @$pb.TagNumber(1)
  set document(Document v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDocument() => $_has(0);
  @$pb.TagNumber(1)
  void clearDocument() => clearField(1);
  @$pb.TagNumber(1)
  Document ensureDocument() => $_ensure(0);

  @$pb.TagNumber(2)
  Value get data => $_getN(1);
  @$pb.TagNumber(2)
  set data(Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
  @$pb.TagNumber(2)
  Value ensureData() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.double get score => $_getN(2);
  @$pb.TagNumber(3)
  set score($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearScore() => clearField(3);
}

class ReadInput extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ReadInput', createEmptyInstance: create)
    ..aOM<Document>(1, 'document', subBuilder: Document.create)
    ..hasRequiredFields = false
  ;

  ReadInput._() : super();
  factory ReadInput() => create();
  factory ReadInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReadInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  ReadInput clone() => ReadInput()..mergeFromMessage(this);
  @$core.override
  ReadInput copyWith(void Function(ReadInput) updates) => super.copyWith((message) => updates(message as ReadInput));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ReadInput create() => ReadInput._();
  @$core.override
  ReadInput createEmptyInstance() => create();
  static $pb.PbList<ReadInput> createRepeated() => $pb.PbList<ReadInput>();
  @$core.pragma('dart2js:noInline')
  static ReadInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReadInput>(create);
  static ReadInput _defaultInstance;

  @$pb.TagNumber(1)
  Document get document => $_getN(0);
  @$pb.TagNumber(1)
  set document(Document v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDocument() => $_has(0);
  @$pb.TagNumber(1)
  void clearDocument() => clearField(1);
  @$pb.TagNumber(1)
  Document ensureDocument() => $_ensure(0);
}

class ReadOutput extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ReadOutput', createEmptyInstance: create)
    ..aOM<Error>(1, 'error', subBuilder: Error.create)
    ..aOM<Document>(2, 'document', subBuilder: Document.create)
    ..aOB(3, 'exists')
    ..aOM<Value>(4, 'data', subBuilder: Value.create)
    ..hasRequiredFields = false
  ;

  ReadOutput._() : super();
  factory ReadOutput() => create();
  factory ReadOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReadOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  ReadOutput clone() => ReadOutput()..mergeFromMessage(this);
  @$core.override
  ReadOutput copyWith(void Function(ReadOutput) updates) => super.copyWith((message) => updates(message as ReadOutput));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ReadOutput create() => ReadOutput._();
  @$core.override
  ReadOutput createEmptyInstance() => create();
  static $pb.PbList<ReadOutput> createRepeated() => $pb.PbList<ReadOutput>();
  @$core.pragma('dart2js:noInline')
  static ReadOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReadOutput>(create);
  static ReadOutput _defaultInstance;

  @$pb.TagNumber(1)
  Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error(Error v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => clearField(1);
  @$pb.TagNumber(1)
  Error ensureError() => $_ensure(0);

  @$pb.TagNumber(2)
  Document get document => $_getN(1);
  @$pb.TagNumber(2)
  set document(Document v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDocument() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocument() => clearField(2);
  @$pb.TagNumber(2)
  Document ensureDocument() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.bool get exists => $_getBF(2);
  @$pb.TagNumber(3)
  set exists($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasExists() => $_has(2);
  @$pb.TagNumber(3)
  void clearExists() => clearField(3);

  @$pb.TagNumber(4)
  Value get data => $_getN(3);
  @$pb.TagNumber(4)
  set data(Value v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasData() => $_has(3);
  @$pb.TagNumber(4)
  void clearData() => clearField(4);
  @$pb.TagNumber(4)
  Value ensureData() => $_ensure(3);
}

class WriteInput extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('WriteInput', createEmptyInstance: create)
    ..aOM<Document>(1, 'document', subBuilder: Document.create)
    ..e<WriteType>(2, 'type', $pb.PbFieldType.OE, defaultOrMaker: WriteType.unspecifiedWriteType, valueOf: WriteType.valueOf, enumValues: WriteType.values)
    ..aOM<Value>(3, 'value', subBuilder: Value.create)
    ..hasRequiredFields = false
  ;

  WriteInput._() : super();
  factory WriteInput() => create();
  factory WriteInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WriteInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  WriteInput clone() => WriteInput()..mergeFromMessage(this);
  @$core.override
  WriteInput copyWith(void Function(WriteInput) updates) => super.copyWith((message) => updates(message as WriteInput));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static WriteInput create() => WriteInput._();
  @$core.override
  WriteInput createEmptyInstance() => create();
  static $pb.PbList<WriteInput> createRepeated() => $pb.PbList<WriteInput>();
  @$core.pragma('dart2js:noInline')
  static WriteInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteInput>(create);
  static WriteInput _defaultInstance;

  @$pb.TagNumber(1)
  Document get document => $_getN(0);
  @$pb.TagNumber(1)
  set document(Document v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDocument() => $_has(0);
  @$pb.TagNumber(1)
  void clearDocument() => clearField(1);
  @$pb.TagNumber(1)
  Document ensureDocument() => $_ensure(0);

  @$pb.TagNumber(2)
  WriteType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(WriteType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  Value get value => $_getN(2);
  @$pb.TagNumber(3)
  set value(Value v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => clearField(3);
  @$pb.TagNumber(3)
  Value ensureValue() => $_ensure(2);
}

class WriteOutput extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('WriteOutput', createEmptyInstance: create)
    ..aOM<Error>(1, 'error', subBuilder: Error.create)
    ..hasRequiredFields = false
  ;

  WriteOutput._() : super();
  factory WriteOutput() => create();
  factory WriteOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WriteOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  WriteOutput clone() => WriteOutput()..mergeFromMessage(this);
  @$core.override
  WriteOutput copyWith(void Function(WriteOutput) updates) => super.copyWith((message) => updates(message as WriteOutput));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static WriteOutput create() => WriteOutput._();
  @$core.override
  WriteOutput createEmptyInstance() => create();
  static $pb.PbList<WriteOutput> createRepeated() => $pb.PbList<WriteOutput>();
  @$core.pragma('dart2js:noInline')
  static WriteOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WriteOutput>(create);
  static WriteOutput _defaultInstance;

  @$pb.TagNumber(1)
  Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error(Error v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => clearField(1);
  @$pb.TagNumber(1)
  Error ensureError() => $_ensure(0);
}

class Error extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Error', createEmptyInstance: create)
    ..e<ErrorCode>(1, 'code', $pb.PbFieldType.OE, defaultOrMaker: ErrorCode.unspecifiedError, valueOf: ErrorCode.valueOf, enumValues: ErrorCode.values)
    ..aOS(2, 'name')
    ..aOS(3, 'message')
    ..aOS(4, 'stackTrace', protoName: 'stackTrace')
    ..aOM<Collection>(5, 'collection', subBuilder: Collection.create)
    ..aOM<Document>(6, 'document', subBuilder: Document.create)
    ..hasRequiredFields = false
  ;

  Error._() : super();
  factory Error() => create();
  factory Error.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Error.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Error clone() => Error()..mergeFromMessage(this);
  @$core.override
  Error copyWith(void Function(Error) updates) => super.copyWith((message) => updates(message as Error));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Error create() => Error._();
  @$core.override
  Error createEmptyInstance() => create();
  static $pb.PbList<Error> createRepeated() => $pb.PbList<Error>();
  @$core.pragma('dart2js:noInline')
  static Error getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Error>(create);
  static Error _defaultInstance;

  @$pb.TagNumber(1)
  ErrorCode get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(ErrorCode v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get stackTrace => $_getSZ(3);
  @$pb.TagNumber(4)
  set stackTrace($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStackTrace() => $_has(3);
  @$pb.TagNumber(4)
  void clearStackTrace() => clearField(4);

  @$pb.TagNumber(5)
  Collection get collection => $_getN(4);
  @$pb.TagNumber(5)
  set collection(Collection v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCollection() => $_has(4);
  @$pb.TagNumber(5)
  void clearCollection() => clearField(5);
  @$pb.TagNumber(5)
  Collection ensureCollection() => $_ensure(4);

  @$pb.TagNumber(6)
  Document get document => $_getN(5);
  @$pb.TagNumber(6)
  set document(Document v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasDocument() => $_has(5);
  @$pb.TagNumber(6)
  void clearDocument() => clearField(6);
  @$pb.TagNumber(6)
  Document ensureDocument() => $_ensure(5);
}

class Query extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Query', createEmptyInstance: create)
    ..aOS(1, 'filterString', protoName: 'filterString')
    ..aOM<Filter>(2, 'filter', subBuilder: Filter.create)
    ..pPS(3, 'sorters')
    ..aOM<Schema>(4, 'schema', subBuilder: Schema.create)
    ..aInt64(5, 'skip')
    ..aInt64(6, 'take')
    ..hasRequiredFields = false
  ;

  Query._() : super();
  factory Query() => create();
  factory Query.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Query.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Query clone() => Query()..mergeFromMessage(this);
  @$core.override
  Query copyWith(void Function(Query) updates) => super.copyWith((message) => updates(message as Query));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Query create() => Query._();
  @$core.override
  Query createEmptyInstance() => create();
  static $pb.PbList<Query> createRepeated() => $pb.PbList<Query>();
  @$core.pragma('dart2js:noInline')
  static Query getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Query>(create);
  static Query _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filterString => $_getSZ(0);
  @$pb.TagNumber(1)
  set filterString($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilterString() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilterString() => clearField(1);

  @$pb.TagNumber(2)
  Filter get filter => $_getN(1);
  @$pb.TagNumber(2)
  set filter(Filter v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilter() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilter() => clearField(2);
  @$pb.TagNumber(2)
  Filter ensureFilter() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<$core.String> get sorters => $_getList(2);

  @$pb.TagNumber(4)
  Schema get schema => $_getN(3);
  @$pb.TagNumber(4)
  set schema(Schema v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSchema() => $_has(3);
  @$pb.TagNumber(4)
  void clearSchema() => clearField(4);
  @$pb.TagNumber(4)
  Schema ensureSchema() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get skip => $_getI64(4);
  @$pb.TagNumber(5)
  set skip($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSkip() => $_has(4);
  @$pb.TagNumber(5)
  void clearSkip() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get take => $_getI64(5);
  @$pb.TagNumber(6)
  set take($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTake() => $_has(5);
  @$pb.TagNumber(6)
  void clearTake() => clearField(6);
}

class Filter extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Filter', createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  Filter._() : super();
  factory Filter() => create();
  factory Filter.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Filter.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Filter clone() => Filter()..mergeFromMessage(this);
  @$core.override
  Filter copyWith(void Function(Filter) updates) => super.copyWith((message) => updates(message as Filter));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Filter create() => Filter._();
  @$core.override
  Filter createEmptyInstance() => create();
  static $pb.PbList<Filter> createRepeated() => $pb.PbList<Filter>();
  @$core.pragma('dart2js:noInline')
  static Filter getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Filter>(create);
  static Filter _defaultInstance;
}

class Schema extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Schema', createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  Schema._() : super();
  factory Schema() => create();
  factory Schema.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Schema.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Schema clone() => Schema()..mergeFromMessage(this);
  @$core.override
  Schema copyWith(void Function(Schema) updates) => super.copyWith((message) => updates(message as Schema));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Schema create() => Schema._();
  @$core.override
  Schema createEmptyInstance() => create();
  static $pb.PbList<Schema> createRepeated() => $pb.PbList<Schema>();
  @$core.pragma('dart2js:noInline')
  static Schema getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Schema>(create);
  static Schema _defaultInstance;
}

class Collection extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Collection', createEmptyInstance: create)
    ..aOS(1, 'datastoreId', protoName: 'datastoreId')
    ..aOS(2, 'collectionId', protoName: 'collectionId')
    ..hasRequiredFields = false
  ;

  Collection._() : super();
  factory Collection() => create();
  factory Collection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Collection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Collection clone() => Collection()..mergeFromMessage(this);
  @$core.override
  Collection copyWith(void Function(Collection) updates) => super.copyWith((message) => updates(message as Collection));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Collection create() => Collection._();
  @$core.override
  Collection createEmptyInstance() => create();
  static $pb.PbList<Collection> createRepeated() => $pb.PbList<Collection>();
  @$core.pragma('dart2js:noInline')
  static Collection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Collection>(create);
  static Collection _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datastoreId => $_getSZ(0);
  @$pb.TagNumber(1)
  set datastoreId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDatastoreId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatastoreId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get collectionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set collectionId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCollectionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCollectionId() => clearField(2);
}

class Document extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Document', createEmptyInstance: create)
    ..aOS(1, 'datastoreId', protoName: 'datastoreId')
    ..aOS(2, 'collectionId', protoName: 'collectionId')
    ..aOS(3, 'documentId', protoName: 'documentId')
    ..hasRequiredFields = false
  ;

  Document._() : super();
  factory Document() => create();
  factory Document.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Document.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Document clone() => Document()..mergeFromMessage(this);
  @$core.override
  Document copyWith(void Function(Document) updates) => super.copyWith((message) => updates(message as Document));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Document create() => Document._();
  @$core.override
  Document createEmptyInstance() => create();
  static $pb.PbList<Document> createRepeated() => $pb.PbList<Document>();
  @$core.pragma('dart2js:noInline')
  static Document getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Document>(create);
  static Document _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get datastoreId => $_getSZ(0);
  @$pb.TagNumber(1)
  set datastoreId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDatastoreId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDatastoreId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get collectionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set collectionId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCollectionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCollectionId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get documentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set documentId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDocumentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDocumentId() => clearField(3);
}

class Value extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Value', createEmptyInstance: create)
    ..aOB(1, 'isNull', protoName: 'isNull')
    ..aOB(2, 'boolValue', protoName: 'boolValue')
    ..a<$fixnum.Int64>(3, 'intValue', $pb.PbFieldType.OS6, protoName: 'intValue', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.double>(4, 'floatValue', $pb.PbFieldType.OD, protoName: 'floatValue')
    ..aOM<Timestamp>(5, 'dateTimeValue', protoName: 'dateTimeValue', subBuilder: Timestamp.create)
    ..aOM<GeoPoint>(6, 'geoPoint', protoName: 'geoPoint', subBuilder: GeoPoint.create)
    ..aOS(7, 'stringValue', protoName: 'stringValue')
    ..a<$core.List<$core.int>>(8, 'bytesValue', $pb.PbFieldType.OY, protoName: 'bytesValue')
    ..aOB(9, 'emptyList', protoName: 'emptyList')
    ..pc<Value>(11, 'listValue', $pb.PbFieldType.PM, protoName: 'listValue', subBuilder: Value.create)
    ..m<$core.String, Value>(12, 'mapValue', protoName: 'mapValue', entryClassName: 'Value.MapValueEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: Value.create)
    ..hasRequiredFields = false
  ;

  Value._() : super();
  factory Value() => create();
  factory Value.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Value.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Value clone() => Value()..mergeFromMessage(this);
  @$core.override
  Value copyWith(void Function(Value) updates) => super.copyWith((message) => updates(message as Value));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Value create() => Value._();
  @$core.override
  Value createEmptyInstance() => create();
  static $pb.PbList<Value> createRepeated() => $pb.PbList<Value>();
  @$core.pragma('dart2js:noInline')
  static Value getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Value>(create);
  static Value _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isNull => $_getBF(0);
  @$pb.TagNumber(1)
  set isNull($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsNull() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsNull() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get boolValue => $_getBF(1);
  @$pb.TagNumber(2)
  set boolValue($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBoolValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearBoolValue() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get intValue => $_getI64(2);
  @$pb.TagNumber(3)
  set intValue($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIntValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearIntValue() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get floatValue => $_getN(3);
  @$pb.TagNumber(4)
  set floatValue($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFloatValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearFloatValue() => clearField(4);

  @$pb.TagNumber(5)
  Timestamp get dateTimeValue => $_getN(4);
  @$pb.TagNumber(5)
  set dateTimeValue(Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasDateTimeValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearDateTimeValue() => clearField(5);
  @$pb.TagNumber(5)
  Timestamp ensureDateTimeValue() => $_ensure(4);

  @$pb.TagNumber(6)
  GeoPoint get geoPoint => $_getN(5);
  @$pb.TagNumber(6)
  set geoPoint(GeoPoint v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasGeoPoint() => $_has(5);
  @$pb.TagNumber(6)
  void clearGeoPoint() => clearField(6);
  @$pb.TagNumber(6)
  GeoPoint ensureGeoPoint() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get stringValue => $_getSZ(6);
  @$pb.TagNumber(7)
  set stringValue($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStringValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearStringValue() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get bytesValue => $_getN(7);
  @$pb.TagNumber(8)
  set bytesValue($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasBytesValue() => $_has(7);
  @$pb.TagNumber(8)
  void clearBytesValue() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get emptyList => $_getBF(8);
  @$pb.TagNumber(9)
  set emptyList($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasEmptyList() => $_has(8);
  @$pb.TagNumber(9)
  void clearEmptyList() => clearField(9);

  @$pb.TagNumber(11)
  $core.List<Value> get listValue => $_getList(9);

  @$pb.TagNumber(12)
  $core.Map<$core.String, Value> get mapValue => $_getMap(10);
}

class Timestamp extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Timestamp', createEmptyInstance: create)
    ..aInt64(1, 'seconds')
    ..a<$core.int>(2, 'nanos', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  Timestamp._() : super();
  factory Timestamp() => create();
  factory Timestamp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Timestamp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  Timestamp clone() => Timestamp()..mergeFromMessage(this);
  @$core.override
  Timestamp copyWith(void Function(Timestamp) updates) => super.copyWith((message) => updates(message as Timestamp));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Timestamp create() => Timestamp._();
  @$core.override
  Timestamp createEmptyInstance() => create();
  static $pb.PbList<Timestamp> createRepeated() => $pb.PbList<Timestamp>();
  @$core.pragma('dart2js:noInline')
  static Timestamp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Timestamp>(create);
  static Timestamp _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seconds => $_getI64(0);
  @$pb.TagNumber(1)
  set seconds($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSeconds() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeconds() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get nanos => $_getIZ(1);
  @$pb.TagNumber(2)
  set nanos($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNanos() => $_has(1);
  @$pb.TagNumber(2)
  void clearNanos() => clearField(2);
}

class GeoPoint extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GeoPoint', createEmptyInstance: create)
    ..a<$core.double>(1, 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(2, 'longitude', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  GeoPoint._() : super();
  factory GeoPoint() => create();
  factory GeoPoint.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GeoPoint.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.override
  GeoPoint clone() => GeoPoint()..mergeFromMessage(this);
  @$core.override
  GeoPoint copyWith(void Function(GeoPoint) updates) => super.copyWith((message) => updates(message as GeoPoint));
  @$core.override
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GeoPoint create() => GeoPoint._();
  @$core.override
  GeoPoint createEmptyInstance() => create();
  static $pb.PbList<GeoPoint> createRepeated() => $pb.PbList<GeoPoint>();
  @$core.pragma('dart2js:noInline')
  static GeoPoint getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GeoPoint>(create);
  static GeoPoint _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => clearField(2);
}

