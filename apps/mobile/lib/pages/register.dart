import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../helpers/constants.dart';

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
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text("Connected to $baseUrl"),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
            ),
            TextButton(
              onPressed: () async {
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
