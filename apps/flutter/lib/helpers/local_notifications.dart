import 'package:eraser/eraser.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'logger.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'notification_id', // id
  'Default Notifications', // title
  importance: Importance.defaultImportance,
  enableVibration: false,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initiateLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const initializationSettingsDarwin = DarwinInitializationSettings();
  const initializationSettingsLinux = LinuxInitializationSettings(
    defaultActionName: 'Open notification',
  );
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> clearNotificationByTag(String tag) async {
  try {
    await Eraser.clearAppNotificationsByTag(tag);
  } catch (e) {
    AppLogger.instance.e(e);
  }
}
