// To parse this JSON data, do
//
//     final chatListModel = chatListModelFromJson(jsonString);


import 'dart:convert';

ChatListModel chatListModelFromJson(String str) => ChatListModel.fromJson(json.decode(str));

String chatListModelToJson(ChatListModel data) => json.encode(data.toJson());

int _intFrom(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _boolFrom(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value?.toString().toLowerCase().trim();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return fallback;
}

DateTime _dateTimeFrom(dynamic value, [DateTime? fallback]) {
  final fb = fallback ?? DateTime.now();
  if (value is DateTime) return value;
  final s = value?.toString();
  if (s == null || s.isEmpty) return fb;
  return DateTime.tryParse(s) ?? fb;
}

DateTime? _dateTimeOrNullFrom(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final s = value.toString();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}

class ChatListModel {
  String message;
  int total;
  List<Chats> chats;

  ChatListModel({
    required this.message,
    required this.total,
    required this.chats,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
    message: (json["message"] ?? "").toString(),
    total: _intFrom(json["total"]),
    chats:
    (json["chats"] is List ? (json["chats"] as List) : const [])
        .whereType<Map>()
        .map((x) => Chats.fromJson(Map<String, dynamic>.from(x)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "total": total,
    "chats": List<dynamic>.from(chats.map((x) => x.toJson())),
  };
}

class Chats {
  String id;
  String type;
  String? groupTitle;
  Ticket ticket;
  ChatWith chatWith;
  List<ChatWith> members;
  LastMessage? lastMessage;
  int unreadCount;
  DateTime updatedAt;

  Chats({
    required this.id,
    required this.type,
    this.groupTitle,
    required this.ticket,
    required this.chatWith,
    required this.members,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  static String? _extractGroupTitle(Map<String, dynamic> json) {
    dynamic candidate =
        json['groupTitle'] ??
            json['groupName'] ??
            json['roomTitle'] ??
            json['roomName'] ??
            json['title'] ??
            json['name'];

    if (candidate == null && json['group'] is Map) {
      final groupMap = Map<String, dynamic>.from(json['group'] as Map);
      candidate =
          groupMap['title'] ??
              groupMap['name'] ??
              groupMap['groupTitle'] ??
              groupMap['groupName'];
    }

    final s = candidate?.toString().trim();
    if (s == null || s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
    id: (json["_id"] ?? "").toString(),
    type: (json["type"] ?? "").toString(),
    groupTitle: _extractGroupTitle(json),
    ticket:
    Ticket.fromJson(
      json["ticket"] is Map ? Map<String, dynamic>.from(json["ticket"]) : const {},
    ),
    chatWith:
    ChatWith.fromJson(
      json["chatWith"] is Map
          ? Map<String, dynamic>.from(json["chatWith"])
          : const {},
    ),
    members:
    (json["members"] is List ? (json["members"] as List) : const [])
        .whereType<Map>()
        .map((x) => ChatWith.fromJson(Map<String, dynamic>.from(x)))
        .toList(),
    lastMessage:
    json["lastMessage"] is Map
        ? LastMessage.fromJson(Map<String, dynamic>.from(json["lastMessage"]))
        : null,
    unreadCount: _intFrom(json["unreadCount"]),
    updatedAt: _dateTimeFrom(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "groupTitle": groupTitle,
    "ticket": ticket.toJson(),
    "chatWith": chatWith.toJson(),
    "members": List<dynamic>.from(members.map((x) => x.toJson())),
    "lastMessage": lastMessage?.toJson(),
    "unreadCount": unreadCount,
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class ChatWith {
  String id;
  String fullName;
  String email;
  String countryCode;
  String? flag;

  ChatWith({
    required this.id,
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.flag,
  });

  factory ChatWith.fromJson(Map<String, dynamic> json) => ChatWith(
    id: (json["_id"] ?? "").toString(),
    fullName: (json["fullName"] ?? "").toString(),
    email: (json["email"] ?? "").toString(),
    countryCode: (json["countryCode"] ?? "").toString(),
    flag: json["flag"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
    "countryCode": countryCode,
    "flag": flag,
  };
}

class Ticket {
  String id;
  String ticketNumber;
  String problem;
  String errorCode;
  String notes;
  List<Media>? media;
  String ticketType;
  String type;
  String status;
  bool isActive;
  String machine;
  String processor;
  String organisation;
  String pricing;
  String paymentStatus;
  bool isShowChatOption;
  bool isFirstTimeServiceDone;
  dynamic resolvedAt;
  dynamic resolutionDurationMinutes;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String? rescheduleTime;
  DateTime? rescheduleUpdateTime;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.problem,
    required this.errorCode,
    required this.notes,
    required this.media,
    required this.ticketType,
    required this.type,
    required this.status,
    required this.isActive,
    required this.machine,
    required this.processor,
    required this.organisation,
    required this.pricing,
    required this.paymentStatus,
    required this.isShowChatOption,
    required this.isFirstTimeServiceDone,
    required this.resolvedAt,
    required this.resolutionDurationMinutes,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.rescheduleTime,
    this.rescheduleUpdateTime,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: (json["_id"] ?? "").toString(),
    ticketNumber: (json["ticketNumber"] ?? "").toString(),
    problem: (json["problem"] ?? "").toString(),
    errorCode: (json["errorCode"] ?? "").toString(),
    notes: (json["notes"] ?? "").toString(),
    media:
    (json["media"] is List ? (json["media"] as List) : const [])
        .whereType<Map>()
        .map((x) => Media.fromJson(Map<String, dynamic>.from(x)))
        .toList(),
    ticketType: (json["ticketType"] ?? "").toString(),
    type: (json["type"] ?? "").toString(),
    status: (json["status"] ?? "").toString(),
    isActive: _boolFrom(json["isActive"], true),
    machine: (json["machine"] ?? "").toString(),
    processor: (json["processor"] ?? "").toString(),
    organisation: (json["organisation"] ?? "").toString(),
    pricing: (json["pricing"] ?? "").toString(),
    paymentStatus: (json["paymentStatus"] ?? "").toString(),
    isShowChatOption:
    _boolFrom(json["IsShowChatOption"] ?? json["isShowChatOption"]),
    isFirstTimeServiceDone: _boolFrom(json["isFirstTimeServiceDone"]),
    resolvedAt: json["resolvedAt"],
    resolutionDurationMinutes: json["resolutionDurationMinutes"],
    createdAt: _dateTimeFrom(json["createdAt"]),
    updatedAt: _dateTimeFrom(json["updatedAt"]),
    v: _intFrom(json["__v"] ?? json["v"]),
    rescheduleTime: json["reschedule_time"]?.toString(),
    rescheduleUpdateTime: _dateTimeOrNullFrom(json["reschedule_update_time"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticketNumber": ticketNumber,
    "problem": problem,
    "errorCode": errorCode,
    "notes": notes,
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
    "ticketType": ticketType,
    "type": type,
    "status": status,
    "isActive": isActive,
    "machine": machine,
    "processor": processor,
    "organisation": organisation,
    "pricing": pricing,
    "paymentStatus": paymentStatus,
    "IsShowChatOption": isShowChatOption,
    "isFirstTimeServiceDone": isFirstTimeServiceDone,
    "resolvedAt": resolvedAt,
    "resolutionDurationMinutes": resolutionDurationMinutes,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
    "reschedule_time": rescheduleTime,
    "reschedule_update_time": rescheduleUpdateTime?.toIso8601String(),
  };
}




// // To parse this JSON data, do
// //
// //     final chatListModel = chatListModelFromJson(jsonString);
//
// import 'dart:convert';
//
// // Yah function JSON string (jo ek list hai) ko List<ChatListModel> mein convert karta hai
// List<ChatListModel> chatListModelFromJson(String str) => List<ChatListModel>.from(json.decode(str).map((x) => ChatListModel.fromJson(x)));
//
// // Yah function List<ChatListModel> ko wapas JSON string mein convert karta hai
// String chatListModelToJson(List<ChatListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class ChatListModel {
//   String? id;
//   Ticket? ticket;
//   ChatWith? chatWith;
//   int? unreadCount; // NEW
//   LastMessage? lastMessage; // NEW
//
//   ChatListModel({
//     this.id,
//     this.ticket,
//     this.chatWith,
//     this.unreadCount, // NEW
//     this.lastMessage, // NEW
//   });
//
//   factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
//     id: json["_id"],
//     ticket: json["ticket"] == null ? null : Ticket.fromJson(json["ticket"]),
//     chatWith: json["chatWith"] == null ? null : ChatWith.fromJson(json["chatWith"]),
//     unreadCount: json["unreadCount"], // NEW
//     lastMessage: json["lastMessage"] == null ? null : LastMessage.fromJson(json["lastMessage"]), // NEW
//   );
//
//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "ticket": ticket?.toJson(),
//     "chatWith": chatWith?.toJson(),
//     "unreadCount": unreadCount, // NEW
//     "lastMessage": lastMessage?.toJson(), // NEW
//   };
// }
//
// // Naye 'lastMessage' object ke liye nayi class
class LastMessage {
  String id;
  String room;
  String sender;
  String content;
  String translatedContent;
  List<dynamic> attachments;
  dynamic replyTo;
  bool edited;
  bool isDeleted;
  List<String> readBy;
  List<dynamic> reactions;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  LastMessage({
    required this.id,
    required this.room,
    required this.sender,
    required this.content,
    required this.translatedContent,
    required this.attachments,
    required this.replyTo,
    required this.edited,
    required this.isDeleted,
    required this.readBy,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
    id: (json["_id"] ?? "").toString(),
    room: (json["room"] ?? "").toString(),
    sender: (json["sender"] ?? "").toString(),
    content: (json["content"] ?? "").toString(),
    translatedContent: (json["translatedContent"] ?? "").toString(),
    attachments:
    (json["attachments"] is List ? (json["attachments"] as List) : const [])
        .toList(),
    replyTo: json["replyTo"],
    edited: _boolFrom(json["edited"]),
    isDeleted: _boolFrom(json["isDeleted"]),
    readBy:
    (json["readBy"] is List ? (json["readBy"] as List) : const [])
        .map((x) => x.toString())
        .toList(),
    reactions:
    (json["reactions"] is List ? (json["reactions"] as List) : const [])
        .toList(),
    createdAt: _dateTimeFrom(json["createdAt"]),
    updatedAt: _dateTimeFrom(json["updatedAt"]),
    v: _intFrom(json["__v"] ?? json["v"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "room": room,
    "sender": sender,
    "content": content,
    "translatedContent": translatedContent,
    "attachments": List<dynamic>.from(attachments.map((x) => x)),
    "replyTo": replyTo,
    "edited": edited,
    "isDeleted": isDeleted,
    "readBy": List<dynamic>.from(readBy.map((x) => x)),
    "reactions": List<dynamic>.from(reactions.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

//
// class ChatWith {
//   String? id;
//   String? fullName;
//   String? email;
//   String? countryCode; // NEW
//   String? flag;
//
//   ChatWith({
//     this.id,
//     this.fullName,
//     this.email,
//     this.countryCode, // NEW
//     this.flag,
//   });
//
//   factory ChatWith.fromJson(Map<String, dynamic> json) => ChatWith(
//     id: json["_id"],
//     fullName: json["fullName"],
//     email: json["email"],
//     countryCode: json["countryCode"], // NEW
//     flag: json["flag"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "fullName": fullName,
//     "email": email,
//     "countryCode": countryCode, // NEW
//     "flag": flag,
//   };
// }
//
// class Ticket {
//   String? id;
//   String? ticketNumber;
//   String? problem;
//   String? errorCode;
//   String? notes;
//   List<Media>? media;
//   String? ticketType;
//   String? type;
//   String? status;
//   bool? isActive;
//   String? machine;
//   String? processor;
//   String? flag;
//   String? organisation;
//   String? pricing;
//   String? paymentStatus;
//   bool? isShowChatOption; // NEW
//   bool? isFirstTimeServiceDone; // NEW
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   DateTime? rescheduleUpdateTime;
//   int? v;
//
//   Ticket({
//     this.id,
//     this.ticketNumber,
//     this.problem,
//     this.errorCode,
//     this.notes,
//     this.media,
//     this.ticketType,
//     this.type,
//     this.status,
//     this.isActive,
//     this.machine,
//     this.processor,
//     this.organisation,
//     this.pricing,
//     this.paymentStatus,
//     this.isShowChatOption, // NEW
//     this.isFirstTimeServiceDone, // NEW
//     this.createdAt,
//     this.updatedAt,
//     this.flag,
//     this.rescheduleUpdateTime,
//     this.v,
//   });
//
//   factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
//     id: json["_id"],
//     ticketNumber: json["ticketNumber"],
//     problem: json["problem"],
//     errorCode: json["errorCode"],
//     notes: json["notes"],
//     media: json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
//     ticketType: json["ticketType"],
//     type: json["type"],
//     status: json["status"],
//     isActive: json["isActive"],
//     machine: json["machine"],
//     processor: json["processor"],
//     organisation: json["organisation"],
//     pricing: json["pricing"],
//     paymentStatus: json["paymentStatus"],
//     isShowChatOption: json["IsShowChatOption"], // NEW - JSON key 'IsShowChatOption' se map kiya
//     isFirstTimeServiceDone: json["isFirstTimeServiceDone"], // NEW
//     flag: json["flag"],
//     rescheduleUpdateTime: json["reschedule_update_time"] == null ? null : DateTime.parse(json["reschedule_update_time"]),
//     createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
//     updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
//     v: json["__v"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "ticketNumber": ticketNumber,
//     "problem": problem,
//     "errorCode": errorCode,
//     "notes": notes,
//     "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
//     "ticketType": ticketType,
//     "type": type,
//     "status": status,
//     "isActive": isActive,
//     "machine": machine,
//     "processor": processor,
//     "organisation": organisation,
//     "pricing": pricing,
//     "paymentStatus": paymentStatus,
//     "IsShowChatOption": isShowChatOption, // NEW - JSON key 'IsShowChatOption' se map kiya
//     "isFirstTimeServiceDone": isFirstTimeServiceDone, // NEW
//     "flag": flag,
//     "reschedule_update_time":rescheduleUpdateTime?.toIso8601String(),
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//   };
// }
//
class Media {
  String? url;
  String? type;
  String? id;

  Media({
    this.url,
    this.type,
    this.id,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    url: json["url"],
    type: json["type"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "type": type,
    "_id": id,
  };
}
