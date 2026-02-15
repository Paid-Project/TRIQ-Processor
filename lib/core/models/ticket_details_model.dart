// To parse this JSON data, do
//
//     final ticketDetailsModel = ticketDetailsModelFromJson(jsonString);

import 'dart:convert';

TicketDetailsModel ticketDetailsModelFromJson(String str) => TicketDetailsModel.fromJson(json.decode(str));

String ticketDetailsModelToJson(TicketDetailsModel data) => json.encode(data.toJson());

class TicketDetailsModel {
  TicketDetails? ticketDetails;
  MachineDetails? machineDetails;
  CustomerMachineDetails? customerMachineDetails;
  Details? processorDetails;
  Details? organisationDetails;
  PricingDetails? pricingDetails;
  ChatRoom? chatRoom;
  String? role;


  TicketDetailsModel({
    this.ticketDetails,
    this.machineDetails,
    this.customerMachineDetails,
    this.processorDetails,
    this.organisationDetails,
    this.pricingDetails,
    this.chatRoom,
    this.role,


  });

  factory TicketDetailsModel.fromJson(Map<String, dynamic> json) => TicketDetailsModel(
    ticketDetails: json["ticketDetails"] == null ? null : TicketDetails.fromJson(json["ticketDetails"]),
    machineDetails: json["machineDetails"] == null ? null : MachineDetails.fromJson(json["machineDetails"]),
    customerMachineDetails: json["customerMachineDetails"] == null ? null : CustomerMachineDetails.fromJson(json["customerMachineDetails"]),
    processorDetails: json["processorDetails"] == null ? null : Details.fromJson(json["processorDetails"]),
    organisationDetails: json["organisationDetails"] == null ? null : Details.fromJson(json["organisationDetails"]),
    pricingDetails: json["pricingDetails"] == null ? null : PricingDetails.fromJson(json["pricingDetails"]),
    chatRoom: json["chatRoom"] == null ? null : ChatRoom.fromJson(json["chatRoom"]),
    role: json["role"],

  );

  Map<String, dynamic> toJson() => {
    "ticketDetails": ticketDetails?.toJson(),
    "machineDetails": machineDetails?.toJson(),
    "customerMachineDetails": customerMachineDetails?.toJson(),
    "processorDetails": processorDetails?.toJson(),
    "organisationDetails": organisationDetails?.toJson(),
    "pricingDetails": pricingDetails?.toJson(),
    "chatRoom": chatRoom?.toJson(),
  };
}

class CustomerMachineDetails {
  String? machine;
  DateTime? purchaseDate;
  DateTime? installationDate;
  DateTime? warrantyStart;
  DateTime? warrantyEnd;
  String? warrantyStatus;
  String? invoiceContractNo;
  String? id;

  CustomerMachineDetails({
    this.machine,
    this.purchaseDate,
    this.installationDate,
    this.warrantyStart,
    this.warrantyEnd,
    this.warrantyStatus,
    this.invoiceContractNo,
    this.id,
  });

  factory CustomerMachineDetails.fromJson(Map<String, dynamic> json) => CustomerMachineDetails(
    machine: json["machine"],
    purchaseDate: json["purchaseDate"] == null ? null : DateTime.parse(json["purchaseDate"]),
    installationDate: json["installationDate"] == null ? null : DateTime.parse(json["installationDate"]),
    warrantyStart: json["warrantyStart"] == null ? null : DateTime.parse(json["warrantyStart"]),
    warrantyEnd: json["warrantyEnd"] == null ? null : DateTime.parse(json["warrantyEnd"]),
    warrantyStatus: json["warrantyStatus"],
    invoiceContractNo: json["invoiceContractNo"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "machine": machine,
    "purchaseDate": purchaseDate?.toIso8601String(),
    "installationDate": installationDate?.toIso8601String(),
    "warrantyStart": warrantyStart?.toIso8601String(),
    "warrantyEnd": warrantyEnd?.toIso8601String(),
    "warrantyStatus": warrantyStatus,
    "invoiceContractNo": invoiceContractNo,
    "_id": id,
  };
}

class MachineDetails {
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

