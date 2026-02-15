// To parse this JSON data, do
//
//     final ticketModel = ticketModelFromJson(jsonString);

import 'dart:convert';

TicketModel ticketModelFromJson(String str) =>
    TicketModel.fromJson(json.decode(str));

String ticketModelToJson(TicketModel data) => json.encode(data.toJson());

class TicketModel {
  int? total;
  int? page;
  int? pages;
  int? count;
  List<TicketList>? data;

  TicketModel({this.total, this.page, this.pages, this.count, this.data});

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    total: json["total"],
    page: json["page"],
    pages: json["pages"],
    count: json["count"],
    data:
        json["data"] == null
            ? []
            : List<TicketList>.from(
              json["data"]!.map((x) => TicketList.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "pages": pages,
    "count": count,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class TicketList {
  String? id;
  String? ticketNumber;
  String? problem;
  String? errorCode;
  String? notes;
  List<Media>? media;
  String? ticketType;
  String? type;
  String? status;
  bool? isActive;
  Machine? machine;
  Organisation? processor;
  Organisation? organisation;
  String? pricing;
  String? paymentStatus;
  String? engineerRemark;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? rescheduleUpdateTime;
  DateTime? resolvedAt;
  String? warrantyStatus;
  int? v;
  ChatRoom? chatRoom;
  bool? IsShowChatOption;
  String? rescheduleTime;
  String? flag;
  var resolutionDurationMinutes;

  TicketList({
    this.id,
    this.ticketNumber,
    this.problem,
    this.errorCode,
    this.notes,
    this.media,
    this.ticketType,
    this.type,
    this.status,
    this.isActive,
    this.machine,
    this.processor,
    this.organisation,
    this.engineerRemark,
    this.pricing,
    this.paymentStatus,
    this.rescheduleTime,
    this.rescheduleUpdateTime,
    this.createdAt,
    this.updatedAt,
    this.warrantyStatus,
    this.v,
    this.chatRoom,
    this.IsShowChatOption,
    this.flag,
    this.resolvedAt,
    this.resolutionDurationMinutes,
  });

  factory TicketList.fromJson(Map<String, dynamic> json) => TicketList(
    id: json["_id"],
    ticketNumber: json["ticketNumber"],
    problem: json["problem"],
    errorCode: json["errorCode"],
    rescheduleTime: json["reschedule_time"],
    rescheduleUpdateTime: json["reschedule_update_time"] == null ? null : DateTime.parse(json["reschedule_update_time"]),
      resolvedAt: json["resolvedAt"] == null ? null : DateTime.parse(json["resolvedAt"]),
    notes: json["notes"],
    media:
        json["media"] == null
            ? []
            : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
    ticketType: json["ticketType"],
    type: json["type"],
    status: json["status"],
    isActive: json["isActive"],
    engineerRemark: json["engineerRemark"],
    machine: json["machine"] == null ? null : Machine.fromJson(json["machine"]),
    processor:
        json["processor"] == null
            ? null
            : Organisation.fromJson(json["processor"]),
    organisation:
        json["organisation"] == null
            ? null
            : Organisation.fromJson(json["organisation"]),
    pricing: json["pricing"],
    paymentStatus: json["paymentStatus"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    chatRoom:
        json["chatRoom"] == null ? null : ChatRoom.fromJson(json["chatRoom"]),
    IsShowChatOption: json["IsShowChatOption"],
    warrantyStatus: json["warrantyStatus"],
    flag: json["flag"],

    resolutionDurationMinutes:json["resolutionDurationMinutes"] ,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticketNumber": ticketNumber,
    "problem": problem,
    "errorCode": errorCode,
    "reschedule_time": rescheduleTime,
    "notes": notes,
    "media":
        media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
    "engineerRemark": engineerRemark,
    "ticketType": ticketType,
    "type": type,
    "status": status,
    "isActive": isActive,
    "machine": machine?.toJson(),
    "processor": processor?.toJson(),
    "organisation": organisation?.toJson(),
    "pricing": pricing,
    "paymentStatus": paymentStatus,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "reschedule_update_time": rescheduleUpdateTime,
    "resolvedAt": resolvedAt?.toIso8601String(),
    "resolutionDurationMinutes": resolutionDurationMinutes?.toIso8601String(),
    "__v": v,
    "chatRoom": chatRoom?.toJson(),
    "IsShowChatOption": IsShowChatOption,
    "warrantyStatus": warrantyStatus,
    "flag": flag,
  };
}

class Machine {
  ProcessingDimensions? processingDimensions;
  String? id;
  String? machineName;
  String? modelNumber;
  String? serialNumber;
  String? machineType;
  String? user;
  int? totalPower;
  String? manualsLink;
  String? notes;
  String? status;
  bool? isActive;
  String? remarks;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Machine({
    this.processingDimensions,
    this.id,
    this.machineName,
    this.modelNumber,
    this.serialNumber,
    this.machineType,
    this.user,
    this.totalPower,
    this.manualsLink,
    this.notes,
    this.status,
    this.isActive,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
    processingDimensions:
        json["processingDimensions"] == null
            ? null
            : ProcessingDimensions.fromJson(json["processingDimensions"]),
    id: json["_id"],
    machineName: json["machineName"],
    modelNumber: json["modelNumber"],
    serialNumber: json["serialNumber"],
    machineType: json["machine_type"],
    user: json["user"],
    totalPower: json["totalPower"],
    manualsLink: json["manualsLink"],
    notes: json["notes"],
    status: json["status"],
    isActive: json["isActive"],
    remarks: json["remarks"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "processingDimensions": processingDimensions?.toJson(),
    "_id": id,
    "machineName": machineName,
    "modelNumber": modelNumber,
    "serialNumber": serialNumber,
    "machine_type": machineType,
    "user": user,
    "totalPower": totalPower,
    "manualsLink": manualsLink,
    "notes": notes,
    "status": status,
    "isActive": isActive,
    "remarks": remarks,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ProcessingDimensions {
  int? maxHeight;
  int? maxWidth;
  int? minHeight;
  int? minWidth;
  String? thickness;
  int? maxSpeed;

  ProcessingDimensions({
    this.maxHeight,
    this.maxWidth,
    this.minHeight,
    this.minWidth,
    this.thickness,
    this.maxSpeed,
  });

  factory ProcessingDimensions.fromJson(Map<String, dynamic> json) =>
      ProcessingDimensions(
        maxHeight: json["maxHeight"],
        maxWidth: json["maxWidth"],
        minHeight: json["minHeight"],
        minWidth: json["minWidth"],
        thickness: json["thickness"],
        maxSpeed: json["maxSpeed"],
      );

  Map<String, dynamic> toJson() => {
    "maxHeight": maxHeight,
    "maxWidth": maxWidth,
    "minHeight": minHeight,
    "minWidth": minWidth,
    "thickness": thickness,
    "maxSpeed": maxSpeed,
  };
}

class Media {
  String? url;
  String? type;
  String? id;

  Media({this.url, this.type, this.id});

  factory Media.fromJson(Map<String, dynamic> json) =>
      Media(url: json["url"], type: json["type"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"url": url, "type": type, "_id": id};
}

class Organisation {
  String? id;
  String? fullName;
  String? email;
  String? password;
  String? phone;
  String? countryCode;
  List<String>? roles;
  String? emailOtp;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  int? v;

  Organisation({
    this.id,
    this.fullName,
    this.email,
    this.password,
    this.phone,
    this.countryCode,
    this.roles,
    this.emailOtp,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.v,
  });

  factory Organisation.fromJson(Map<String, dynamic> json) => Organisation(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
    password: json["password"],
    phone: json["phone"],
    countryCode: json["countryCode"],
    roles:
        json["roles"] == null
            ? []
            : List<String>.from(json["roles"]!.map((x) => x)),
    emailOtp: json["emailOTP"],
    isEmailVerified: json["isEmailVerified"],
    isPhoneVerified: json["isPhoneVerified"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
    "password": password,
    "phone": phone,
    "countryCode": countryCode,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "emailOTP": emailOtp,
    "isEmailVerified": isEmailVerified,
    "isPhoneVerified": isPhoneVerified,
    "__v": v,
  };
}

class ChatRoom {
  String? id;
  String? ticket;
  ChatUser? organisation;
  ChatUser? processor;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ChatRoom({
    this.id,
    this.ticket,
    this.organisation,
    this.processor,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
    id: json["_id"],
    ticket: json["ticket"],
    organisation:
        json["organisation"] == null
            ? null
            : ChatUser.fromJson(json["organisation"]),
    processor:
        json["processor"] == null ? null : ChatUser.fromJson(json["processor"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticket": ticket,
    "organisation": organisation?.toJson(),
    "processor": processor?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ChatUser {
  String? id;
  String? fullName;
  String? email;

  ChatUser({this.id, this.fullName, this.email});

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
  };
}
