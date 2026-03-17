import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? _socket;
  String? _serverUrl;

  static const String eventRegisterUser = 'registerUser';
  static const String eventJoinRoom = 'joinRoom';
  static const String eventSendMessage = 'sendMessage';
  static const String eventTyping = 'typing';
  static const String eventSeenMessage = 'seenMessage';
  static const String eventReactMessage = 'reactMessage';
  static const String eventNewMessage = 'newMessage';
  static const String eventUpdateChatList = 'updateChatList';
  static const String eventUserTyping = 'userTyping';
  static const String eventMessageReactionUpdated = 'messageReactionUpdated';
  static const String eventError = 'error';

  void initializeSocket({
    required String serverUrl,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? extraHeaders,
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
  }) {
    final effectiveQuery = queryParams ?? <String, dynamic>{};
    final effectiveHeaders = extraHeaders ?? <String, dynamic>{};

    // This service is a singleton used from multiple screens. Re-initializing
    // should not replace an already active socket connection.
    if (_socket == null || _serverUrl != serverUrl) {
      print('Initializing socket to: $serverUrl');
      print('Query params: $effectiveQuery');
      print('Headers: $effectiveHeaders');

      _serverUrl = serverUrl;

      _socket?.dispose();
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery(effectiveQuery)
            .setExtraHeaders(effectiveHeaders)
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        print('Socket connected with ID: ${_socket!.id}');
      });

      _socket!.onDisconnect((_) {
        print('Socket disconnected');
      });

      _socket!.onError((err) {
        print('Socket error: $err');
      });

      _socket!.onConnectError((err) {
        print('Socket connection error: $err');
      });
    } else {
      // Socket already exists; make sure it is connected.
      if (_socket!.connected != true) {
        _socket!.connect();
      }
    }

    if (onConnected != null) {
      if (_socket!.connected == true) {
        onConnected();
      } else {
        late final void Function(dynamic) handler;
        handler = (dynamic _) {
          onConnected();
          _socket?.off('connect', handler);
        };
        _socket!.on('connect', handler);
      }
    }

    if (onDisconnected != null) {
      late final void Function(dynamic) handler;
      handler = (dynamic _) {
        onDisconnected();
        _socket?.off('disconnect', handler);
      };
      _socket!.on('disconnect', handler);
    }
  }

  void registerUser(String orgOrProcessorId, [String? event]) {
    print('Registering user: $orgOrProcessorId');
    _socket?.emit(event ?? eventRegisterUser, {'userId': orgOrProcessorId});
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void joinRoom(String roomId, [String? event]) {
    print('Joining room: $roomId');
    _socket?.emit(event ?? eventJoinRoom, {'roomId': roomId});
  }

  void seenMessage(String messageId) {
    final payload = {'messageId': messageId};
    print('Mark message seen: $payload');
    _socket?.emit(eventSeenMessage, payload);
  }

  /// Server -> Client (commonly broadcast) when a message is seen/read.
  ///
  /// Backend payload shapes vary; this tries to support:
  /// - { "messageId": "...", "readBy": ["..."] }
  /// - { "messageId": "...", "userId": "..." }
  /// - { "_id": "...", "readBy": ["..."] } (full message object)
  void onSeenMessageUpdated(
      void Function(String messageId, List<String> readBy) handler,
      ) {
    _socket?.on(eventSeenMessage, (data) {
      if (data is! Map) return;
      final root = Map<String, dynamic>.from(data);

      Map<String, dynamic> map = root;
      for (final key in const ['data', 'payload']) {
        final candidate = map[key];
        if (candidate is Map) {
          map = Map<String, dynamic>.from(candidate);
          break;
        }
      }

      final messageId =
          (map['messageId'] ?? map['_id'] ?? root['messageId'] ?? root['_id'])
              ?.toString()
              .trim() ??
              '';
      if (messageId.isEmpty) return;

      final readByRaw = map['readBy'] ?? root['readBy'];
      if (readByRaw is List) {
        final readBy = readByRaw.map((e) => e.toString()).toList();
        handler(messageId, readBy);
        return;
      }

      final singleUser =
          (map['userId'] ??
              map['user'] ??
              root['userId'] ??
              root['user'])
              ?.toString()
              .trim() ??
              '';
      if (singleUser.isNotEmpty) {
        handler(messageId, [singleUser]);
      }
    });
  }
//Server ko batane ke liye user typing kar raha hai.
  void typing(String roomId) {
    final payload = {'roomId': roomId};
    print('Typing in room: $payload');
    _socket?.emit(eventTyping, payload);
  }
//Server batata hai kaun typing kar raha hai.
  void onUserTyping(void Function(String userId) handler) {
    _socket?.on(eventUserTyping, (data) {
      final userId =
          (data is Map ? data['userId'] : null)?.toString().trim() ?? '';
      if (userId.isEmpty) return;
      handler(userId);
    });
  }
//Chat list update ke liye.
  void onUpdateChatList(
      void Function(
          String roomId,
          Map<String, dynamic>? lastMessage,
          int unreadCount,
          )
      handler,
      ) {
    _socket?.on(eventUpdateChatList, (data) {
      if (data is! Map) return;
      final root = Map<String, dynamic>.from(data);

      // Some backends wrap payload: { data: {...} } / { chat: {...} }.
      Map<String, dynamic> map = root;
      for (final key in const ['data', 'chat', 'payload']) {
        final candidate = map[key];
        if (candidate is Map) {
          map = Map<String, dynamic>.from(candidate);
          break;
        }
      }

      final roomId =
          (map['roomId'] ??
              map['room'] ??
              map['_id'] ??
              root['roomId'] ??
              root['room'] ??
              root['_id'])
              ?.toString()
              .trim() ??
              '';
      if (roomId.isEmpty) return;

      int unreadCount = 0;
      final unreadRaw = map['unreadCount'] ?? root['unreadCount'];
      if (unreadRaw is int) unreadCount = unreadRaw;
      if (unreadRaw is num) unreadCount = unreadRaw.toInt();
      if (unreadRaw is String) unreadCount = int.tryParse(unreadRaw) ?? 0;

      final lastMessage =
      (map['lastMessage'] ?? root['lastMessage']) is Map
          ? Map<String, dynamic>.from(
        (map['lastMessage'] ?? root['lastMessage']) as Map,
      )
          : null;

      handler(roomId, lastMessage, unreadCount);
    });
  }
//Reaction update ke liye.
  void onMessageReactionUpdated(
      void Function(String messageId, List<Map<String, dynamic>> reactions)
      handler,
      ) {
    _socket?.on(eventMessageReactionUpdated, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);

      final messageId = map['messageId']?.toString().trim() ?? '';
      if (messageId.isEmpty) return;

      final reactionsRaw = map['reactions'];
      if (reactionsRaw is List) {
        final reactions =
        reactionsRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        handler(messageId, reactions);
        return;
      }

      final emoji = map['emoji']?.toString();
      final user = map['user']?.toString();
      if (emoji != null && emoji.isNotEmpty && user != null && user.isNotEmpty) {
        handler(messageId, [
          {'user': user, 'emoji': emoji},
        ]);
      }
    });
  }

  void onErrorMessage(void Function(String message) handler) {
    _socket?.on(eventError, (data) {
      if (data is Map) {
        final msg = data['message']?.toString().trim();
        if (msg != null && msg.isNotEmpty) {
          handler(msg);
          return;
        }
      }
      final msg = data?.toString().trim() ?? '';
      if (msg.isNotEmpty) handler(msg);
    });
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
      // 'messageType': messageType ?? _inferMessageType(attachments, content),
      // 'clientMessageId': clientMessageId,
    }..removeWhere((key, value) => value == null);

    print('Sending message with payload: $payload');
    print('Socket connected: ${_socket?.connected}');
    print('Socket ID: ${_socket?.id}');

    _socket?.emit(event ?? eventSendMessage, payload);
  }

  void reactToMessage({
    required String messageId,
    required String emoji,
  }) {
    final payload = {'messageId': messageId, 'emoji': emoji};
    print('Reacting to message: $payload');
    _socket?.emit(eventReactMessage, payload);
  }

  void onNewMessage(Function(dynamic) handler, [String? event]) {
    print('Setting up newMessage listener');
    _socket?.on(event ?? eventNewMessage, (data) {
      print("SOCKET RAW EVENT: $data");
      handler(data);
    });
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  bool get isConnected => _socket?.connected == true;

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _serverUrl = null;
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
