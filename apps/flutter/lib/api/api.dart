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

Future<ChatMessagePayload> onChatHandlerForDb(
    ChatMessagePayload payload) async {
  try {
    await MyDatabase.instance.into(MyDatabase.instance.message).insert(
          MessageData(
            id: payload.messageId,
            username: payload.username,
            encryptedPayload: base64Decode(payload.encryptedPayload),
            sentAt: DateTime.parse(payload.timestamp),
            direction: MessageDirection.received,
          ),
        );
  } catch (e) {
    AppLogger.instance.e(e);
  }
  return payload;
}

Future<void> onReceivedHandlerOnDb(ReceivedMessagePayload payload) async {
  try {
    await (MyDatabase.instance.message.update()
          ..where((tbl) => tbl.id.equals(payload.messageId)))
        .write(
      MessageCompanion(
        receivedAt: Value(
          DateTime.parse(payload.timestamp),
        ),
      ),
    );
  } catch (e) {
    AppLogger.instance.e(e);
  }
}

Future<void> onReadHandlerOnDb(ReceivedMessagePayload payload) async {
  try {
    await (MyDatabase.instance.message.update()
          ..where((tbl) => tbl.id.equals(payload.messageId)))
        .write(
      MessageCompanion(
        readAt: Value(
          DateTime.parse(payload.timestamp),
        ),
      ),
    );
  } catch (e) {
    AppLogger.instance.e(e);
  }
}

Future<ParsedMessage> decryptMessageDataHandler({
  required Uint8List encryptedPayload,
  required String remotePublicKey,
  required String publicKey,
  required String privateKey,
}) async {
  final sharedKey = await getSharedKey(
    publicKey: publicKey,
    privateKey: privateKey,
    remotePublicKeyString: remotePublicKey,
  );
  final unencrypted = await decryptMessage(
    sharedKey,
    encryptedPayload,
  );
  return ParsedMessage.fromJson(
    jsonDecode(unencrypted) as Map<String, dynamic>,
  );
}

const flutterSecureStorage = FlutterSecureStorage();

Future<String?> getCachedPublicKey(String username) async {
  final key = "public_key_$username";
  final userPublicKey = await flutterSecureStorage.read(key: key);
  return userPublicKey;
}

class CoreApi with ChangeNotifier {
  final String baseUrl;
  ApiSocketClient? socketClient;
  final ApiHttpClient httpClient;
  bool isLoading = false;
  bool isConnected = false;
  String? _token;
  String? _username;
  String? _publicKey;
  String? _privateKey;

  CoreApi({required this.baseUrl})
      : httpClient = ApiHttpClient(
          baseUrl: baseUrl,
        ) {
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
    await httpClient.health();
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
    _token = await flutterSecureStorage.read(key: "token");
    _username = await flutterSecureStorage.read(key: "username");
    _publicKey = await flutterSecureStorage.read(key: "publicKey");
    _privateKey = await flutterSecureStorage.read(key: "privateKey");
    AppLogger.instance.d("Read from secure storage: $_token");
  }

  Future<void> clearSecureStorage() async {
    await flutterSecureStorage.deleteAll();
  }

  Future<void> writeToSecureStorage() async {
    await flutterSecureStorage.write(key: "token", value: _token);
    await flutterSecureStorage.write(key: "username", value: _username);
    await flutterSecureStorage.write(key: "publicKey", value: _publicKey);
    await flutterSecureStorage.write(key: "privateKey", value: _privateKey);
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

    final response = await httpClient.register(
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
    socketClient = ApiSocketClient(
      token: _token!,
      baseUrl: baseUrl,
    );
    socketClient!.connect(
      _token!,
      onConnect: (_) {
        isConnected = true;
        notifyListeners();
      },
      onDisconnect: (_) {
        isConnected = false;
        notifyListeners();
      },
      onChat: (e) async {
        final payload = ChatMessagePayload.fromJson(e);
        await onChatHandlerForDb(payload);
        final receivedPayload = ReceivedMessagePayload(
          messageId: payload.messageId,
          timestamp: DateTime.now().toIso8601String(),
          username: payload.username,
        );
        await receivedMessage(
          payload: receivedPayload,
        );
        await onReceivedHandlerOnDb(receivedPayload);
      },
      onReceived: (e) async {
        final receivedPayload = ReceivedMessagePayload.fromJson(e);
        await onReceivedHandlerOnDb(receivedPayload);
      },
      onRead: (e) async {
        final payload = ReceivedMessagePayload.fromJson(e);
        await onReadHandlerOnDb(payload);
      },
    );
  }

  Future<ParsedMessage> decryptMessageData(
    MessageData message,
    String remotePublicKey,
  ) async {
    return decryptMessageDataHandler(
      encryptedPayload: message.encryptedPayload,
      remotePublicKey: remotePublicKey,
      publicKey: _publicKey!,
      privateKey: _privateKey!,
    );
  }

  Future<bool> userOnline(String username) async {
    if (_token == null) throw Error();
    return httpClient.userOnline(username: username, token: _token!);
  }

  Future<UserResponse> getUser(String username) async {
    final userPublicKey = await getCachedPublicKey(username);
    if (userPublicKey != null) {
      return UserResponse(
        username: username,
        publicKey: userPublicKey,
      );
    }
    if (_token == null) throw Error();
    final user = await httpClient.getUser(
      username: username,
      token: _token!,
    );
    final key = "public_key_$username";
    await flutterSecureStorage.write(key: key, value: user.publicKey);
    return user;
  }

  Future<UserResponse> getMe() async {
    if (_token == null) throw Error();
    try {
      final user = await httpClient.getMe(
        token: _token!,
      );
      return user;
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<void> registerNotifications({
    required String notificationToken,
  }) async {
    if (_token == null) throw Error();
    return await httpClient.registerNotifications(
      token: _token!,
      notificationToken: notificationToken,
    );
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
            direction: MessageDirection.sent,
          ),
        );
    final response = httpClient.sendMessage(
      token: _token!,
      payload: ChatMessagePayload(
        messageId: messageId,
        encryptedPayload: base64Encode(encryptedPayload),
        timestamp: timestamp.toIso8601String(),
        username: username,
      ),
    );
    await (MyDatabase.instance.message.update()
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(
      MessageCompanion(sentAt: Value(timestamp)),
    );
    return response;
  }

  Future<bool> receivedMessage(
      {required ReceivedMessagePayload payload}) async {
    if (_token == null) throw Error();
    return await httpClient.receivedMessage(
      token: _token!,
      payload: payload,
    );
  }

  Future<bool> readMessage({required ReceivedMessagePayload payload}) async {
    if (_token == null) throw Error();
    return await httpClient.readMessage(
      token: _token!,
      payload: payload,
    );
  }

  Future<void> logout() async {
    if (_token == null) throw Error();
    await MyDatabase.instance.message.deleteAll();
    socketClient?.disconnect();
    socketClient = null;
    _token = null;
    _username = null;
    _publicKey = null;
    _privateKey = null;
    isLoading = false;
    clearSecureStorage();
    notifyListeners();
    await httpClient.logout(
      token: _token!,
    );
  }
}
