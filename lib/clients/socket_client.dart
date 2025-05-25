import 'dart:io';

import 'package:google_docs/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {

  io.Socket? socket;
  static SocketClient? _instance;

    SocketClient._internal() {
    socket = IO.io(
      'http://192.168.56.1',
      IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter compatibility
        .disableAutoConnect() // connect manually
        .build()
    );
    
    socket!.onConnect((_) {
      print('Socket connected successfully');
    });

    socket!.onDisconnect((_) {
      print('Socket disconnected, attempting to reconnect...');
      socket!.connect();
    });

    socket!.onError((error) {
      print('Socket error: $error');
      socket!.connect();
    });

    socket!.onReconnect((_) {
      print('Socket reconnected successfully');
    });

    socket!.onReconnectAttempt((attemptNumber) {
      print('Attempting to reconnect: $attemptNumber');
    });

    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}