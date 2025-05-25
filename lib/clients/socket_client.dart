import 'dart:io';

import 'package:google_docs/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {

  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io(host, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'timeout': 20000,
      'forceNew': true,
    });
    
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