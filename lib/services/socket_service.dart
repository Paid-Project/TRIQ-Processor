import 'package:flutter/material.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  io.Socket? _socket;

  void initializeSocket({
    required String serverUrl,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? extraHeaders,
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
  }) {
    AppLogger.info('Initializing socket to: $serverUrl');
    AppLogger.info('Query params: $queryParams');
    AppLogger.info('Headers: $extraHeaders');

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery(queryParams ?? {})
          .setExtraHeaders(extraHeaders ?? {})
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      AppLogger.info('Socket connected with ID: ${_socket!.id}');
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      AppLogger.info('Socket disconnected');
      onDisconnected?.call();
    });

    _socket!.onError((err) {
      AppLogger.error('Socket error: $err');
    });

    _socket!.onConnectError((err) {
      AppLogger.error('Socket connection error: $err');
    });
  }

  void registerUser(String orgOrProcessorId, [String? event]) {
    AppLogger.info('Registering user: $orgOrProcessorId');
    _socket?.emit(event ?? 'registerUser', {'userId': orgOrProcessorId});
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void joinRoom(String roomId, [String? event]) {
    AppLogger.info('Joining room: $roomId');
    _socket?.emit(event ?? 'joinRoom', {'roomId': roomId});
  }

  void sendMessage({
    required String roomId,
    required String content,
    String? event,
    List<Map<String, dynamic>> attachments = const [],
    String? replyTo,
    String? messageType,
    String? clientMessageId,
  }) {
    final payload = {
      'roomId': roomId,
      'content': content,
      'attachments': attachments,
      'replyTo': replyTo,
      'messageType': messageType ?? _inferMessageType(attachments, content),
      'clientMessageId': clientMessageId,
    }..removeWhere((key, value) => value == null);

    AppLogger.info('Sending message with payload: $payload');
    AppLogger.info('Socket connected: ${_socket?.connected}');
    AppLogger.info('Socket ID: ${_socket?.id}');

    _socket?.emit(event ?? 'sendMessage', payload);
  }

  void reactToMessage({
    required String messageId,
    required String emoji,
  }) {
    final payload = {'messageId': messageId, 'emoji': emoji};
    AppLogger.info('Reacting to message: $payload');
    _socket?.emit('reactMessage', payload);
  }

  void onNewMessage(Function(dynamic) handler, [String? event]) {
    AppLogger.info('Setting up newMessage listener');
    _socket?.on(event ?? 'newMessage', (data) {
      AppLogger.info('New message received: $data');
      handler(data);
    });
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }

  String _inferMessageType(
    List<Map<String, dynamic>> attachments,
    String content,
  ) {
    if (attachments.isNotEmpty) {
      return (attachments.first['type'] ?? 'text').toString();
    }
    if (content.trim().isNotEmpty) {
      return 'text';
    }
    return 'text';
  }
}



