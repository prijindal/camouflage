import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/http.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../models/message.dart';

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
          ..where((tbl) => tbl.username.equals(widget.user.username)))
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
      shrinkWrap: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ListTile(
          title: Row(
            mainAxisAlignment: message.direction == MessageDirection.sent
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(String.fromCharCodes(message.body)),
            ],
          ),
        );
      },
    );
  }
}

class UserChat extends StatefulWidget {
  const UserChat({
    super.key,
    required this.user,
  });
  final UserResponse user;

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  Future<void> _sendChatMessage() async {
    final coreApi = Provider.of<CoreApi>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      final body = Uint8List.fromList(_textController.text.codeUnits);
      _textController.clear();
      await coreApi.sendMessage(
        payload: ParsedMessage(
          type: MessageType.text,
          body: body,
        ),
        username: widget.user.username,
        publicKey: widget.user.publicKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          flex: 1,
          child: ChatMessagesList(user: widget.user),
        ),
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter some text";
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  onPressed: _sendChatMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.username});
  final String username;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  String? error;
  UserResponse? user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final coreApi = Provider.of<CoreApi>(context, listen: false);
      final fetchedUser = await coreApi.getUser(widget.username);
      setState(() {
        isLoading = false;
        user = fetchedUser;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: isLoading
          ? const Center(
              child: Text("Loading..."),
            )
          : user == null || error != null
              ? Center(
                  child: Text(error ?? "User not found"),
                )
              : UserChat(user: user!),
    );
  }
}
