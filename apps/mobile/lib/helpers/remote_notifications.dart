import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/api.dart';
import 'local_notifications.dart';
import 'logger.dart';

Future<void> remoteMessageHandler(RemoteMessage message) async {
  onChatHandler(message.data); // Run parallelly

  final publicKey = await flutterSecureStorage.read(key: "publicKey");
  final privateKey = await flutterSecureStorage.read(key: "privateKey");

  AppLogger.instance.d(publicKey);
  AppLogger.instance.d(privateKey);
  AppLogger.instance.d(message.data);

  final userPublicKey =
      await getCachedPublicKey(message.data["username"] as String);

  if (publicKey != null &&
      privateKey != null &&
      userPublicKey != null &&
      message.notification != null) {
    final decryptedMessage = await decryptMessageDataHandler(
      encryptedPayload:
          base64Decode(message.data["encrypted_payload"] as String),
      remotePublicKey: userPublicKey,
      publicKey: publicKey,
      privateKey: privateKey,
    );

    final messageId = message.data["message_id"] as String;

    await clearNotificationByTag(messageId);

    flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.data["username"] as String,
      String.fromCharCodes(decryptedMessage.body), // Only if it's text
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: message.notification?.android?.smallIcon,
          playSound: false,
          enableVibration: false,
          tag: messageId,
          // other properties...
        ),
      ),
    );
  }
}
