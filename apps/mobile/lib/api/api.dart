import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../encryption/key.dart';
import '../helpers/logger.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../models/message.dart';
import '../models/payloads.dart';
import './http.dart';
import './socket.dart';

const _uuid = Uuid();

class CoreApi with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool isLoading = false;
  bool isConnected = false;
  String? _token;
  String? _username;
  String? _publicKey;
  String? _privateKey;

  CoreApi() {
    init();
  }

  String get username {
    if (_username == null) {
      AppLogger.instance.e("Username not found");
      throw Error();
    }
    return _username!;
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    // Check if server is up
    await ApiHttpClient.instance.health();
    await readFromSecureStorage();
    if (isLoggedIn) {
      final user = await getMe();
      if (user.username != _username) {
        clearSecureStorage();
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> readFromSecureStorage() async {
    _token = await storage.read(key: "token");
    _username = await storage.read(key: "username");
    _publicKey = await storage.read(key: "publicKey");
    _privateKey = await storage.read(key: "privateKey");
    AppLogger.instance.d("Read from secure storage: $_token");
  }

  Future<void> clearSecureStorage() async {
    await storage.deleteAll();
  }

  Future<void> writeToSecureStorage() async {
    await storage.write(key: "token", value: _token);
    await storage.write(key: "username", value: _username);
    await storage.write(key: "publicKey", value: _publicKey);
    await storage.write(key: "privateKey", value: _privateKey);
    AppLogger.instance.d("Written to secure storage: $_token");
  }

  bool get isLoggedIn => _token != null;

  Future<void> register(String username) async {
    final masterKey = generateMasterKey();
    final masterHash = await getMasterHash(username, masterKey);
    final keyPair = await newKeyPair();
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
    notifyListeners();
  }

  void connect() {
    ApiSocketClient.instance.connect(
      _token!,
      onConnect: (_) {
        isConnected = true;
        notifyListeners();
      },
      onDisconnect: (_) {
        isConnected = false;
        notifyListeners();
      },
      onChat: _onChat,
    );
  }

  Future<void> _onChat(Map<String, dynamic> e) async {
    if (_token == null) throw Error();
    final payload = ChatMessagePayload.fromJson(e);
    await MyDatabase.instance.into(MyDatabase.instance.message).insert(
          MessageData(
            id: payload.messageId,
            username: payload.username,
            encryptedPayload: base64Decode(payload.encryptedPayload),
            sentAt: DateTime.parse(payload.timestamp),
            direction: MessageDirection.received,
          ),
        );
  }

  Future<ParsedMessage> decryptMessageData(
    MessageData message,
    String publicKey,
  ) async {
    final sharedKey = await getSharedKey(
      publicKey: _publicKey!,
      privateKey: _privateKey!,
      remotePublicKeyString: publicKey,
    );
    final unencrypted = await decryptMessage(
      sharedKey,
      message.encryptedPayload,
    );
    return ParsedMessage.fromJson(
      jsonDecode(unencrypted) as Map<String, dynamic>,
    );
  }

  Future<UserResponse> getUser(String username) async {
    if (_token == null) throw Error();
    final user = await ApiHttpClient.instance.getUser(
      username: username,
      token: _token!,
    );
    return user;
  }

  Future<UserResponse> getMe() async {
    if (_token == null) throw Error();
    try {
      final user = await ApiHttpClient.instance.getMe(
        token: _token!,
      );
      return user;
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<bool> sendMessage({
    required ParsedMessage payload,
    required String username,
    required String publicKey,
  }) async {
    if (_token == null || _publicKey == null || _privateKey == null)
      throw Error();
    final sharedKey = await getSharedKey(
      publicKey: _publicKey!,
      privateKey: _privateKey!,
      remotePublicKeyString: publicKey,
    );
    final encryptedPayload =
        await encryptMessage(sharedKey, jsonEncode(payload.toJson()));
    final timestamp = DateTime.now();
    final messageId = _uuid.v4();
    await MyDatabase.instance.into(MyDatabase.instance.message).insert(
          MessageData(
            id: messageId,
            username: username,
            encryptedPayload: encryptedPayload,
            sentAt: timestamp,
            direction: MessageDirection.sent,
          ),
        );
    return ApiHttpClient.instance.sendMessage(
      token: _token!,
      payload: ChatMessagePayload(
        messageId: messageId,
        encryptedPayload: base64Encode(encryptedPayload),
        timestamp: timestamp.toIso8601String(),
        username: username,
      ),
    );
  }

  Future<void> logout() async {
    if (_token == null) throw Error();
    await MyDatabase.instance.message.deleteAll();
    ApiSocketClient.instance.disconnect();
    _token = null;
    _username = null;
    _publicKey = null;
    _privateKey = null;
    isLoading = false;
    clearSecureStorage();
    notifyListeners();
    await ApiHttpClient.instance.logout(
      token: _token!,
    );
  }
}
