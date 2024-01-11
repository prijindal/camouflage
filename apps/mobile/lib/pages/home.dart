import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/core.dart';
import '../helpers/logger.dart';

class MyAppWidet extends StatefulWidget {
  const MyAppWidet({super.key});

  @override
  State<MyAppWidet> createState() => _MyAppWidetState();
}

class _MyAppWidetState extends State<MyAppWidet> {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                final username = "prijindal";
                final user = await coreApi.getUser(username);
                AppLogger.instance.d(user.username);
                AppLogger.instance.d(user.publicKey);
              },
              child: const Text(
                'Get User',
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
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final coreApi = Provider.of<CoreApi>(context);
    if (coreApi.isLoading) {
      return const Scaffold(
        body: Center(
          child: Text("Loading..."),
        ),
      );
    }
    if (coreApi.isLoggedIn) {
      return const MyAppWidet();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                final username = "prijindal";
                await coreApi.register(username);
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
