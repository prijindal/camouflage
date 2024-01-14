import 'package:flutter/material.dart';

import '../helpers/constants.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Loading..."),
            Text(
              "Connecting to $baseUrl",
            ),
          ],
        ),
      ),
    );
  }
}
