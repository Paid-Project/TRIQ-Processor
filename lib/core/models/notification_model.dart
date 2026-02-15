// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) =>
    List<NotificationModel>.from(
      json.decode(str).map((x) => NotificationModel.fromJson(x)),
    );

String notificationModelToJson(List<NotificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  String? id;
  String? title;
  String? body;
  String? type;
  String? sender;
  String? receiver;
  String? userImage;
  bool? isRead;
  bool? isActive;
  Data? data;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  NotificationModel({
    this.id,
    this.title,
    this.body,
    this.type,
    this.sender,
    this.receiver,
    this.userImage,
    this.isRead,
    this.isActive,
    this.data,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) => NotificationModel(
    id: json["_id"],
    title: json["title"],
    body: json["body"],
    type: json["type"],
    sender: json["sender"],
    userImage: json["userImage"],
    receiver: json["receiver"],
    isRead: json["isRead"],
    isActive: json["isActive"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "body": body,
    "type": type,
    "sender": sender,
    "userImage": userImage,
    "receiver": receiver,
    "isRead": isRead,
    "isActive": isActive,
    "data": data?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Data {
  String? action;
  String? processorId;
  String? screenName;
  String? ticketId;
  String? machineId;
  String? customerId;

  Data({
    this.action, 
    this.processorId, 
    this.screenName, 
    this.ticketId,
    this.machineId,
    this.customerId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    action: json["action"], 
    processorId: json["processorId"], 
    screenName: json["screenName"], 
    ticketId: json["ticketId"],
    machineId: json["machineId"],
    customerId: json["customerId"],
  );

  Map<String, dynamic> toJson() => {
    "action": action,
    "processorId": processorId,
    "screenName": screenName,
    "ticketId": ticketId,
    "machineId": machineId,
    "customerId": customerId,
  };
}
