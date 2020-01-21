import 'dart:io';

void main() {
  const name = 'copy_of_database_adapter_tester.dart';

  // Skip: Algolia (doesn't use it)

  _copy(
    'adapters/elasticsearch/test/$name',
  );
  _copy(
    'adapters/firestore_browser/test/$name',
  );
  _copy(
    'adapters/firestore_flutter/example/test_driver/$name',
    isFlutter: true,
  );
  _copy(
    'adapters/postgre/test/$name',
  );
  _copy(
    'adapters/sqlite/example/test_driver/$name',
    isFlutter: true,
  );

  _copy(
    'adapters_incubator/azure/test/$name',
  );
  _copy(
    'adapters_incubator/grpc/test/$name',
  );
}

void _copy(String dest, {bool isFlutter = false}) {
  var source = File.fromUri(Platform.script.resolve(
    '../database/test/database_adapter_tester.dart',
  )).readAsStringSync();
  if (isFlutter) {
    source = source.replaceAll(
      'package:test/test.dart',
      'package:flutter_test/flutter_test.dart',
    );
  }
  print('Copying to: $dest');
  File(dest).writeAsStringSync(source);
}
