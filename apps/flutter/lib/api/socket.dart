import 'package:socket_io_client/socket_io_client.dart' as io;

import '../helpers/logger.dart';

class ApiSocketClient {
  io.Socket socket;

  ApiSocketClient({required String baseUrl, required String token})
      : socket = io.io(
          baseUrl,
          io.OptionBuilder().setTransports(['websocket']).setAuth(
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
      // AppLogger.instance.d(e);
      if (onChat != null) {
        if (e is Map<String, dynamic>) {
          onChat(e);
        } else if (e is List<dynamic>) {
          onChat(e[0] as Map<String, dynamic>);
        }
      }
    });
    socket.on('received', (e) {
      AppLogger.instance.d(e);
      if (onReceived != null) {
        if (e is Map<String, dynamic>) {
          onReceived(e);
        } else if (e is List<dynamic>) {
          onReceived(e[0] as Map<String, dynamic>);
        }
      }
    });
    socket.on('read', (e) {
      AppLogger.instance.d(e);
      if (onRead != null) {
        if (e is Map<String, dynamic>) {
          onRead(e);
        } else if (e is List<dynamic>) {
          onRead(e[0] as Map<String, dynamic>);
        }
      }
    });
  }
}
