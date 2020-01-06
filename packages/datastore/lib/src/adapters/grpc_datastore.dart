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

import 'dart:async';

import 'package:datastore/adapters_framework.dart';
import 'package:datastore/datastore.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:meta/meta.dart';

import 'internal/grpc_datastore_helpers.dart';
import 'internal/protos/datastore.pbgrpc.dart' as pb;

/// An adapter for using remote datastores by communicating over a
/// [GRPC](https://www.grpc.io) channel.
///
/// The server can be written any programming language. If the server uses Dart,
/// you can use [GrpcSearchServerService].
///
/// An example:
/// ```
/// import 'package:datastore/adapters.dart';
/// import 'package:datastore/datastore.dart';
///
/// void main() {
///   Datastore.freezeDefaultInstance(
///     GrpcDatastore(
///       host: 'localhost',
///       // port: 443,
///     ),
///   );
///   // ...
/// }
/// ```
class GrpcDatastore extends DatastoreAdapter {
  final pb.DatastoreServerClient client;

  /// Constructs an instance using [host] parameter.
  factory GrpcDatastore({
    @required String host,
    int port,
    grpc.ChannelOptions channelOptions,
  }) {
    ArgumentError.checkNotNull(host, 'host');
    return GrpcDatastore.withClientChannel(grpc.ClientChannel(
      host,
      port: port ?? 443,
      options: channelOptions ?? const grpc.ChannelOptions(),
    ));
  }

  /// Constructs an instance using [grpc.ClientChannel].
  GrpcDatastore.withClientChannel(
    grpc.ClientChannel clientChannel, {
    grpc.CallOptions options,
  }) : client = pb.DatastoreServerClient(
          clientChannel,
          options: options,
        );

  @override
  Stream<DatastoreExtensionResponse> performExtension(
      DatastoreExtensionRequest request) {
    return super.performExtension(request);
  }

  @override
  Stream<Snapshot> performRead(ReadRequest request) async* {
    //
    // Request
    //
    final document = request.document;
    final grpcRequest = pb.ReadInput()
      ..document = grpcDocumentFromDart(request.document);

    //
    // Dispatch
    //
    final grpcResponseStream = client.read(grpcRequest);

    //
    // Responses
    //
    await for (var grpcResponse in grpcResponseStream) {
      if (grpcResponse.hasError()) {
        throw grpcErrorToDart(grpcResponse.error);
      }
      yield (Snapshot(
        document: document,
        data: grpcResponse.exists ? grpcValueToDart(grpcResponse.data) : null,
        exists: grpcResponse.exists,
      ));
    }
  }

  @override
  Stream<QueryResult> performSearch(SearchRequest request) async* {
    //
    // Request
    //
    final collection = request.collection;
    final query = request.query;
    final grpcRequest = pb.SearchInput()
      ..collection = grpcCollectionFromDart(request.collection);

    //
    // Dispatch
    //
    final grpcResponseStream = client.search(grpcRequest);

    //
    // Responses
    //
    await for (var grpcResponse in grpcResponseStream) {
      if (grpcResponse.hasError()) {
        throw grpcErrorToDart(grpcResponse.error);
      }
      final items = List<QueryResultItem>.unmodifiable(
        grpcResponse.items.map((grpcItem) {
          final document = collection.document(
            grpcItem.document.documentId,
          );
          final data = grpcValueToDart(grpcItem.data);
          return QueryResultItem(
            snapshot: Snapshot(
              document: document,
              data: data as Map<String, Object>,
            ),
            score: grpcItem.score,
          );
        }),
      );
      yield (QueryResult.withDetails(
        collection: collection,
        query: query,
        items: items,
      ));
    }
  }

  @override
  Future<void> performWrite(WriteRequest request) async {
    //
    // Request
    //
    final grpcRequest = pb.WriteInput()
      ..document = grpcDocumentFromDart(request.document)
      ..type = grpcWriteTypeFromDart(request.type)
      ..value = grpcValueFromDart(request.data);

    //
    // Dispatch
    //
    final grpcResponse = await client.write(grpcRequest).last;
    if (grpcResponse.error != null) {
      throw grpcErrorToDart(grpcResponse.error);
    }
  }
}
