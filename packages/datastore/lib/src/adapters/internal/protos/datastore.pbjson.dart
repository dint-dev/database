///
//  Generated code. Do not modify.
//  source: datastore.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const WriteType$json = const {
  '1': 'WriteType',
  '2': const [
    const {'1': 'unspecifiedWriteType', '2': 0},
    const {'1': 'delete', '2': 1},
    const {'1': 'deleteIfExists', '2': 2},
    const {'1': 'insert', '2': 3},
    const {'1': 'update', '2': 4},
    const {'1': 'upsert', '2': 5},
  ],
};

const ErrorCode$json = const {
  '1': 'ErrorCode',
  '2': const [
    const {'1': 'unspecifiedError', '2': 0},
    const {'1': 'exists', '2': 1},
    const {'1': 'doesNotExist', '2': 2},
  ],
};

const SearchInput$json = const {
  '1': 'SearchInput',
  '2': const [
    const {'1': 'collection', '3': 1, '4': 1, '5': 11, '6': '.Collection', '10': 'collection'},
    const {'1': 'query', '3': 2, '4': 1, '5': 11, '6': '.Query', '10': 'query'},
    const {'1': 'isIncremental', '3': 5, '4': 1, '5': 8, '10': 'isIncremental'},
  ],
};

const SearchOutput$json = const {
  '1': 'SearchOutput',
  '2': const [
    const {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.Error', '10': 'error'},
    const {'1': 'count', '3': 2, '4': 1, '5': 4, '10': 'count'},
    const {'1': 'items', '3': 3, '4': 3, '5': 11, '6': '.SearchResultItem', '10': 'items'},
  ],
};

const SearchResultItem$json = const {
  '1': 'SearchResultItem',
  '2': const [
    const {'1': 'document', '3': 1, '4': 1, '5': 11, '6': '.Document', '10': 'document'},
    const {'1': 'data', '3': 2, '4': 1, '5': 11, '6': '.Value', '10': 'data'},
    const {'1': 'score', '3': 3, '4': 1, '5': 1, '10': 'score'},
  ],
};

const ReadInput$json = const {
  '1': 'ReadInput',
  '2': const [
    const {'1': 'document', '3': 1, '4': 1, '5': 11, '6': '.Document', '10': 'document'},
  ],
};

const ReadOutput$json = const {
  '1': 'ReadOutput',
  '2': const [
    const {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.Error', '10': 'error'},
    const {'1': 'document', '3': 2, '4': 1, '5': 11, '6': '.Document', '10': 'document'},
    const {'1': 'exists', '3': 3, '4': 1, '5': 8, '10': 'exists'},
    const {'1': 'data', '3': 4, '4': 1, '5': 11, '6': '.Value', '10': 'data'},
  ],
};

const WriteInput$json = const {
  '1': 'WriteInput',
  '2': const [
    const {'1': 'document', '3': 1, '4': 1, '5': 11, '6': '.Document', '10': 'document'},
    const {'1': 'type', '3': 2, '4': 1, '5': 14, '6': '.WriteType', '10': 'type'},
    const {'1': 'value', '3': 3, '4': 1, '5': 11, '6': '.Value', '10': 'value'},
  ],
};

const WriteOutput$json = const {
  '1': 'WriteOutput',
  '2': const [
    const {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.Error', '10': 'error'},
  ],
};

const Error$json = const {
  '1': 'Error',
  '2': const [
    const {'1': 'code', '3': 1, '4': 1, '5': 14, '6': '.ErrorCode', '10': 'code'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'stackTrace', '3': 4, '4': 1, '5': 9, '10': 'stackTrace'},
    const {'1': 'collection', '3': 5, '4': 1, '5': 11, '6': '.Collection', '10': 'collection'},
    const {'1': 'document', '3': 6, '4': 1, '5': 11, '6': '.Document', '10': 'document'},
  ],
};

const Query$json = const {
  '1': 'Query',
  '2': const [
    const {'1': 'filterString', '3': 1, '4': 1, '5': 9, '10': 'filterString'},
    const {'1': 'filter', '3': 2, '4': 1, '5': 11, '6': '.Filter', '10': 'filter'},
    const {'1': 'sorters', '3': 3, '4': 3, '5': 9, '10': 'sorters'},
    const {'1': 'schema', '3': 4, '4': 1, '5': 11, '6': '.Schema', '10': 'schema'},
    const {'1': 'skip', '3': 5, '4': 1, '5': 3, '10': 'skip'},
    const {'1': 'take', '3': 6, '4': 1, '5': 3, '10': 'take'},
  ],
};

const Filter$json = const {
  '1': 'Filter',
};

const Schema$json = const {
  '1': 'Schema',
};

const Collection$json = const {
  '1': 'Collection',
  '2': const [
    const {'1': 'datastoreId', '3': 1, '4': 1, '5': 9, '10': 'datastoreId'},
    const {'1': 'collectionId', '3': 2, '4': 1, '5': 9, '10': 'collectionId'},
  ],
};

const Document$json = const {
  '1': 'Document',
  '2': const [
    const {'1': 'datastoreId', '3': 1, '4': 1, '5': 9, '10': 'datastoreId'},
    const {'1': 'collectionId', '3': 2, '4': 1, '5': 9, '10': 'collectionId'},
    const {'1': 'documentId', '3': 3, '4': 1, '5': 9, '10': 'documentId'},
  ],
};

const Value$json = const {
  '1': 'Value',
  '2': const [
    const {'1': 'isNull', '3': 1, '4': 1, '5': 8, '10': 'isNull'},
    const {'1': 'boolValue', '3': 2, '4': 1, '5': 8, '10': 'boolValue'},
    const {'1': 'intValue', '3': 3, '4': 1, '5': 18, '10': 'intValue'},
    const {'1': 'floatValue', '3': 4, '4': 1, '5': 1, '10': 'floatValue'},
    const {'1': 'dateTimeValue', '3': 5, '4': 1, '5': 11, '6': '.Timestamp', '10': 'dateTimeValue'},
    const {'1': 'geoPoint', '3': 6, '4': 1, '5': 11, '6': '.GeoPoint', '10': 'geoPoint'},
    const {'1': 'stringValue', '3': 7, '4': 1, '5': 9, '10': 'stringValue'},
    const {'1': 'bytesValue', '3': 8, '4': 1, '5': 12, '10': 'bytesValue'},
    const {'1': 'emptyList', '3': 9, '4': 1, '5': 8, '10': 'emptyList'},
    const {'1': 'listValue', '3': 11, '4': 3, '5': 11, '6': '.Value', '10': 'listValue'},
    const {'1': 'mapValue', '3': 12, '4': 3, '5': 11, '6': '.Value.MapValueEntry', '10': 'mapValue'},
  ],
  '3': const [Value_MapValueEntry$json],
};

const Value_MapValueEntry$json = const {
  '1': 'MapValueEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.Value', '10': 'value'},
  ],
  '7': const {'7': true},
};

const Timestamp$json = const {
  '1': 'Timestamp',
  '2': const [
    const {'1': 'seconds', '3': 1, '4': 1, '5': 3, '10': 'seconds'},
    const {'1': 'nanos', '3': 2, '4': 1, '5': 5, '10': 'nanos'},
  ],
};

const GeoPoint$json = const {
  '1': 'GeoPoint',
  '2': const [
    const {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    const {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
  ],
};

