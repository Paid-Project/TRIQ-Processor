import 'dart:convert';

class ViewersModel {
  String type;
  int count;
  List<ViewUser> users;

  ViewersModel({
    required this.type,
    required this.count,
    required this.users,
  });

  factory ViewersModel.fromRawJson(String str) => ViewersModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ViewersModel.fromJson(Map<String, dynamic> json) => ViewersModel(
    type: json["type"],
    count: json["count"],
    users: List<ViewUser>.from(json["users"].map((x) => ViewUser.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "count": count,
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
  };
}

class ViewUser {
  String id;
  String fullName;
  final DateTime? seenAt;

  ViewUser({
    required this.id,
    required this.fullName,
     this.seenAt,
  });

  factory ViewUser.fromRawJson(String str) => ViewUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  static DateTime? _parseDate(dynamic value) {
    final rawValue = value?.toString() ?? '';
    if (rawValue.isEmpty) return null;
    return DateTime.tryParse(rawValue);
  }

  factory ViewUser.fromJson(Map<String, dynamic> json) => ViewUser(
    id: (json["_id"] ?? json["id"] ?? '').toString(),
    fullName: (json["fullName"] ?? json["name"] ?? json["userName"] ?? '').toString(),
    seenAt: _parseDate(json['seenAt'] ?? json['readAt'] ?? json['viewedAt']),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "seenAt": seenAt?.toIso8601String() ?? "",
  };
}
