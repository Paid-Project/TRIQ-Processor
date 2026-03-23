import 'dart:convert';

class AttachmentsModel {
  final String message;
  final int page;
  final int count;
  final int total;
  final List<AttachmentsDatum> data;

  AttachmentsModel({
    required this.message,
    required this.page,
    required this.count,
    required this.total,
    required this.data,
  });

  factory AttachmentsModel.fromRawJson(String str) => AttachmentsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttachmentsModel.fromJson(Map<String, dynamic> json) => AttachmentsModel(
    message: _readString(json["message"]),
    page: _readInt(json["page"]),
    count: _readInt(json["count"]),
    total: _readInt(json["total"]),
    data: _readAttachmentList(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "page": page,
    "count": count,
    "total": total,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class AttachmentsDatum {
  final Sender sender;
  final DateTime createdAt;
  final String messageId;
  final FileClass file;

  AttachmentsDatum({
    required this.sender,
    required this.createdAt,
    required this.messageId,
    required this.file,
  });

  factory AttachmentsDatum.fromRawJson(String str) => AttachmentsDatum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttachmentsDatum.fromJson(Map<String, dynamic> json) => AttachmentsDatum(
    sender: Sender.fromJson(_readMap(json["sender"])),
    createdAt: _readDateTime(json["createdAt"]),
    messageId: _readString(json["messageId"]),
    file: FileClass.fromJson(_readMap(json["file"])),
  );

  Map<String, dynamic> toJson() => {
    "sender": sender.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "messageId": messageId,
    "file": file.toJson(),
  };

  bool get isImage => file.isImage;
}

class FileClass {
  final String url;
  final String type;
  final String id;

  FileClass({
    required this.url,
    required this.type,
    required this.id,
  });

  factory FileClass.fromRawJson(String str) => FileClass.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FileClass.fromJson(Map<String, dynamic> json) => FileClass(
    url: _readString(json["url"]),
    type: _readString(json["type"]).trim().toLowerCase(),
    id: _readString(json["_id"]),
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "type": type,
    "_id": id,
  };

  bool get isImage {
    if (type == 'image' || type.startsWith('image/')) {
      return true;
    }

    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.endsWith('.bmp') ||
        lowerUrl.endsWith('.heic');
  }
}

class Sender {
  final String id;
  final String fullName;

  Sender({
    required this.id,
    required this.fullName,
  });

  factory Sender.fromRawJson(String str) => Sender.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: _readString(json["_id"]),
    fullName: _readString(json["fullName"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
  };
}

List<AttachmentsDatum> _readAttachmentList(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<Map>()
      .map((item) => AttachmentsDatum.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

String _readString(dynamic value) {
  return value?.toString() ?? '';
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _readDateTime(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
}
