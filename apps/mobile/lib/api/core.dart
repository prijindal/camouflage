import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../encryption/key.dart';
import '../helpers/logger.dart';
import './http.dart';
import './socket.dart';

class CoreApi with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool isLoading = false;
  String? _token;
  String? _username;
  String? _publicKey;
  String? _privateKey;

  CoreApi() {
    readFromSecureStorage();
  }

  Future<void> readFromSecureStorage() async {
    isLoading = true;
    notifyListeners();
    _token = await storage.read(key: "token");
    _username = await storage.read(key: "username");
    _publicKey = await storage.read(key: "publicKey");
    _privateKey = await storage.read(key: "privateKey");
    AppLogger.instance.d("Read from secure storage: $_token");
    isLoading = false;
    notifyListeners();
  }

  Future<void> writeToSecureStorage() async {
    isLoading = true;
    notifyListeners();
    await storage.write(key: "token", value: _token);
    await storage.write(key: "username", value: _username);
    await storage.write(key: "publicKey", value: _publicKey);
    await storage.write(key: "privateKey", value: _privateKey);
    AppLogger.instance.d("Written to secure storage: $_token");
    isLoading = false;
    notifyListeners();
  }

  bool get isLoggedIn => _token != null;

  Future<void> register(String username) async {
    final masterKey = generateMasterKey();
    final masterHash = await getMasterHash(username, masterKey);
    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    _publicKey = base64Encode(publicKey.bytes);

    final response = await ApiHttpClient.instance.register(
      username: username,
      master_hash: masterHash,
      public_key: _publicKey!,
    );
    _token = response.token;
    _username = response.username;
    _privateKey = base64Encode(privateKeyBytes);
    writeToSecureStorage();
  }

  void connect() {
    ApiSocketClient.instance.connect(_token!);
  }

  Future<UserResponse> getUser(String username) async {
    if (_token == null) throw Error();
    final user = await ApiHttpClient.instance.getUser(
      username: username,
      token: _token!,
    );
    return user;
  }

  Future<void> logout() async {
    if (_token == null) throw Error();
    await ApiHttpClient.instance.logout(
      token: _token!,
    );
    _token = null;
    _username = null;
    _publicKey = null;
    _privateKey = null;
    writeToSecureStorage();
  }
}
