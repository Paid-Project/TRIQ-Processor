import '../../../resources/enums/chat_enum.dart';

class ChatMessageModel {
  final String id;
  final String roomId;
  final Sender sender;
  final String senderType;
  final String messageType;
  String content;
  final String translatedContent;
  final List<Attachment> attachments;
  final List<String> readBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  bool isSentByMe;
  bool isDeleted;

  List<Reaction> reactions;
  ChatMessageModel? replyTo;
  String? replyToId;
  final String? clientMessageId;
  MessageStatus status;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.sender,
    required this.senderType,
    required this.messageType,
    required this.content,
    required this.translatedContent,
    required this.attachments,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isSentByMe,
    required this.isDeleted,
    this.replyTo,
    this.replyToId,
    this.clientMessageId,
    this.reactions = const [],
    required this.status,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    Sender sender;
    if (json['sender'] is String) {
      sender = Sender(
        id: json['sender'] as String,
        fullName: 'Unknown User',
        email: '',
      );
    } else {
      sender = Sender.fromJson(json['sender']);
    }

    final attachments =
        (json['attachments'] as List<dynamic>?)
            ?.map((e) => Attachment.fromJson(e))
            .toList() ??
        [];
    final rawMessageType =
        (json['messageType'] ?? json['type'] ?? '').toString().trim().toLowerCase();
    final resolvedMessageType =
        rawMessageType.isNotEmpty
            ? rawMessageType
            : _resolveMessageTypeFromAttachments(attachments);

    return ChatMessageModel(
      id: json['_id'] ?? '',
      roomId: json['room'] ?? '',
      sender: sender,
      senderType: json['senderType'] ?? '',
      messageType: resolvedMessageType,
      content: json['content'] ?? '',
      translatedContent: json['translatedContent'] ?? '',
      attachments: attachments,
      replyTo:
          (json['replyTo'] != null && json['replyTo'] is Map<String, dynamic>)
              ? ChatMessageModel.fromJson(json['replyTo'])
              : null,
      replyToId:
          json['replyTo'] is String
              ? json['replyTo']
              : (json['replyTo'] is Map ? json['replyTo']['_id'] : null),
      readBy: List<String>.from(json['readBy'] ?? []),
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => Reaction.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
      isSentByMe: false,
      isDeleted: json['isDeleted'] ?? false,
      clientMessageId:
          json['clientMessageId']?.toString() ??
          json['client_message_id']?.toString(),
      status: MessageStatusX.fromString(MessageStatus.sent.name),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'room': roomId,
      'sender': sender.toJson(),
      'senderType': senderType,
      'messageType': messageType,
      'content': content,
      'translatedContent': translatedContent,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'readBy': readBy,
      'replyTo': replyTo?.toJson(),
      'clientMessageId': clientMessageId,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  bool get isAudioMessage =>
      messageType == 'audio' || attachments.any((attachment) => attachment.isAudio);

  bool get isImageMessage =>
      messageType == 'image' ||
      attachments.any((attachment) => attachment.type == 'image');

  bool get isVideoMessage =>
      messageType == 'video' ||
      attachments.any((attachment) => attachment.type == 'video');

  Attachment? get audioAttachment {
    for (final attachment in attachments) {
      if (attachment.isAudio) {
        return attachment;
      }
    }
    return null;
  }

  String get previewText {
    final trimmedContent = content.trim();
    if (trimmedContent.isNotEmpty) {
      return trimmedContent;
    }
    if (isAudioMessage) {
      return 'Voice message';
    }
    if (isVideoMessage) {
      return 'Video';
    }
    if (isImageMessage) {
      return 'Photo';
    }
    if (attachments.isNotEmpty) {
      return 'Attachment';
    }
    return '';
  }

  static String _resolveMessageTypeFromAttachments(List<Attachment> attachments) {
    if (attachments.isEmpty) {
      return 'text';
    }

    final firstAttachment = attachments.first;
    if (firstAttachment.isAudio) {
      return 'audio';
    }
    if (firstAttachment.type.isNotEmpty) {
      return firstAttachment.type;
    }
    return 'text';
  }
}

class Sender {
  final String id;
  final String fullName;
  final String email;

  Sender({required this.id, required this.fullName, required this.email});

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'fullName': fullName, 'email': email};
  }
}

class Attachment {
  final String type;
  final String url;
  final String? name;
  final String? mimeType;
  final int? durationInSeconds;

  Attachment({
    required this.type,
    required this.url,
    this.name,
    this.mimeType,
    this.durationInSeconds,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      type: (json['type'] ?? '').toString().trim().toLowerCase(),
      url: json['url'] ?? '',
      name: json['name']?.toString(),
      mimeType: json['mimeType']?.toString() ?? json['mime_type']?.toString(),
      durationInSeconds: _parseDurationInSeconds(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'name': name,
      'mimeType': mimeType,
      'durationInSeconds': durationInSeconds,
    };
  }

  bool get isAudio {
    if (type == 'audio') {
      return true;
    }
    if (mimeType?.startsWith('audio/') == true) {
      return true;
    }
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.m4a') ||
        lowerUrl.endsWith('.aac') ||
        lowerUrl.endsWith('.mp3') ||
        lowerUrl.endsWith('.wav') ||
        lowerUrl.endsWith('.ogg');
  }

  static int? _parseDurationInSeconds(Map<String, dynamic> json) {
    final rawDuration = json['durationInSeconds'] ?? json['duration'];
    if (rawDuration is num) {
      return rawDuration.toInt();
    }
    if (rawDuration is String) {
      return int.tryParse(rawDuration);
    }
    return null;
  }
}

class Reaction {
  final String user;
  final String emoji;

  Reaction({required this.user, required this.emoji});

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(user: json['user'] ?? '', emoji: json['emoji'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'user': user, 'emoji': emoji};
  }
}
