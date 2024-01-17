import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coreApi = Provider.of<CoreApi>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Loading..."),
            Text(
              "Connecting to ${coreApi.baseUrl}",
            ),
          ],
        ),
      ),
    );
  }
}
