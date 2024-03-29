import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/core.dart';
import '../models/message.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key, required this.message});
  final DisplayMessage message;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool _isExpanded = false;

  DisplayMessage get message => widget.message;

  Widget _status() {
    final IconData icon;
    if (message.sentAt == null) {
      icon = Icons.pending;
    } else if (message.receivedAt == null) {
      icon = Icons.done;
    } else {
      icon = Icons.done_all;
    }
    // print(message.readAt);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Icon(
        icon,
        size: 16,
        color: message.readAt == null ? null : Colors.green,
      ),
    );
  }

  double get messageMaxWidth {
    return min(400, MediaQuery.of(context).size.width - 100);
  }

  Widget _renderMessage() {
    if (message.type == MessageType.text) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(String.fromCharCodes(message.body)),
          if (message.direction == MessageDirection.sent) _status(),
        ],
      );
    } else if (message.type == MessageType.image) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.memory(
            message.body,
            scale: 1,
            width: messageMaxWidth,
          ),
          if (message.direction == MessageDirection.sent) _status(),
        ],
      );
    }
    return const Text("Invalid message");
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      title: Column(
        crossAxisAlignment: message.direction == MessageDirection.sent
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.direction == MessageDirection.sent
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(10, 10),
                  ),
                ),
                child: _renderMessage(),
              ),
            ],
          ),
          if (_isExpanded && message.sentAt != null)
            Text(
              timeago.format(message.sentAt!),
              style: Theme.of(context).textTheme.labelMedium,
            ),
        ],
      ),
    );
  }
}
