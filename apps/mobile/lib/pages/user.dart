import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/http.dart';
import '../components/chatmessagelist.dart';
import '../models/message.dart';

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
  bool online = false;
  Timer? _onlineTimer;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchOnline();
    _onlineTimer = Timer.periodic(Duration(seconds: 1), (_) => _fetchOnline());
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    super.dispose();
  }

  void _fetchOnline() async {
    final coreApi = Provider.of<CoreApi>(context, listen: false);
    final isOnline = await coreApi.userOnline(widget.username);
    setState(() {
      online = isOnline;
    });
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.username),
            if (online)
              Text(
                "Online",
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
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
