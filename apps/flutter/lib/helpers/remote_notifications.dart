import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/api.dart';
import '../models/message.dart';
import '../models/payloads.dart';
import 'local_notifications.dart';
import 'logger.dart';

Future<void> _remoteOnChatHandler(ChatMessagePayload payload) async {
  await onChatHandlerForDb(payload); // Run parallelly
}

Future<void> remoteMessageHandler(RemoteMessage message) async {
  final payload = ChatMessagePayload.fromJson(message.data);
  unawaited(_remoteOnChatHandler(payload));

  final publicKey = await flutterSecureStorage.read(key: "publicKey");
  final privateKey = await flutterSecureStorage.read(key: "privateKey");

  AppLogger.instance.d(publicKey);
  AppLogger.instance.d(privateKey);
  AppLogger.instance.d(message.data);

  final userPublicKey = await getCachedPublicKey(payload.username);

  if (publicKey != null &&
      privateKey != null &&
      userPublicKey != null &&
      message.notification != null) {
    final decryptedMessage = await decryptMessageDataHandler(
      encryptedPayload: base64Decode(payload.encryptedPayload),
      remotePublicKey: userPublicKey,
      publicKey: publicKey,
      privateKey: privateKey,
    );

    final messageId = payload.messageId;

    await clearNotificationByTag(messageId);

    // TODO: Consider not doing this, it is not a good idea to show messages on notification
    // Also, it creates a ton of issues
    // Maybe, only display a message when it is invoked when app is already opened?

    final body = decryptedMessage.type == MessageType.text
        ? String.fromCharCodes(decryptedMessage.body)
        : null;

    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      payload.username,
      body,
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
