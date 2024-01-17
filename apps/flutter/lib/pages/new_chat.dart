import 'package:flutter/material.dart';

import 'user.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final _usernameController = TextEditingController();

  Future<void> _openUserPage(String username) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => UserPage(username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter a user")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
            ),
            TextButton(
              onPressed: () => _openUserPage(_usernameController.text),
              child: const Text(
                'Chat with user',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
