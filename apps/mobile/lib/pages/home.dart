import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../api/api.dart';
import '../helpers/firebase.dart';
import '../helpers/logger.dart';
import '../models/drift.dart';
import './user.dart';
import 'new_chat.dart';

class HomePageChat {
  final String username;
  final DateTime lastMessageAt;
  final int count;

  HomePageChat({
    required this.username,
    required this.lastMessageAt,
    required this.count,
  });
}

class ChatsList extends StatefulWidget {
  const ChatsList({super.key});

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  List<HomePageChat> _users = [];
  StreamSubscription<List<drift.TypedResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _addWatcher();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _addWatcher() {
    final maxSentAtField = MyDatabase.instance.message.sentAt.max();
    final countField = MyDatabase.instance.message.id.count();
    final usernameField = MyDatabase.instance.message.username;
    _subscription = (MyDatabase.instance.message.selectOnly()
          ..addColumns([usernameField, countField, maxSentAtField])
          ..groupBy([usernameField])
          ..orderBy(
            [
              drift.OrderingTerm(
                expression: maxSentAtField,
                mode: drift.OrderingMode.desc,
              )
            ],
          ))
        .watch()
        .listen((event) async {
      final List<HomePageChat> users = [];
      for (var element in event) {
        final username = element.read(usernameField);
        final count = element.read(countField);
        final maxSentAt = element.read(maxSentAtField);
        if (username != null && count != null && maxSentAt != null) {
          users.add(
            HomePageChat(
              count: count,
              username: username,
              lastMessageAt: maxSentAt,
            ),
          );
        }
      }
      setState(() {
        _users = users;
      });
    });
  }

  Future<void> _openUserPage(String username) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => UserPage(username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          title: Text(user.username),
          subtitle: Text("Last message ${timeago.format(user.lastMessageAt)}"),
          trailing: Text(user.count.toString()),
          onTap: () => _openUserPage(user.username),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final coreApi = Provider.of<CoreApi>(context, listen: false);
    coreApi.connect();
    _registerNotificationPermissions();
    _setupInteractedMessage();
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => UserPage(
            username: message.data["username"] as String,
          ),
        ),
      );
    }
  }

  Future<void> _registerNotificationPermissions() async {
    if (!isFirebaseInitialized()) return;
    final permission = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (permission.authorizationStatus != AuthorizationStatus.authorized) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text(
                "Notifications permission not granted",
              ),
              IconButton(
                onPressed: () async {
                  await AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
        ),
      );
      return;
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      final coreApi = Provider.of<CoreApi>(context, listen: false);
      await coreApi.registerNotifications(notificationToken: token);
      AppLogger.instance.d("Registered notification successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    final coreApi = Provider.of<CoreApi>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(coreApi.username),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.circle,
                size: 16,
                color: coreApi.isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Are you sure you want to logout?"),
                  content: const Text(
                    "All your chat will be deleted and you will not be able to login again, you will have to create a new user",
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('Confirm'),
                      onPressed: () async {
                        final coreApi =
                            Provider.of<CoreApi>(context, listen: false);
                        Navigator.of(context).pop();
                        await coreApi.logout();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const ChatsList(),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (context) => const NewChatPage(),
          ));
        },
      ),
    );
  }
}
