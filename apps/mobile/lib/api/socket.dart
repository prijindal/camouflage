import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../helpers/constants.dart';
import '../helpers/logger.dart';

class ApiSocketClient {
  IO.Socket? socket;

  void initiateSocket(String token) {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).setAuth(
          {"Authorization": "Bearer $token"}).build(),
    );
  }

  static final ApiSocketClient instance = ApiSocketClient();

  void connect(
    String token, {
    dynamic Function(dynamic)? onConnect,
    dynamic Function(dynamic)? onDisconnect,
    dynamic Function(Map<String, dynamic>)? onChat,
  }) {
    initiateSocket(token);
    socket!.onConnect((e) {
      if (onConnect != null) {
        onConnect(e);
      }
      AppLogger.instance.d('connect');
    });
    socket!.onDisconnect((e) {
      if (onDisconnect != null) {
        onDisconnect(e);
      }
      AppLogger.instance.d('disconnect');
    });
    socket!.on('chat', (e) {
      if (onChat != null) {
        onChat(e[0] as Map<String, dynamic>);
      }
      AppLogger.instance.d(e[0]);
    });
  }
}
