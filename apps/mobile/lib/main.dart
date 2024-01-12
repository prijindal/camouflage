import 'dart:convert';

import 'package:eraser/eraser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import './api/api.dart';
import './firebase_options.dart';
import './helpers/logger.dart';
import "./models/theme.dart";
import './pages/home.dart';
import './pages/loading.dart';
import './pages/register.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'notification_id', // id
  'Default Notifications', // title
  importance: Importance.defaultImportance,
  enableVibration: false,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  try {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    AppLogger.instance.e(
      "Firebase cannot be initialized",
      error: e,
      stackTrace: stack,
    );
  }

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

    print("Decrypted: ${decryptedMessage.toJson()}");

    final messageId = message.data["message_id"] as String;

    try {
      await Eraser.clearAppNotificationsByTag(messageId);
    } catch (e) {
      AppLogger.instance.e(e);
    }

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

void main() {
  runApp(const MyApp());
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  flutterLocalNotificationsPlugin
      .initialize(initializationSettings)
      .catchError((e) {
    AppLogger.instance.e(e);
  });
  // TODO: Move all this local notifications somewhere else
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel)
      .catchError((e) {
    AppLogger.instance.e(e);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  try {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  } catch (e, stack) {
    AppLogger.instance.e(
      "Firebase cannot be initialized",
      error: e,
      stackTrace: stack,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModeNotifier>(
          create: (_) => ThemeModeNotifier(ThemeMode.system),
        ),
        ChangeNotifierProvider<CoreApi>(
          create: (_) => CoreApi(),
        ),
      ],
      child: const MyMaterialApp(),
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    final coreApi = Provider.of<CoreApi>(context);
    AppLogger.instance.d("Building MyApp");
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeNotifier.getTheme(),
      home: coreApi.isLoading
          ? const LoadingPage()
          : !coreApi.isLoggedIn
              ? const RegisterPage()
              : const HomePage(),
    );
  }
}
