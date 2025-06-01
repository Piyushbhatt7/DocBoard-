import 'dart:io';

import 'package:google_docs/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {

  io.Socket? socket;
  static SocketClient? _instance;

    SocketClient._internal() {
    print('Initializing socket connection to: $host');
    socket = IO.io(
      host,
      IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter compatibility
        .disableAutoConnect() // connect manually
        .build()
    );
    
    socket!.onConnect((_) {
      print('Socket connected successfully to $host');
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

    socket!.onConnectError((error) {
      print('Connection error: $error');
    });

    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}