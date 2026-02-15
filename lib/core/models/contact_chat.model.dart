class ContactChat {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String department;
  final String profilePhoto;
  final String status;
  final String? organizationName; // Response mein nahi hai, isliye null rahega
  final String type;
  final String? flag;
  final ChatRoom chatRoom;

  ContactChat({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.department,
    required this.profilePhoto,
    required this.status,
    this.flag,
    this.organizationName,
    required this.type,
    required this.chatRoom,
  });

  factory ContactChat.fromJson(Map<String, dynamic> json) {
    return ContactChat(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      status: json['status'] ?? '',
      flag: json['flag'], // Ab yeh response mein hai
      organizationName: json['organizationName'], // Yeh key response mein nahi hai, isliye null aayega
      type: json['type'] ?? '',
      // Yeh line updated ChatRoom.fromJson ko call karegi
      chatRoom: ChatRoom.fromJson(json['chatRoom'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'department': department,
      'profilePhoto': profilePhoto,
      'status': status,
      'flag': flag,
      'organizationName': organizationName,
      'type': type,
      'chatRoom': chatRoom.toJson(),
    };
  }
}

// ======================================================
// ===          UPDATED ChatRoom MODEL                ===
// ======================================================
class ChatRoom {
  final bool exists;
  final String? roomId;
  final bool hasMessages;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  ChatRoom({
    required this.exists,
    this.roomId,
    required this.hasMessages, // <-- ADDED to constructor
    this.lastMessage,         // <-- ADDED to constructor
    this.lastMessageTime,         // <-- ADDED to constructor
    required this.unreadCount, // <-- ADDED to constructor
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      exists: json['exists'] ?? false,
      roomId: json['roomId'],
      // Parse new fields with safe defaults
      hasMessages: json['hasMessages'] ?? false,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime']??'',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'roomId': roomId,
      'hasMessages': hasMessages,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
    };
  }
}