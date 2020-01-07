///
//  Generated code. Do not modify.
//  source: datastore.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const WriteType$json = {
  '1': 'WriteType',
  '2': [
    {'1': 'unspecifiedWriteType', '2': 0},
    {'1': 'delete', '2': 1},
    {'1': 'deleteIfExists', '2': 2},
    {'1': 'insert', '2': 3},
    {'1': 'update', '2': 4},
    {'1': 'upsert', '2': 5},
  ],
};

const ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'unspecifiedError', '2': 0},
    {'1': 'exists', '2': 1},
    {'1': 'doesNotExist', '2': 2},
  ],
};

const SearchInput$json = {
  '1': 'SearchInput',
  '2': [
    {
      '1': 'collection',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Collection',
      '10': 'collection'
    },
    {'1': 'query', '3': 2, '4': 1, '5': 11, '6': '.Query', '10': 'query'},
    {'1': 'isIncremental', '3': 5, '4': 1, '5': 8, '10': 'isIncremental'},
  ],
};

const SearchOutput$json = {
  '1': 'SearchOutput',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.Error', '10': 'error'},
    {'1': 'count', '3': 2, '4': 1, '5': 4, '10': 'count'},
    {
      '1': 'items',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.SearchResultItem',
      '10': 'items'
    },
  ],
};

const SearchResultItem$json = {
  '1': 'SearchResultItem',
  '2': [
    {
      '1': 'document',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Document',
      '10': 'document'
    },
    {'1': 'data', '3': 2, '4': 1, '5': 11, '6': '.Value', '10': 'data'},
    {'1': 'score', '3': 3, '4': 1, '5': 1, '10': 'score'},
  ],
};

const ReadInput$json = {
  '1': 'ReadInput',
  '2': [
    {
      '1': 'document',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Document',
      '10': 'document'
    },
  ],
};

const ReadOutput$json = {
  '1': 'ReadOutput',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.Error', '10': 'error'},
    {
      '1': 'document',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Document',
      '10': 'document'
    },
    {'1': 'exists', '3': 3, '4': 1, '5': 8, '10': 'exists'},
    {'1': 'data', '3': 4, '4': 1, '5': 11, '6': '.Value', '10': 'data'},
  ],
};

const WriteInput$json = {
  '1': 'WriteInput',
  '2': [
    {
      '1': 'document',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Document',
      '10': 'document'
    },
    {'1': 'type', '3': 2, '4': 1, '5': 14, '6': '.WriteType', '10': 'type'},
    {'1': 'value', '3': 3, '4': 1, '5': 11, '6': '.Value', '10': 'value'},
  ],
};

const WriteOutput$json = {
  '1': 'WriteOutput',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.Error', '10': 'error'},
  ],
};

const Error$json = {
  '1': 'Error',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 14, '6': '.ErrorCode', '10': 'code'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'stackTrace', '3': 4, '4': 1, '5': 9, '10': 'stackTrace'},
    {
      '1': 'collection',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.Collection',
      '10': 'collection'
    },
    {
      '1': 'document',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.Document',
      '10': 'document'
    },
  ],
};

const Query$json = {
  '1': 'Query',
  '2': [
    {'1': 'filterString', '3': 1, '4': 1, '5': 9, '10': 'filterString'},
    {'1': 'filter', '3': 2, '4': 1, '5': 11, '6': '.Filter', '10': 'filter'},
    {'1': 'sorters', '3': 3, '4': 3, '5': 9, '10': 'sorters'},
    {'1': 'schema', '3': 4, '4': 1, '5': 11, '6': '.Schema', '10': 'schema'},
    {'1': 'skip', '3': 5, '4': 1, '5': 3, '10': 'skip'},
    {'1': 'take', '3': 6, '4': 1, '5': 3, '10': 'take'},
  ],
};

const Filter$json = {
  '1': 'Filter',
};

const Schema$json = {
  '1': 'Schema',
};

const Collection$json = {
  '1': 'Collection',
  '2': [
    {'1': 'datastoreId', '3': 1, '4': 1, '5': 9, '10': 'datastoreId'},
    {'1': 'collectionId', '3': 2, '4': 1, '5': 9, '10': 'collectionId'},
  ],
};

const Document$json = {
  '1': 'Document',
  '2': [
    {'1': 'datastoreId', '3': 1, '4': 1, '5': 9, '10': 'datastoreId'},
    {'1': 'collectionId', '3': 2, '4': 1, '5': 9, '10': 'collectionId'},
    {'1': 'documentId', '3': 3, '4': 1, '5': 9, '10': 'documentId'},
  ],
};

const Value$json = {
  '1': 'Value',
  '2': [
    {'1': 'isNull', '3': 1, '4': 1, '5': 8, '10': 'isNull'},
    {'1': 'boolValue', '3': 2, '4': 1, '5': 8, '10': 'boolValue'},
    {'1': 'intValue', '3': 3, '4': 1, '5': 18, '10': 'intValue'},
    {'1': 'floatValue', '3': 4, '4': 1, '5': 1, '10': 'floatValue'},
    {
      '1': 'dateTimeValue',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.Timestamp',
      '10': 'dateTimeValue'
    },
    {
      '1': 'geoPoint',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.GeoPoint',
      '10': 'geoPoint'
    },
    {'1': 'stringValue', '3': 7, '4': 1, '5': 9, '10': 'stringValue'},
    {'1': 'bytesValue', '3': 8, '4': 1, '5': 12, '10': 'bytesValue'},
    {'1': 'emptyList', '3': 9, '4': 1, '5': 8, '10': 'emptyList'},
    {
      '1': 'listValue',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.Value',
      '10': 'listValue'
    },
    {
      '1': 'mapValue',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.Value.MapValueEntry',
      '10': 'mapValue'
    },
  ],
  '3': [Value_MapValueEntry$json],
};

const Value_MapValueEntry$json = {
  '1': 'MapValueEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.Value', '10': 'value'},
  ],
  '7': {'7': true},
};

const Timestamp$json = {
  '1': 'Timestamp',
  '2': [
    {'1': 'seconds', '3': 1, '4': 1, '5': 3, '10': 'seconds'},
    {'1': 'nanos', '3': 2, '4': 1, '5': 5, '10': 'nanos'},
  ],
};

const GeoPoint$json = {
  '1': 'GeoPoint',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
  ],
};
