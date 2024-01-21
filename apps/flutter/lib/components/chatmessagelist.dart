import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/http.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../models/message.dart';
import '../models/payloads.dart';
import 'chatmessage.dart';

class ChatMessagesList extends StatefulWidget {
  const ChatMessagesList({super.key, required this.user});
  final UserResponse user;

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList>
    with WidgetsBindingObserver {
  List<DisplayMessage> _messages = [];
  StreamSubscription<List<MessageData>>? _subscription;
  AppLifecycleState? _notification;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _addWatcher();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
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
        unawaited(_markRead(element));
      }
      setState(() {
        _messages = messages;
      });
    });
  }

  bool get _isLifecycleActive =>
      _notification == null || _notification == AppLifecycleState.resumed;

  Future<void> _markRead(MessageData message) async {
    if (_isLifecycleActive &&
        message.readAt == null &&
        message.direction == MessageDirection.received) {
      final coreApi = Provider.of<CoreApi>(context, listen: false);
      final receivedPayload = ReceivedMessagePayload(
        messageId: message.id,
        timestamp: DateTime.now().toIso8601String(),
        username: message.username,
      );
      await coreApi.readMessage(
        payload: receivedPayload,
      );
      await onReadHandlerOnDb(receivedPayload);
    }
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
