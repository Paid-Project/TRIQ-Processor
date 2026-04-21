import 'dart:convert';

class ViewersModel {
  String messageId;
  int totalRecipients;
  int readCount;
  int unreadCount;
  List<SeenBy> seenBy;
  List<SeenBy> unseenBy;

  ViewersModel({
    required this.messageId,
    required this.totalRecipients,
    required this.readCount,
    required this.unreadCount,
    required this.seenBy,
    required this.unseenBy,
  });

  factory ViewersModel.fromRawJson(String str) => ViewersModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ViewersModel.fromJson(Map<String, dynamic> json) => ViewersModel(
    messageId: json["messageId"],
    totalRecipients: json["totalRecipients"],
    readCount: json["readCount"],
    unreadCount: json["unreadCount"],
    seenBy: List<SeenBy>.from(json["seenBy"].map((x) => SeenBy.fromJson(x))),
    unseenBy: List<SeenBy>.from(json["unseenBy"].map((x) => SeenBy.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "messageId": messageId,
    "totalRecipients": totalRecipients,
    "readCount": readCount,
    "unreadCount": unreadCount,
    "seenBy": List<dynamic>.from(seenBy.map((x) => x.toJson())),
    "unseenBy": List<dynamic>.from(unseenBy.map((x) => x.toJson())),
  };
}

class SeenBy {
  String id;
  String fullName;
  dynamic profileImage;
  DateTime? seenAt;

  SeenBy({
    required this.id,
    required this.fullName,
    required this.profileImage,
    this.seenAt,
  });

  factory SeenBy.fromRawJson(String str) => SeenBy.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SeenBy.fromJson(Map<String, dynamic> json) {
    DateTime? parseSeen(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    final id =
        (json["_id"] ?? json["id"] ?? json["userId"] ?? json["user"] ?? '')
            .toString();
    final fullName = (json["fullName"] ??
            json["name"] ??
            json["email"] ??
            '')
        .toString();

    return SeenBy(
      id: id,
      fullName: fullName,
      profileImage: json["profileImage"] ?? json["avatar"] ?? json["image"],
      seenAt: parseSeen(
        json["seenAt"] ??
            json["readAt"] ??
            json["read_at"] ??
            json["updatedAt"],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "profileImage": profileImage,
    "seenAt": seenAt?.toIso8601String(),
  };
}

/// Parses viewers API payloads: supports `seenBy` / `unseenBy`, nested `data`, and legacy `users` / `viewers`.
class ViewersListsSplit {
  final List<SeenBy> seen;
  final List<SeenBy> unseen;
  final int readCount;
  final int unreadCount;

  const ViewersListsSplit({
    required this.seen,
    required this.unseen,
    required this.readCount,
    required this.unreadCount,
  });

  static int _asInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static List<SeenBy> _parseList(dynamic v) {
    if (v is! List) return [];
    final out = <SeenBy>[];
    for (final item in v) {
      if (item is Map) {
        try {
          out.add(SeenBy.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
    }
    return out;
  }

  factory ViewersListsSplit.fromApi(dynamic raw) {
    if (raw is List) {
      final combined = _parseList(raw);
      final seen = <SeenBy>[];
      final unseen = <SeenBy>[];
      for (final u in combined) {
        if (u.seenAt != null) {
          seen.add(u);
        } else {
          unseen.add(u);
        }
      }
      return ViewersListsSplit(
        seen: seen,
        unseen: unseen,
        readCount: seen.length,
        unreadCount: unseen.length,
      );
    }

    final rootMap =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    Map<String, dynamic> root = rootMap;

    final nested = root['data'];
    if (nested is Map) {
      root = Map<String, dynamic>.from(nested);
    } else if (nested is List) {
      final combined = _parseList(nested);
      final seen = <SeenBy>[];
      final unseen = <SeenBy>[];
      for (final u in combined) {
        if (u.seenAt != null) {
          seen.add(u);
        } else {
          unseen.add(u);
        }
      }
      return ViewersListsSplit(
        seen: seen,
        unseen: unseen,
        readCount: seen.length,
        unreadCount: unseen.length,
      );
    }

    var seen = _parseList(root['seenBy']);
    if (seen.isEmpty) seen = _parseList(root['seen_by']);

    var unseen = _parseList(root['unseenBy']);
    if (unseen.isEmpty) unseen = _parseList(root['unseen_by']);

    var readCount = _asInt(root['readCount'] ?? root['read_count'], seen.length);
    var unreadCount =
        _asInt(root['unreadCount'] ?? root['unread_count'], unseen.length);

    if (seen.isEmpty && unseen.isEmpty) {
      for (final key in ['users', 'viewers', 'recipients']) {
        final list = root[key];
        if (list is List && list.isNotEmpty) {
          final all = _parseList(list);
          for (final u in all) {
            if (u.seenAt != null) {
              seen.add(u);
            } else {
              unseen.add(u);
            }
          }
          readCount = seen.length;
          unreadCount = unseen.length;
          break;
        }
      }
    }

    return ViewersListsSplit(
      seen: seen,
      unseen: unseen,
      readCount: readCount,
      unreadCount: unreadCount,
    );
  }
}
