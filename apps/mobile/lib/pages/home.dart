import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/core.dart';
import './user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final coreApi = Provider.of<CoreApi>(context, listen: false);
    coreApi.connect();
  }

  @override
  Widget build(BuildContext context) {
    final coreApi = Provider.of<CoreApi>(context);
    return Scaffold(
      appBar: AppBar(title: Text(coreApi.username)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              onChanged: (value) {
                setState(() {
                  _usernameController.text = value;
                });
              },
            ),
            TextButton(
              onPressed: _usernameController.text.isEmpty
                  ? null
                  : () async {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              UserPage(username: _usernameController.text),
                        ),
                      );
                    },
              child: const Text(
                'Chat with user',
              ),
            ),
            TextButton(
              onPressed: () async {
                await coreApi.logout();
              },
              child: const Text(
                'Logout',
              ),
            ),
            Text(
              'Connection: ${coreApi.isConnected}',
            ),
          ],
        ),
      ),
    );
  }
}
