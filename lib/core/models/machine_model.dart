// To parse this JSON data, do
//
//     final machineModel = machineModelFromJson(jsonString);

import 'dart:convert';

MachineModel machineModelFromJson(String str) => MachineModel.fromJson(json.decode(str));

String machineModelToJson(MachineModel data) => json.encode(data.toJson());

class MachineModel {
  int? count;
  List<Datum>? data;

  MachineModel({
    this.count,
    this.data,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
    count: json["count"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
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

  Datum({
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
