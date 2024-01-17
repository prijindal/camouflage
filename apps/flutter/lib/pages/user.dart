import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/http.dart';
import '../components/chatform.dart';
import '../components/chatmessagelist.dart';

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
  @override
  void initState() {
    super.initState();
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
        ChatForm(user: widget.user),
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
    _onlineTimer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchOnline());
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
