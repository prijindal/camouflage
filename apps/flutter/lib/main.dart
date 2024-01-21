import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './api/api.dart';
import './firebase_options.dart';
import './helpers/logger.dart';
import "./models/theme.dart";
import './pages/home.dart';
import './pages/loading.dart';
import './pages/register.dart';
import 'helpers/constants.dart';
import 'helpers/local_notifications.dart';
import 'helpers/remote_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    AppLogger.instance.e(
      "Firebase cannot be initialized",
      error: e,
      stackTrace: stack,
    );
  }

  await remoteMessageHandler(message);
}

void main() {
  runApp(const MyApp());
  initiateLocalNotifications().catchError((dynamic e) {
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
          create: (_) => CoreApi(
            baseUrl: baseUrl,
          ),
        ),
      ],
      child: const MyMaterialApp(),
    );
  }
}

final themeData = ThemeData(
  // primarySwatch: Colors.blue, // Not working ??
  primaryColor: Colors.blue,
  useMaterial3: true,
);

final lightTheme = themeData.copyWith(
  appBarTheme: themeData.appBarTheme.copyWith(
    backgroundColor: themeData.primaryColor,
  ),
);

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    final coreApi = Provider.of<CoreApi>(context);
    AppLogger.instance.d("Building MyApp");
    return MaterialApp(
      theme: lightTheme,
      // darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeNotifier.getTheme(),
      home: coreApi.isLoadingLocal
          ? const LoadingPage()
          : !coreApi.isLoggedIn
              ? const RegisterPage()
              : const HomePage(),
    );
  }
}