  MachineDetails({
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

  factory MachineDetails.fromJson(Map<String, dynamic> json) => MachineDetails(
    processingDimensions: json["processingDimensions"] == null ? null : ProcessingDimensions.fromJson(json["processingDimensions"]),
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
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
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

  factory ProcessingDimensions.fromJson(Map<String, dynamic> json) => ProcessingDimensions(
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

class Details {
  String? id;
  String? fullName;
  String? email;
  String? phone;
  String? countryCode;
  String? flag;
  String? userImage;

  Details({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.countryCode,
    this.flag,
    this.userImage,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
    phone: json["phone"],
    countryCode: json["countryCode"],
    flag: json["flag"],
    userImage: json["userImage"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "countryCode": countryCode,
    "flag": flag,
    "userImage": userImage,
  };
}

class PricingDetails {
  String? supportMode;
  String? warrantyStatus;
  String? ticketType;
  int? cost;
  String? currency;
  String? id;

  PricingDetails({
    this.supportMode,
    this.warrantyStatus,
    this.ticketType,
    this.cost,
    this.currency,
    this.id,
  });

  factory PricingDetails.fromJson(Map<String, dynamic> json) => PricingDetails(
    supportMode: json["supportMode"],
    warrantyStatus: json["warrantyStatus"],
    ticketType: json["ticketType"],
    cost: json["cost"],
    currency: json["currency"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "supportMode": supportMode,
    "warrantyStatus": warrantyStatus,
    "ticketType": ticketType,
    "cost": cost,
    "currency": currency,
    "_id": id,
  };
}

class TicketDetails {
  String? id;
  String? ticketNumber;
  String? problem;
  String? errorCode;
  String? status;
  String? type;
  String? ticketType;
  String? notes;
  String? engineerRemark;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? paymentStatus;
  List<Media>? media;
  bool? IsShowChatOption;
  bool? isFirstTimeServiceDone;
  DateTime? resolvedAt;
  var resolutionDurationMinutes;
  TicketDetails({
    this.id,
    this.ticketNumber,
    this.problem,
    this.errorCode,
    this.status,
    this.type,
    this.ticketType,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.paymentStatus,
    this.media,
    this.IsShowChatOption,
    this.engineerRemark,
    this.isFirstTimeServiceDone,
    this.resolvedAt,
    this.resolutionDurationMinutes
  });

  factory TicketDetails.fromJson(Map<String, dynamic> json) => TicketDetails(
    id: json["id"],
    ticketNumber: json["ticketNumber"],
    problem: json["problem"],
    errorCode: json["errorCode"],
    status: json["status"],
    type: json["type"],
    ticketType: json["ticketType"],
    engineerRemark: json["engineerRemark"],
    notes: json["notes"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    paymentStatus: json["paymentStatus"],
    media: json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
    IsShowChatOption: json["IsShowChatOption"],
    isFirstTimeServiceDone: json["isFirstTimeServiceDone"],
    resolvedAt: json["resolvedAt"] == null ? null : DateTime.parse(json["resolvedAt"]),
    resolutionDurationMinutes:json["resolutionDurationMinutes"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticketNumber": ticketNumber,
    "problem": problem,
    "errorCode": errorCode,
    "status": status,
    "type": type,
    "ticketType": ticketType,
    "notes": notes,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "paymentStatus": paymentStatus,
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
    "IsShowChatOption": IsShowChatOption,
    "engineerRemark": engineerRemark,
    "isFirstTimeServiceDone": isFirstTimeServiceDone,
    "resolvedAt": resolvedAt?.toIso8601String(),
    "resolutionDurationMinutes":resolutionDurationMinutes
  };
}

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
    organisation: json["organisation"] == null ? null : ChatUser.fromJson(json["organisation"]),
    processor: json["processor"] == null ? null : ChatUser.fromJson(json["processor"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
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

  ChatUser({
    this.id,
    this.fullName,
    this.email,
  });

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
