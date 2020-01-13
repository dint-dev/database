///
import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;

import 'generated.pb.dart' as _lib0;

export 'generated.pb.dart';

class DatabaseServerClient extends $grpc.Client {
  static final _$search =
      $grpc.ClientMethod<_lib0.SearchInput, _lib0.SearchOutput>(
          '/DatabaseServer/search',
          (_lib0.SearchInput value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              _lib0.SearchOutput.fromBuffer(value));
  static final _$read = $grpc.ClientMethod<_lib0.ReadInput, _lib0.ReadOutput>(
      '/DatabaseServer/read',
      (_lib0.ReadInput value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => _lib0.ReadOutput.fromBuffer(value));
  static final _$write =
      $grpc.ClientMethod<_lib0.WriteInput, _lib0.WriteOutput>(
          '/DatabaseServer/write',
          (_lib0.WriteInput value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => _lib0.WriteOutput.fromBuffer(value));

  DatabaseServerClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseStream<_lib0.ReadOutput> read(_lib0.ReadInput request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$read, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<_lib0.SearchOutput> search(_lib0.SearchInput request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$search, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<_lib0.WriteOutput> write(_lib0.WriteInput request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$write, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseStream(call);
  }
}

abstract class DatabaseServerServiceBase extends $grpc.Service {
  DatabaseServerServiceBase() {
    $addMethod($grpc.ServiceMethod<_lib0.SearchInput, _lib0.SearchOutput>(
        'search',
        search_Pre,
        false,
        true,
        ($core.List<$core.int> value) => _lib0.SearchInput.fromBuffer(value),
        (_lib0.SearchOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<_lib0.ReadInput, _lib0.ReadOutput>(
        'read',
        read_Pre,
        false,
        true,
        ($core.List<$core.int> value) => _lib0.ReadInput.fromBuffer(value),
        (_lib0.ReadOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<_lib0.WriteInput, _lib0.WriteOutput>(
        'write',
        write_Pre,
        false,
        true,
        ($core.List<$core.int> value) => _lib0.WriteInput.fromBuffer(value),
        (_lib0.WriteOutput value) => value.writeToBuffer()));
  }

  @$core.override
  $core.String get $name => 'DatabaseServer';

  $async.Stream<_lib0.ReadOutput> read(
      $grpc.ServiceCall call, _lib0.ReadInput request);

  $async.Stream<_lib0.ReadOutput> read_Pre(
      $grpc.ServiceCall call, $async.Future<_lib0.ReadInput> request) async* {
    yield* read(call, await request);
  }

  $async.Stream<_lib0.SearchOutput> search(
      $grpc.ServiceCall call, _lib0.SearchInput request);

  $async.Stream<_lib0.SearchOutput> search_Pre(
      $grpc.ServiceCall call, $async.Future<_lib0.SearchInput> request) async* {
    yield* search(call, await request);
  }

  $async.Stream<_lib0.WriteOutput> write(
      $grpc.ServiceCall call, _lib0.WriteInput request);
  $async.Stream<_lib0.WriteOutput> write_Pre(
      $grpc.ServiceCall call, $async.Future<_lib0.WriteInput> request) async* {
    yield* write(call, await request);
  }
}
