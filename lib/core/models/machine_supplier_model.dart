// To parse this JSON data, do
//
//     final machineSupplierModel = machineSupplierModelFromJson(jsonString);

import 'dart:convert';

MachineSupplierModel machineSupplierModelFromJson(String str) => MachineSupplierModel.fromJson(json.decode(str));

String machineSupplierModelToJson(MachineSupplierModel data) => json.encode(data.toJson());

class MachineSupplierModel {
  List<MachineSupplier>? data;

  MachineSupplierModel({
    this.data,
  });

  factory MachineSupplierModel.fromJson(Map<String, dynamic> json) => MachineSupplierModel(
    data: json["data"] == null ? [] : List<MachineSupplier>.from(json["data"]!.map((x) => MachineSupplier.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class MachineSupplier {
  Customer? customer;

  MachineSupplier({
    this.customer,
  });

  factory MachineSupplier.fromJson(Map<String, dynamic> json) => MachineSupplier(
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
  );

  Map<String, dynamic> toJson() => {
    "customer": customer?.toJson(),
  };
}

class Customer {
  String? id;
  String? phoneNumber;
  String? customerName;
  String? email;
  String? contactPerson;
  String? designation;
  String? countryOrigin;
  Organization? organization;
  List<MachineElement>? machines;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? users;
  String? flag;

  Customer({
    this.id,
    this.phoneNumber,
    this.customerName,
    this.email,
    this.contactPerson,
    this.designation,
    this.countryOrigin,
    this.organization,
    this.machines,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.users,
    this.flag,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["_id"],
    phoneNumber: json["phoneNumber"],
    customerName: json["customerName"],
    email: json["email"],
    contactPerson: json["contactPerson"],
    designation: json["designation"],
    countryOrigin: json["countryOrigin"],
    organization: json["organization"] == null ? null : Organization.fromJson(json["organization"]),
    machines: json["machines"] == null ? [] : List<MachineElement>.from(json["machines"]!.map((x) => MachineElement.fromJson(x))),
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    users: json["users"],
    flag: json["flag"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phoneNumber": phoneNumber,
    "customerName": customerName,
    "email": email,
    "contactPerson": contactPerson,
    "designation": designation,
    "countryOrigin": countryOrigin,
    "organization": organization?.toJson(),
    "machines": machines == null ? [] : List<dynamic>.from(machines!.map((x) => x.toJson())),
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "users": users,
    "flag": flag,
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
    machine: json["machine"] == null ? null : MachineMachine.fromJson(json["machine"]),
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

  MachineMachine({
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

  factory MachineMachine.fromJson(Map<String, dynamic> json) => MachineMachine(
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

class Organization {
  String? id;
  String? fullName;
  String? email;
  String? phone;
  String? remark;

  Organization({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.remark,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
    phone: json["phone"],
    remark: json["remark"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "remark": remark,
  };
}
