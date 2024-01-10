import 'dart:convert';

import 'package:camouflage/api/http.dart';
import 'package:camouflage/encryption/key.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                final username = "prijindal";
                final masterKey = generateMasterKey();
                final masterHash = await getMasterHash(username, masterKey);
                final algorithm = X25519();
                final keyPair = await algorithm.newKeyPair();
                final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
                final publicKey = await keyPair.extractPublicKey();
                final publicKeyBytes = publicKey.bytes;

                final response = await ApiHttpClient.instance.register(
                  username: username,
                  master_hash: masterHash,
                  public_key: base64Encode(publicKeyBytes),
                );
                // Save token, username,publicKeyBytes and privateKeyBytes in local storage
                print(response.token);
                final user = await ApiHttpClient.instance.getUser(
                  username: username,
                  token: response.token,
                );
                print(user.username);
                print(user.publicKey);
              },
              child: const Text(
                'You have pushed the button this many times:',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
