import 'package:google_docs/clients/socket_client.dart' show SocketClient;
import 'package:socket_io_client/src/socket.dart';

class SocketRepository {

  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void joinRoom(String documentId)
  {
    print('Joining room: $documentId');
    if (!_socketClient.connected) {
      print('Socket not connected, attempting to connect...');
      _socketClient.connect();
    }
    _socketClient.emit('join', documentId);
  }

  void typing(Map<String, dynamic> data)
  {
    if (!_socketClient.connected) {
      print('Socket not connected, attempting to connect...');
      _socketClient.connect();
    }
    print('Sending changes to room: ${data['room']}');
    print('Changes data: ${data['delta']}');
    _socketClient.emit('changes', data);
  }

  void changeListener(Function(Map<String, dynamic>) func) {
    print('Setting up change listener');
    _socketClient.off('changes'); // Remove any existing listeners
    _socketClient.on('changes', (data) {
      print('Received changes event: $data');
      func(data);
    });
  }

  bool isConnected() {
    return _socketClient.connected;
  }
}