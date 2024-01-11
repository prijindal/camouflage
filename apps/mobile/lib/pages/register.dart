import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/core.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final coreApi = Provider.of<CoreApi>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login"),
      ),
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
                      await coreApi.register(_usernameController.text);
                    },
              child: const Text(
                'Register',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
