import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/core.dart';
import '../api/http.dart';

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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );
      await coreApi.sendMessage(
        payload: jsonEncode({"type": "text", "body": _textController.text}),
        username: widget.user.username,
        publicKey: widget.user.publicKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) {
              return const ListTile(
                title: Text("Example chat message"),
              );
            },
          ),
        ),
        Flexible(
          flex: 0,
          child: Form(
            key: _formKey,
            child: Expanded(
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
