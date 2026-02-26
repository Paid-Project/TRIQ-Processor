import '../../../resources/enums/chat_enum.dart';

class ChatMessageModel {
  final String id;
  final String roomId;
  final Sender sender;
  final String senderType;
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
  MessageStatus status;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.sender,
    required this.senderType,
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
    this.reactions = const [],
    required this.status,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Handle case where sender is just an ID string instead of an object
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

    return ChatMessageModel(
      id: json['_id'] ?? '',
      roomId: json['room'] ?? '',
      sender: sender,
      content: json['content'] ?? '',
      senderType: json['senderType'] ?? '',
      translatedContent: json['translatedContent'] ?? '',
      attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e))
          .toList() ??
          [],
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
      status: MessageStatusX.fromString(MessageStatus.sent.name),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'room': roomId,
      'sender': sender.toJson(),
      'content': content,
      'translatedContent': translatedContent,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'readBy': readBy,
      "replyTo": replyTo?.toJson(),
      'isDeleted': isDeleted,
      'senderType': senderType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
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
  final String type; // image, video, document
  final String url;

  Attachment({required this.type, required this.url});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(type: json['type'] ?? '', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'url': url};
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
