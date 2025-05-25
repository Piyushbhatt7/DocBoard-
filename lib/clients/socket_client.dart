import 'dart:io';

import 'package:google_docs/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {

  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io(host, <String, dynamic> {
      
    });
  }
}