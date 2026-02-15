// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

CustomerModel customerModelFromJson(String str) => CustomerModel.fromJson(json.decode(str));

String customerModelToJson(CustomerModel data) => json.encode(data.toJson());

class CustomerModel {
  int? count;
  List<Customer>? data;

  CustomerModel({this.count, this.data});

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      CustomerModel(count: json["count"], data: json["data"] == null ? [] : List<Customer>.from(json["data"]!.map((x) => Customer.fromJson(x))));

  Map<String, dynamic> toJson() => {"count": count, "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson()))};
}

class Customer {
  String? id;
  Users? organization;
  String? phoneNumber;
  String? customerName;
  String? email;
  String? contactPerson;
  String? designation;
  String? countryOrigin;
  Users? users;
  List<MachineElement>? machines;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? flag;
  String? userImage;
  String? qrCode;

  Customer({
    this.id,
    this.organization,
    this.phoneNumber,
    this.customerName,
    this.email,
    this.contactPerson,
    this.designation,
    this.countryOrigin,
    this.users,
    this.machines,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.flag,
    this.userImage,
    this.qrCode,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["_id"],
    organization:
        json["organization"] == null
            ? null
            : json["organization"] is String
            ? Users(id: json["organization"]) // Handle case where users is a string ID
            : Users.fromJson(json["organization"]),
    phoneNumber: json["phoneNumber"],
    customerName: json["customerName"],
    email: json["email"],
    contactPerson: json["contactPerson"],
    designation: json["designation"],
    countryOrigin: json["countryOrigin"],
    users:
        json["users"] == null
            ? null
            : json["users"] is String
            ? Users(id: json["users"]) // Handle case where users is a string ID
            : Users.fromJson(json["users"]),
    // Handle case where users is an object
    machines: json["machines"] == null ? [] : List<MachineElement>.from(json["machines"]!.map((x) => MachineElement.fromJson(x))),
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    flag: json["flag"],
    userImage: json["userImage"],
    qrCode: json["qrCode"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "organization": organization?.toJson(),
    "phoneNumber": phoneNumber,
    "customerName": customerName,
    "email": email,
    "contactPerson": contactPerson,
    "designation": designation,
    "countryOrigin": countryOrigin,
    "users": users?.toJson(),
    "machines": machines == null ? [] : List<dynamic>.from(machines!.map((x) => x.toJson())),
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "flag": flag,
    "userImage": userImage,
    "qrCode": qrCode,
  };
}

class MachineElement {
  MachineMachine? machine;
  DateTime? purchaseDate;
  DateTime? installationDate;
  DateTime? warrantyStart;
  DateTime? warrantyEnd;
  String? warrantyStatus;
  String? invoiceContractNo;
  String? id;

  MachineElement({
    this.machine,
    this.purchaseDate,
    this.installationDate,
    this.warrantyStart,
    this.warrantyEnd,
    this.warrantyStatus,
    this.invoiceContractNo,
    this.id,
  });

  factory MachineElement.fromJson(Map<String, dynamic> json) => MachineElement(
    machine:
        json["machine"] == null
            ? null
            : json["machine"] is String
            ? MachineMachine(id: json["machine"]) // Handle case where machine is a string ID
            : MachineMachine.fromJson(json["machine"]),
    // Handle case where machine is an object
    purchaseDate: json["purchaseDate"] == null ? null : DateTime.parse(json["purchaseDate"]),
    installationDate: json["installationDate"] == null ? null : DateTime.parse(json["installationDate"]),
    warrantyStart: json["warrantyStart"] == null ? null : DateTime.parse(json["warrantyStart"]),
    warrantyEnd: json["warrantyEnd"] == null ? null : DateTime.parse(json["warrantyEnd"]),
    warrantyStatus: json["warrantyStatus"],
    invoiceContractNo: json["invoiceContractNo"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "machine": machine?.toJson(),
    "purchaseDate": purchaseDate?.toIso8601String(),
    "installationDate": installationDate?.toIso8601String(),
    "warrantyStart": warrantyStart?.toIso8601String(),
    "warrantyEnd": warrantyEnd?.toIso8601String(),
    "warrantyStatus": warrantyStatus,
    "invoiceContractNo": invoiceContractNo,
    "_id": id,
  };
}

class MachineMachine {
  ProcessingDimensions? processingDimensions;
  String? id;
  String? machineName;
  String? modelNumber;
  String? serialNumber;
  String? machineType;
  int? totalPower;
  String? manualsLink;
  String? notes;
  String? status;
  bool? isActive;
  String? remarks;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  MachineMachine({
    this.processingDimensions,
    this.id,
    this.machineName,
    this.modelNumber,
    this.serialNumber,
    this.machineType,
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

  factory MachineMachine.fromJson(Map<String, dynamic> json) => MachineMachine(
    processingDimensions: json["processingDimensions"] == null ? null : ProcessingDimensions.fromJson(json["processingDimensions"]),
    id: json["_id"],
    machineName: json["machineName"],
    modelNumber: json["modelNumber"],
    serialNumber: json["serialNumber"],
    machineType: json["machine_type"],
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

  ProcessingDimensions({this.maxHeight, this.maxWidth, this.minHeight, this.minWidth, this.thickness, this.maxSpeed});

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

class Users {
  String? id;
  String? fullName;
  String? email;
  String? phone;
  String? contactPerson;
  String? designation;

  Users({this.id, this.fullName, this.email, this.phone, this.contactPerson, this.designation});

  factory Users.fromJson(Map<String, dynamic> json) => Users(id: json["_id"], fullName: json["fullName"], email: json["email"], phone:
  json["phone"], contactPerson: json["contactPerson"], designation: json["designation"]);

  Map<String, dynamic> toJson() => {"_id": id, "fullName": fullName, "email": email, "phone": phone, "contactPerson": contactPerson, "designation": designation};
}

