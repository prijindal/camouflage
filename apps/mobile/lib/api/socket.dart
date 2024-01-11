import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../helpers/logger.dart';

class ApiSocketClient {
  IO.Socket? socket;

  void initiateSocket(String token) {
    socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder().setTransports(['websocket']).setAuth(
          {"Authorization": "Bearer $token"}).build(),
    );
  }

  static final ApiSocketClient instance = ApiSocketClient();

  void connect(String token, {dynamic Function(dynamic)? onConnect}) {
    initiateSocket(token);
    socket!.onConnect((e) {
      if (onConnect != null) {
        onConnect(e);
      }
      AppLogger.instance.d('connect');
      socket!.emit('msg', 'test');
    });
    socket!.on('event', (data) => AppLogger.instance.d(data));
    socket!.onDisconnect((_) => AppLogger.instance.d('disconnect'));
    socket!.on('fromServer', (_) => AppLogger.instance.d(_));
  }
}
