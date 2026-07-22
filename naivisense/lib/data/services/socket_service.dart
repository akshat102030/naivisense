import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception("Socket has not been initialized.");
    }
    return _socket!;
  }

  Future<void> connect({
    required String baseUrl,
    required String token,
    required String userId,
  }) async {
    if (_socket != null && _socket!.connected) {
      log("Socket already connected");
      return;
    }

    final completer = Completer<void>();

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setTimeout(10000)
          .setExtraHeaders({"Authorization": "Bearer $token"})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      log("Socket Connected");

      _socket!.emit("joinRoom", userId);

      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.onDisconnect((_) {
      log("Socket Disconnected");
    });

    _socket!.onReconnect((_) {
      log("Socket Reconnected");

      _socket!.emit("joinRoom", userId);
    });

    _socket!.onReconnectAttempt((attempt) {
      log("Reconnect Attempt $attempt");
    });

    _socket!.onConnectError((err) {
      log("Connect Error: $err");

      if (!completer.isCompleted) {
        completer.completeError(err);
      }
    });

    _socket!.onError((err) {
      log("Socket Error: $err");
    });

    return completer.future;
  }

  void disconnect() {
    if (_socket == null) return;

    _socket!.clearListeners();
    _socket!.disconnect();
    _socket!.dispose();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    if (!isConnected) return;

    _socket!.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.off(event);
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void removeAllListeners() {
    _socket?.clearListeners();
  }
}
