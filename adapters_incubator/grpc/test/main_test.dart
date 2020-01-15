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

import 'dart:typed_data';

import 'package:database/database.dart';
import 'package:database_adapter_grpc/database_adapter_grpc.dart';
import 'package:database_adapter_grpc/src/grpc_database_helpers.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:grpc/service_api.dart' as grpc;
import 'package:http2/http2.dart' as http2;
import 'package:test/test.dart';

import 'copy_of_database_adapter_tester.dart';

Future<void> main() async {
  final newDatabase = () async {
    //
    // Define server
    //
    final serverService = GrpcSearchServerService(
      database: MemoryDatabase(),
      onError: (call, request, error, stackTrace) {
        print('Error: $error');
      },
    );
    final server = grpc.Server(<grpc.Service>[serverService]);
    await server.serve(
      address: 'localhost',
      port: 0,
      http2ServerSettings: http2.ServerSettings(),
    );
    addTearDown(() {
      server.shutdown();
    });

    //
    // Define client
    //
    return GrpcDatabase(
      host: 'localhost',
      port: server.port,
      channelOptions: grpc.ChannelOptions(
        credentials: grpc.ChannelCredentials.insecure(),
      ),
    );
  };

  DatabaseAdapterTester(newDatabase).run();

  group('encoding/decoding data:', () {
    test('null', () {
      final encoded = grpcValueFromDart(null);
      final decoded = grpcValueToDart(encoded);
      expect(decoded, null);
    });
    test('bool: false', () {
      final encoded = grpcValueFromDart(false);
      final decoded = grpcValueToDart(encoded);
      expect(decoded, false);
    });
    test('bool: true', () {
      final encoded = grpcValueFromDart(true);
      final decoded = grpcValueToDart(encoded);
      expect(decoded, true);
    });
    test('int', () {
      final encoded = grpcValueFromDart(42);
      final decoded = grpcValueToDart(encoded);
      expect(decoded, 42);
    });
    test('float', () {
      final encoded = grpcValueFromDart(3.14);
      final decoded = grpcValueToDart(encoded);
      expect(decoded, 3.14);
    });
    test('dateTime', () {
      final encoded = grpcValueFromDart(DateTime(2019, 12, 31));
      final decoded = grpcValueToDart(encoded);
      expect(decoded, DateTime(2019, 12, 31));
    });
    test('string', () {
      final encoded = grpcValueFromDart('abc');
      final decoded = grpcValueToDart(encoded);
      expect(decoded, 'abc');
    });
    test('bytes', () {
      final encoded = grpcValueFromDart(Uint8List.fromList([1, 2, 3]));
      final decoded = grpcValueToDart(encoded);
      expect(decoded, Uint8List.fromList([1, 2, 3]));
    });
    test('list: empty', () {
      final encoded = grpcValueFromDart([]);
      final decoded = grpcValueToDart(encoded);
      expect(decoded, []);
    });
    test('list: 3 items', () {
      final encoded = grpcValueFromDart(['a', 'b', 'c']);
      final decoded = grpcValueToDart(encoded);
      expect(decoded, ['a', 'b', 'c']);
    });
    test('map: empty', () {
      final encoded = grpcValueFromDart({});
      final decoded = grpcValueToDart(encoded);
      expect(decoded, {});
    });
    test('map: 2 entries', () {
      final encoded = grpcValueFromDart({'k0': 'v0', 'k1': 3.14});
      final decoded = grpcValueToDart(encoded);
      expect(decoded, {'k0': 'v0', 'k1': 3.14});
    });
    test('other', () {
      final invalidValue = () => null;
      expect(
        () => grpcValueFromDart(invalidValue),
        throwsArgumentError,
      );
    });
  });
}
