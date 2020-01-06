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
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:meta/meta.dart';

import 'internal/grpc_datastore_helpers.dart';
import 'internal/protos/datastore.pbgrpc.dart' as pb;

typedef GrpcSearchServerServiceErrorHandler = void Function(
  grpc.ServiceCall serviceCall,
  Object request,
  Object error,
  StackTrace stackTrace,
);

/// A [GRPC](https://www.grpc.io) service that exposes any implementation of
/// [Datastore].
///
/// The GRPC service definition can be found [in Github](https://github.com/terrier989/datastore).
///
/// An example of usage:
/// ```dart
/// import 'package:grpc/grpc.dart';
/// import 'package:datastore_adapter_grpc/server.dart';
///
/// Future<void> main() async {
///   // Construct a GRPC service
///   final serverService = GrpcSearchServerService(
///     datastore: Datastore.defaultInstance,
///   );
///
///   // Construct a GRPC server
///   final server = grpc.Server(<grpc.Service>[
///     serverService,
///   ]);
///
///   // Serve
///   await server.serve(
///     address: 'localhost',
///     port: 0,
///   );
/// }
/// ```
class GrpcSearchServerService extends pb.DatastoreServerServiceBase {
  final Datastore datastore;
  final GrpcSearchServerServiceErrorHandler onError;

  GrpcSearchServerService({
    @required this.datastore,
    this.onError,
  }) {
    ArgumentError.checkNotNull(datastore, 'datastore');
  }

  @override
  Stream<pb.ReadOutput> read(
    grpc.ServiceCall call,
    pb.ReadInput grpcRequest,
  ) async* {
    try {
      //
      // Request
      //
      final document = grpcDocumentToDart(datastore, grpcRequest.document);

      //
      // Dispatch
      //
      final snapshotStream = document.getIncrementalStream();

      //
      // Response
      //
      await for (var snapshot in snapshotStream) {
        final grpcOutput = pb.ReadOutput();
        grpcOutput.document = grpcDocumentFromDart(snapshot.document);
        grpcOutput.exists = snapshot.exists;
        if (snapshot.exists) {
          grpcOutput.data = grpcValueFromDart(snapshot.data);
        }
        yield (grpcOutput);
      }
    } catch (error, stackTrace) {
      _reportError(call, grpcRequest, error, stackTrace);
      yield (pb.ReadOutput()..error = grpcErrorFromDart(error));
    }
  }

  @override
  Stream<pb.SearchOutput> search(
    grpc.ServiceCall call,
    pb.SearchInput grpcRequest,
  ) async* {
    try {
      //
      // Request
      //
      final request = SearchRequest(
        collection: grpcCollectionToDart(
          datastore,
          grpcRequest.collection,
        ),
        query: grpcQueryToDart(grpcRequest.query),
      );

      //
      // Dispatch
      //
      final responseStream = request.delegateTo(datastore);

      //
      // Response
      //
      await for (var response in responseStream) {
        // Yield a protocol buffers message
        final grpcOutput = pb.SearchOutput()
          ..items.addAll(response.items.map((item) {
            return pb.SearchResultItem()
              ..document = grpcDocumentFromDart(item.document)
              ..data = grpcValueFromDart(item.data)
              ..score = item.score;
          }));
        final count = response.count;
        if (count != null) {
          grpcOutput.count = Int64(count);
        }
        yield (grpcOutput);
      }
    } catch (error, stackTrace) {
      _reportError(call, grpcRequest, error, stackTrace);
      yield (pb.SearchOutput()..error = grpcErrorFromDart(error));
    }
  }

  @override
  Stream<pb.WriteOutput> write(
    grpc.ServiceCall call,
    pb.WriteInput grpcRequest,
  ) async* {
    try {
      final request = WriteRequest(
        document: grpcDocumentToDart(datastore, grpcRequest.document),
        type: grpcWriteTypeToDart(grpcRequest.type),
        data: grpcValueToDart(grpcRequest.value),
      );
      await request.delegateTo(datastore);
      yield (pb.WriteOutput());
    } catch (error, stackTrace) {
      _reportError(call, grpcRequest, error, stackTrace);
      yield (pb.WriteOutput()..error = grpcErrorFromDart(error));
    }
  }

  /// Calls [onError] if it's non-null.
  void _reportError(grpc.ServiceCall call, Object request, Object error,
      StackTrace stackTrace) {
    if (onError != null) {
      onError(call, request, error, stackTrace);
    }
  }
}
