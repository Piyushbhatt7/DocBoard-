import 'package:google_docs/clients/socket_client.dart' show SocketClient;
import 'package:socket_io_client/src/socket.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;
  final List<Map<String, dynamic>> _messageQueue = [];

  Socket get socketClient => _socketClient;

  void joinRoom(String documentId) {
    print('Joining room: $documentId');
    if (!_socketClient.connected) {
      print('Socket not connected, queueing join room request');
      _messageQueue.add({'type': 'join', 'data': documentId});
      _socketClient.connect();
    } else {
      _socketClient.emit('join', documentId);
    }
  }

  void typing(Map<String, dynamic> data) {
    if (!_socketClient.connected) {
      print('Socket not connected, queueing message');
      _messageQueue.add({'type': 'changes', 'data': data});
      _socketClient.connect();
    } else {
      print('Sending changes to room: ${data['room']}');
      print('Changes data: ${data['delta']}');
      _socketClient.emit('changes', data);
    }
  }

  void changeListener(Function(Map<String, dynamic>) func) {
    print('Setting up change listener');
    _socketClient.off('changes'); // Remove any existing listeners
    
    _socketClient.on('connect', (_) {
      print('Socket connected, processing queued messages');
      _processMessageQueue();
    });

    _socketClient.on('changes', (data) {
      print('Received changes event: $data');
      func(data);
    });
  }

  void _processMessageQueue() {
    while (_messageQueue.isNotEmpty) {
      final message = _messageQueue.removeAt(0);
      if (message['type'] == 'join') {
        _socketClient.emit('join', message['data']);
      } else if (message['type'] == 'changes') {
        _socketClient.emit('changes', message['data']);
      }
    }
  }

  bool isConnected() {
    return _socketClient.connected;
  }
}