// To parse this JSON data, do
//
//     final machineOverviewModel = machineOverviewModelFromJson(jsonString);

import 'dart:convert';

MachineOverviewModel machineOverviewModelFromJson(String str) => MachineOverviewModel.fromJson(json.decode(str));

String machineOverviewModelToJson(MachineOverviewModel data) => json.encode(data.toJson());

class MachineOverviewModel {
  List<MachineOverviewList>? data;

  MachineOverviewModel({
    this.data,
  });

  factory MachineOverviewModel.fromJson(Map<String, dynamic> json) => MachineOverviewModel(
    data: json["data"] == null ? [] : List<MachineOverviewList>.from(json["data"]!.map((x) => MachineOverviewList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class MachineOverviewList {
  String? machineId;
  String? machineName;
  String? modelNumber;
  String? serialNumber;
  String? machineType;
  String? status;
  bool? isActive;
  DateTime? purchaseDate;
  DateTime? installationDate;
  DateTime? warrantyStart;
  DateTime? warrantyEnd;
  String? warrantyStatus;
  String? invoiceContractNo;
  String? organization;
  String? remark;

  MachineOverviewList({
    this.machineId,
    this.machineName,
    this.modelNumber,
    this.serialNumber,
    this.machineType,
    this.status,
    this.isActive,
    this.purchaseDate,
    this.installationDate,
    this.warrantyStart,
    this.warrantyEnd,
    this.warrantyStatus,
    this.invoiceContractNo,
    this.organization,
    this.remark,
  });

  factory MachineOverviewList.fromJson(Map<String, dynamic> json) => MachineOverviewList(
    machineId: json["machineId"],
    machineName: json["machineName"],
    modelNumber: json["modelNumber"],
    serialNumber: json["serialNumber"],
    machineType: json["machineType"],
    status: json["status"],
    isActive: json["isActive"],
    purchaseDate: json["purchaseDate"] == null ? null : DateTime.parse(json["purchaseDate"]),
    installationDate: json["installationDate"] == null ? null : DateTime.parse(json["installationDate"]),
    warrantyStart: json["warrantyStart"] == null ? null : DateTime.parse(json["warrantyStart"]),
    warrantyEnd: json["warrantyEnd"] == null ? null : DateTime.parse(json["warrantyEnd"]),
    warrantyStatus: json["warrantyStatus"],
    invoiceContractNo: json["invoiceContractNo"],
    organization: json["organization"],
    remark: json["remark"],
  );

  Map<String, dynamic> toJson() => {
    "machineId": machineId,
    "machineName": machineName,
    "modelNumber": modelNumber,
    "serialNumber": serialNumber,
    "machineType": machineType,
    "status": status,
    "isActive": isActive,
    "purchaseDate": purchaseDate?.toIso8601String(),
    "installationDate": installationDate?.toIso8601String(),
    "warrantyStart": warrantyStart?.toIso8601String(),
    "warrantyEnd": warrantyEnd?.toIso8601String(),
    "warrantyStatus": warrantyStatus,
    "invoiceContractNo": invoiceContractNo,
    "organization": organization,
    "remark": remark,
  };
}
