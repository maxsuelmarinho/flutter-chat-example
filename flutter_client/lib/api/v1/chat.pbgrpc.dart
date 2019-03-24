///
//  Generated code. Do not modify.
//  source: chat.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

import 'dart:async' as $async;

import 'package:grpc/service_api.dart' as $grpc;
import 'google/protobuf/wrappers.pb.dart' as $0;
import 'google/protobuf/empty.pb.dart' as $1;
import 'chat.pb.dart';
export 'chat.pb.dart';

class ChatServiceClient extends $grpc.Client {
  static final _$send = new $grpc.ClientMethod<$0.StringValue, $1.Empty>(
      '/v1.ChatService/Send',
      ($0.StringValue value) => value.writeToBuffer(),
      (List<int> value) => new $1.Empty.fromBuffer(value));
  static final _$subscribe = new $grpc.ClientMethod<$1.Empty, Message>(
      '/v1.ChatService/Subscribe',
      ($1.Empty value) => value.writeToBuffer(),
      (List<int> value) => new Message.fromBuffer(value));

  ChatServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$1.Empty> send($0.StringValue request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$send, new $async.Stream.fromIterable([request]),
        options: options);
    return new $grpc.ResponseFuture(call);
  }

  $grpc.ResponseStream<Message> subscribe($1.Empty request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$subscribe, new $async.Stream.fromIterable([request]),
        options: options);
    return new $grpc.ResponseStream(call);
  }
}

abstract class ChatServiceBase extends $grpc.Service {
  String get $name => 'v1.ChatService';

  ChatServiceBase() {
    $addMethod(new $grpc.ServiceMethod<$0.StringValue, $1.Empty>(
        'Send',
        send_Pre,
        false,
        false,
        (List<int> value) => new $0.StringValue.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(new $grpc.ServiceMethod<$1.Empty, Message>(
        'Subscribe',
        subscribe_Pre,
        false,
        true,
        (List<int> value) => new $1.Empty.fromBuffer(value),
        (Message value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> send_Pre(
      $grpc.ServiceCall call, $async.Future request) async {
    return send(call, await request);
  }

  $async.Stream<Message> subscribe_Pre(
      $grpc.ServiceCall call, $async.Future request) async* {
    yield* subscribe(call, (await request) as $1.Empty);
  }

  $async.Future<$1.Empty> send($grpc.ServiceCall call, $0.StringValue request);
  $async.Stream<Message> subscribe($grpc.ServiceCall call, $1.Empty request);
}
