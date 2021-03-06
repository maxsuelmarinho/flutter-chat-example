import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_message.dart';
import 'chat_message_incoming.dart';
import 'chat_message_outgoing.dart';
import 'chat_service.dart';
import 'bandwidth_buffer.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(): super(key: new ObjectKey("Main window"));

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  ChatService _service;
  BandwidthBuffer _bandwidthBuffer;
  final StreamController _streamController =StreamController<List<Message>>();

  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController =TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    _bandwidthBuffer = BandwidthBuffer<Message>(
      duration: Duration(milliseconds: 500), 
      onReceive: onReceivedFromBuffer
    );
    _bandwidthBuffer.start();

    _service = ChatService(
      onSentSuccess: onSentSuccess,
      onSentError: onSentError,
      onReceivedSuccess: onReceivedSuccess,
      onReceivedError: onReceivedError, 
    );
    _service.startListening();
  }

  @override
  void dispose() {
    _service.shutdown();

    _bandwidthBuffer.stop();

    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("friendlychat")),
      body: Column(
        children: <Widget>[
          Flexible(
            child: StreamBuilder<List<Message>>(
              stream: _streamController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    _addMessages(snapshot.data);
                }
                return ListView.builder(
                  padding:EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length
                );
              },
            ),
          ),
          Divider(height: 1.0,),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data:IconThemeData(
        color: Theme.of(context).accentColor
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                maxLines: null,
                textInputAction: TextInputAction.send,
                controller:_textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted: null,
                decoration:InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed:_isComposing ? () => _handleSubmitted(_textController.text) : null
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    _isComposing = false;

    var message =MessageOutgoing(text: text);

    // send message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(message);

    _service.send(message);
  }

  void onSentSuccess(MessageOutgoing message) {
    debugPrint("message \"${message.text}\" sent to the server");
    _bandwidthBuffer.send(message);
  }

  void onSentError(Message message, String error) {
    debugPrint("FAILED to send message \"${message.text}\" to the server: $error");
  }

  void onReceivedSuccess(Message message) {
    debugPrint("received message from the server: ${message.text}");
    _bandwidthBuffer.send(message);
  }

  void onReceivedError(String error) {
    debugPrint("FAILED to receive messages from the server: $error");
  }

  void onReceivedFromBuffer(List<Message> messages) {
    _streamController.add(messages);
  }

  void _addMessages(List<Message> messages) {
    messages.forEach((message) {
      var i = _messages.indexWhere((msg) => msg.message.id == message.id);
      if (i != -1) {
        var chatMessage = _messages[i];
        if (chatMessage is ChatMessageOutgoing) {
          assert(message is MessageOutgoing, "message must be MessageOutgoing type");
          chatMessage.controller.setStatus((message as MessageOutgoing).status);
        }
      } else {
        ChatMessage chatMessage;
        var animationControoler =AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this
        );

        switch(message.runtimeType) {
          case MessageOutgoing:
            chatMessage = ChatMessageOutgoing(
              message:message,
              animationController: animationControoler,
            );
            break;
          default:
            chatMessage =ChatMessageIncoming(
              message: message,
              animationController: animationControoler,
            );
            break;
        }

        _messages.insert(0, chatMessage);

        chatMessage.animationController.forward();
      }
    });
  }
}