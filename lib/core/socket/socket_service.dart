import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../environment/app_env.dart';
import '../logger/app_logger.dart';
import '../storage/secure_storage.dart';

enum SocketStatus { disconnected, connecting, connected, error }

/// Low-level Socket.IO connection manager.
///
/// Business features do NOT use this directly – they subscribe through
/// [EventDispatcher] for loose coupling.
@singleton
class SocketService {
  SocketService(this._secureStorage);

  final SecureStorage _secureStorage;

  late io.Socket _socket;

  final _statusController = BehaviorSubject<SocketStatus>.seeded(SocketStatus.disconnected);
  Stream<SocketStatus> get statusStream => _statusController.stream;
  SocketStatus get currentStatus => _statusController.value;

  Future<void> connect() async {
    final token = await _secureStorage.getAccessToken();

    _socket = io.io(
      AppEnv.instance.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _statusController.add(SocketStatus.connecting);

    _socket
      ..onConnect((_) {
        AppLogger.info('Socket connected: ${_socket.id}');
        _statusController.add(SocketStatus.connected);
      })
      ..onDisconnect((_) {
        AppLogger.warning('Socket disconnected');
        _statusController.add(SocketStatus.disconnected);
      })
      ..onConnectError((err) {
        AppLogger.error('Socket connect error', error: err);
        _statusController.add(SocketStatus.error);
      });

    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
    _statusController.add(SocketStatus.disconnected);
  }

  void emit(String event, dynamic data) {
    if (currentStatus != SocketStatus.connected) {
      AppLogger.warning('Attempted emit while socket disconnected: $event');
      return;
    }
    _socket.emit(event, data);
  }

  void on(String event, void Function(dynamic data) handler) {
    _socket.on(event, handler);
  }

  void off(String event) {
    _socket.off(event);
  }

  void dispose() {
    _statusController.close();
    _socket.dispose();
  }
}
