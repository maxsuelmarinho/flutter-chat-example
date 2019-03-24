import 'package:flutter/material.dart';
import 'chat_message.dart';

const String _name = "Me";

/// UNKNOWN - message just created and is not sent yet
/// SENT - message is sent to the server successfully
enum MessageOutgoindStatus {UNKNOWN, SENT}

class MessageOutgoing extends Message {
  MessageOutgoindStatus status;

  MessageOutgoing({String text, String id, this.status =MessageOutgoindStatus.UNKNOWN})
    : super(text, id);
}

class ChatMessageOutgoingController {
  MessageOutgoing message;

  void Function(MessageOutgoindStatus oldStatus, MessageOutgoindStatus newStatus) onStatusChanged;

  ChatMessageOutgoingController({this.message});

  void setStatus(MessageOutgoindStatus newStatus) {
    var oldStatus = message.status;
    if (oldStatus != newStatus) {
      message.status = newStatus;
      if (onStatusChanged != null) {
        onStatusChanged(oldStatus, newStatus);
      }
    }
  }
}

class ChatMessageOutgoing extends StatefulWidget implements ChatMessage {
  final MessageOutgoing message;
  final ChatMessageOutgoingController controller;
  final AnimationController animationController;

  ChatMessageOutgoing({this.message, this.animationController})
    :controller =ChatMessageOutgoingController(message: message), super(key: new ObjectKey(message.id));

  @override
  State createState() => ChatMessageOutgoingState(animationController:animationController, controller:controller);
}

class ChatMessageOutgoingState extends State<ChatMessageOutgoing> {
  final ChatMessageOutgoingController controller;
  final AnimationController animationController;

  ChatMessageOutgoingState({this.controller, this.animationController}) {
    controller.onStatusChanged = onStatusChanged;
  }

  void onStatusChanged(MessageOutgoindStatus oldStatus, MessageOutgoindStatus newStatus) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_name, style: Theme.of(context).textTheme.subhead),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(controller.message.text),
                  ),
                ],
              ),
            ),
            Container(
              child: Icon(
                controller.message.status ==MessageOutgoindStatus.SENT ? Icons.done : Icons.access_time,
              ),
            ),
          ],
        ),
      ),
    );
  }
}