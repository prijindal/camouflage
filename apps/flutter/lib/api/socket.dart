import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../helpers/constants.dart';
import '../helpers/logger.dart';

class ApiSocketClient {
  IO.Socket socket;

  ApiSocketClient({required String token})
      : socket = IO.io(
          baseUrl,
          IO.OptionBuilder().setTransports(['websocket']).setAuth(
              {"Authorization": "Bearer $token"}).build(),
        );

  void disconnect() {
    socket.disconnect();
  }

  void connect(
    String token, {
    dynamic Function(dynamic)? onConnect,
    dynamic Function(dynamic)? onDisconnect,
    dynamic Function(Map<String, dynamic>)? onChat,
    dynamic Function(Map<String, dynamic>)? onReceived,
    dynamic Function(Map<String, dynamic>)? onRead,
  }) {
    socket.onConnect((e) {
      if (onConnect != null) {
        onConnect(e);
      }
      AppLogger.instance.d('connect');
    });
    socket.onDisconnect((e) {
      if (onDisconnect != null) {
        onDisconnect(e);
      }
      AppLogger.instance.d('disconnect');
    });
    socket.on('chat', (e) {
      AppLogger.instance.d(e);
      if (onChat != null) {
        onChat(e as Map<String, dynamic>);
      }
    });
    socket.on('received', (e) {
      AppLogger.instance.d(e);
      if (onReceived != null) {
        onReceived(e as Map<String, dynamic>);
      }
    });
    socket.on('read', (e) {
      AppLogger.instance.d(e);
      if (onRead != null) {
        onRead(e as Map<String, dynamic>);
      }
    });
  }
}
