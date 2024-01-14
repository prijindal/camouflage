import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/http.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../models/message.dart';
import 'chatmessage.dart';

class ChatMessagesList extends StatefulWidget {
  const ChatMessagesList({super.key, required this.user});
  final UserResponse user;

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  List<DisplayMessage> _messages = [];
  StreamSubscription<List<MessageData>>? _subscription;

  @override
  void initState() {
    super.initState();
    _addWatcher();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _addWatcher() {
    _subscription = (MyDatabase.instance.message.select()
          ..where((tbl) => tbl.username.equals(widget.user.username))
          ..orderBy(
            [
              (u) => drift.OrderingTerm(
                    expression: u.sentAt,
                    mode: drift.OrderingMode.desc,
                  )
            ],
          ))
        .watch()
        .listen((event) async {
      final coreApi = Provider.of<CoreApi>(context, listen: false);
      final List<DisplayMessage> messages = [];
      for (var element in event) {
        final parsed = await coreApi.decryptMessageData(
          element,
          widget.user.publicKey,
        );
        messages.add(
          DisplayMessage(
            direction: element.direction,
            type: parsed.type,
            body: parsed.body,
            sentAt: element.sentAt,
            receivedAt: element.receivedAt,
            readAt: element.readAt,
          ),
        );
      }
      setState(() {
        _messages = messages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      shrinkWrap: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ChatMessage(
          message: message,
        );
      },
    );
  }
}
