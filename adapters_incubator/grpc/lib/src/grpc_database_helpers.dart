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

import 'package:database/database.dart';
import 'package:fixnum/fixnum.dart';

import 'generated/generated.pbgrpc.dart' as pb;

pb.Collection grpcCollectionFromDart(Collection collection) {
  return pb.Collection()..collectionId = collection.collectionId;
}

Collection grpcCollectionToDart(Database database, pb.Collection argument) {
  return database.collection(argument.collectionId);
}

pb.Document grpcDocumentFromDart(Document document) {
  return pb.Document()
    ..collectionId = document.parent.collectionId
    ..documentId = document.documentId;
}

Document grpcDocumentToDart(Database database, pb.Document argument) {
  return database
      .collection(argument.collectionId)
      .document(argument.documentId);
}

pb.Error grpcErrorFromDart(Object argument) {
  if (argument is DatabaseException) {
    return pb.Error()
      ..code = pb.ErrorCode.valueOf(argument.code)
      ..name = argument.name
      ..message = argument.message ?? argument.runtimeType.toString();
  }
  return pb.Error()
    ..code = pb.ErrorCode.unspecifiedError
    ..name = 'unspecified'
    ..message = argument.toString();
}

Object grpcErrorToDart(pb.Error argument) {
  return DatabaseException.custom(
    code: argument.code.value,
    name: argument.code.name,
    message: argument.message,
  );
}

pb.Query grpcQueryFromDart(Query argument) {
  final result = pb.Query();

  result.filterString = argument.filter?.toString() ?? '';

  final sorter = argument.sorter;
  if (sorter is PropertySorter) {
    final prefix = sorter.isDescending ? '>' : '<';
    final name = sorter.name;
    result.sorters.add('$prefix$name');
  } else if (sorter is MultiSorter) {
    for (var sorter in sorter.sorters) {
      if (sorter is PropertySorter) {
        final prefix = sorter.isDescending ? '>' : '<';
        final name = sorter.name;
        result.sorters.add('$prefix$name');
      }
    }
  }

  result.skip = Int64(argument.skip);

  final take = argument.take;
  if (take == null) {
    result.take = Int64(-1);
  } else {
    result.take = Int64(argument.take);
  }

  return result;
}

Query grpcQueryToDart(pb.Query argument) {
  //
  // Sorter
  //
  final sorters = <Sorter>[];
  for (var sorter in argument.sorters) {
    if (sorter.startsWith('<')) {
      sorters.add(PropertySorter(sorter.substring(1)));
    }
    if (sorter.startsWith('>')) {
      sorters.add(PropertySorter.descending(sorter.substring(1)));
    }
  }
  Sorter sorter;
  if (sorters.isNotEmpty) {
    if (sorters.length == 1) {
      sorter = sorters.single;
    } else {
      sorter = MultiSorter(sorters);
    }
  }

  //
  // Skip
  //
  final skip = argument.skip.toInt();

  //
  // Take
  //
  var take = argument.take.toInt();
  if (take == -1) {
    take = null;
  }

  return Query.parse(
    argument.filterString,
    sorter: sorter,
    skip: skip,
    take: take,
  );
}

pb.Value grpcValueFromDart(Object argument) {
  final grpcResult = pb.Value();
  if (argument == null) {
    grpcResult.isNull = true;
  } else if (argument is bool) {
    grpcResult.boolValue = argument;
  } else if (argument is int) {
    grpcResult.intValue = Int64(argument);
  } else if (argument is double) {
    grpcResult.floatValue = argument;
  } else if (argument is DateTime) {
    final secondsSinceEpoch = argument.millisecondsSinceEpoch ~/ 1000;
    grpcResult.dateTimeValue = pb.Timestamp()
      ..seconds = Int64(secondsSinceEpoch)
      ..nanos = (argument.microsecondsSinceEpoch.abs() % 1000000) * 1000;
  } else if (argument is String) {
    grpcResult.stringValue = argument;
  } else if (argument is Uint8List) {
    grpcResult.bytesValue = argument;
  } else if (argument is List) {
    if (argument.isEmpty) {
      grpcResult.emptyList = true;
    } else {
      for (var item in argument) {
        grpcResult.listValue.add(grpcValueFromDart(item));
      }
    }
  } else if (argument is Map) {
    final grpcMap = grpcResult.mapValue;
    for (var entry in argument.entries) {
      grpcMap[entry.key] = grpcValueFromDart(entry.value);
    }
  } else {
    throw ArgumentError.value(argument);
  }
  return grpcResult;
}

Object grpcValueToDart(pb.Value argument) {
  if (argument.isNull) {
    return null;
  }
  if (argument.hasBoolValue()) {
    return argument.boolValue;
  }
  if (argument.hasIntValue()) {
    return argument.intValue.toInt();
  }
  if (argument.hasFloatValue()) {
    return argument.floatValue;
  }
  if (argument.hasDateTimeValue()) {
    final grpcTimestamp = argument.dateTimeValue;
    return DateTime.fromMicrosecondsSinceEpoch(
      grpcTimestamp.seconds.toInt() * 1000000 + grpcTimestamp.nanos,
    );
  }
  if (argument.hasStringValue()) {
    return argument.stringValue;
  }
  if (argument.hasBytesValue()) {
    return Uint8List.fromList(argument.bytesValue);
  }
  if (argument.emptyList) {
    return const [];
  }
  final listValue = argument.listValue;
  if (listValue.isNotEmpty) {
    return List.unmodifiable(listValue.map(grpcValueToDart));
  }
  final mapValue = argument.mapValue;
  if (mapValue != null) {
    final result = <String, Object>{};
    for (var grpcEntry in mapValue.entries) {
      result[grpcEntry.key] = grpcValueToDart(grpcEntry.value);
    }
    return result;
  }
  throw ArgumentError.value(argument);
}
