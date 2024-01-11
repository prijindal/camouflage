import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './helpers/logger.dart';
import "./models/theme.dart";
import './pages/home.dart';
import 'api/core.dart';

void main() {
  runApp(const MyApp());
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
    AppLogger.instance.d("Building MyApp");
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeNotifier.getTheme(),
      home: const MyHomePage(),
    );
  }
}
