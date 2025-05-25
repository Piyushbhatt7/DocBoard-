import 'dart:io';

import 'package:google_docs/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {

  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io(host, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });
    
    socket!.onConnect((_) {
      print('Socket connected successfully');
    });

    socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket!.onError((error) {
      print('Socket error: $error');
    });

    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}