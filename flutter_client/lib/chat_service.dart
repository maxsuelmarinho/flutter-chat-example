import 'package:grpc/grpc.dart';
import 'api/v1/chat.pbgrpc.dart' as grpc;
import 'api/v1/google/protobuf/empty.pb.dart';
import 'api/v1/google/protobuf/wrappers.pb.dart';
import 'chat_message.dart';
import 'chat_message_outgoing.dart';

const serverIP = "127.0.0.1";
const serverPort = 3000;

class ChatService {
  bool _isShutdown = false;

  /// gRPC client channel to send messages to the server
  ClientChannel _clientSend;

  /// gRPC client channel to receive messages from the server
  ClientChannel _clientReceive;

  final void Function(MessageOutgoing message) onSentSuccess;

  final void Function(MessageOutgoing message, String error) onSentError;

  final void Function(Message message) onReceivedSuccess;

  final void Function(String error) onReceivedError;

  ChatService({this.onSentSuccess,this.onSentError, this.onReceivedSuccess, this.onReceivedError});

  Future<void> shutdown() async {
    _isShutdown = true;
    _shutdownSend();
    _shutdownReceive();
  }

  void _shutdownSend() {
    if (_clientSend != null) {
      _clientSend.shutdown();
      _clientSend = null;
    }
  }

  void _shutdownReceive() {
    if (_clientReceive != null) {
      _clientReceive.shutdown();
      _clientReceive = null;
    }
  }

  void send(MessageOutgoing message) {
    if (_clientSend == null) {
      _clientSend = ClientChannel(
        serverIP,
        port:serverPort,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        )
      );

      var request = StringValue.create();
      request.value = message.text;

      grpc.ChatServiceClient(_clientSend).send(request).then((_) {
        if (onSentSuccess != null) {
          var sentMessage = MessageOutgoing(
            text: message.text, 
            id: message.id, 
            status: MessageOutgoindStatus.SENT);
          onSentSuccess(sentMessage);
        }
      }).catchError((e) {
        if (!_isShutdown) {
          // invalidate current client
          _shutdownSend();

          if (onSentError != null) {
            onSentError(message, e.toString());
          }

          // try to send again
          Future.delayed(Duration(seconds: 30), () {
            send(message);
          });
        }
      });
    }
  }

  void startListening() {
    if (_clientReceive == null) {
      _clientReceive = ClientChannel(
        serverIP,
        port:serverPort,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        )
      );

      var stream =grpc.ChatServiceClient(_clientReceive).subscribe(Empty.create());

      stream.forEach((msg) {
        if (onReceivedSuccess != null) {
          var message = Message(msg.text);
          onReceivedSuccess(message);
        }
      }).then((_) {
        throw Exception("stream from the server has been closed");
      }).catchError((e) {
        if (!_isShutdown) {
          // invalidate current client
          _shutdownReceive();

          if (onReceivedError != null) {
            onReceivedError(e.toString());
          }

          // start listening again
          Future.delayed(Duration(seconds: 30), () {
            startListening();
          });
        }
      });
    }
  }
}