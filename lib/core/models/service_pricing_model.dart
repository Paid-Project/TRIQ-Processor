// To parse this JSON data, do
//
//     final servicePricingModel = servicePricingModelFromJson(jsonString);

import 'dart:convert';

ServicePricingModel servicePricingModelFromJson(String str) => ServicePricingModel.fromJson(json.decode(str));

String servicePricingModelToJson(ServicePricingModel data) => json.encode(data.toJson());

class ServicePricingModel {
  bool? msg;
  List<Datum>? data;

  ServicePricingModel({
    this.msg,
    this.data,
  });

  factory ServicePricingModel.fromJson(Map<String, dynamic> json) => ServicePricingModel(
    msg: json["msg"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "msg": msg,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? supportMode;
  String? warrantyStatus;
  String? ticketType;
  int? cost;
  String? currency;
  String? id;

  Datum({
    this.supportMode,
    this.warrantyStatus,
    this.ticketType,
    this.cost,
    this.currency,
    this.id,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
