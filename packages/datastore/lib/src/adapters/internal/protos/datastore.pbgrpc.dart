///
//  Generated code. Do not modify.
//  source: datastore.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'datastore.pb.dart' as $0;
export 'datastore.pb.dart';

class DatastoreServerClient extends $grpc.Client {
  static final _$search = $grpc.ClientMethod<$0.SearchInput, $0.SearchOutput>(
      '/DatastoreServer/search',
      ($0.SearchInput value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SearchOutput.fromBuffer(value));
  static final _$read = $grpc.ClientMethod<$0.ReadInput, $0.ReadOutput>(
      '/DatastoreServer/read',
      ($0.ReadInput value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ReadOutput.fromBuffer(value));
  static final _$write = $grpc.ClientMethod<$0.WriteInput, $0.WriteOutput>(
      '/DatastoreServer/write',
      ($0.WriteInput value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.WriteOutput.fromBuffer(value));

  DatastoreServerClient($grpc.ClientChannel channel,
      {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseStream<$0.SearchOutput> search($0.SearchInput request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$search, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.ReadOutput> read($0.ReadInput request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$read, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.WriteOutput> write($0.WriteInput request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$write, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseStream(call);
  }
}

abstract class DatastoreServerServiceBase extends $grpc.Service {
  $core.String get $name => 'DatastoreServer';

  DatastoreServerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SearchInput, $0.SearchOutput>(
        'search',
        search_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SearchInput.fromBuffer(value),
        ($0.SearchOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReadInput, $0.ReadOutput>(
        'read',
        read_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.ReadInput.fromBuffer(value),
        ($0.ReadOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WriteInput, $0.WriteOutput>(
        'write',
        write_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.WriteInput.fromBuffer(value),
        ($0.WriteOutput value) => value.writeToBuffer()));
  }

  $async.Stream<$0.SearchOutput> search_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SearchInput> request) async* {
    yield* search(call, await request);
  }

  $async.Stream<$0.ReadOutput> read_Pre(
      $grpc.ServiceCall call, $async.Future<$0.ReadInput> request) async* {
    yield* read(call, await request);
  }

  $async.Stream<$0.WriteOutput> write_Pre(
      $grpc.ServiceCall call, $async.Future<$0.WriteInput> request) async* {
    yield* write(call, await request);
  }

  $async.Stream<$0.SearchOutput> search(
      $grpc.ServiceCall call, $0.SearchInput request);
  $async.Stream<$0.ReadOutput> read(
      $grpc.ServiceCall call, $0.ReadInput request);
  $async.Stream<$0.WriteOutput> write(
      $grpc.ServiceCall call, $0.WriteInput request);
}
