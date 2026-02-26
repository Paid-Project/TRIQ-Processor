import 'dart:convert';
/// status : 1
/// data : {"_id":"699ed4bac3aa43adc6921ad5","manufacturerUrl":"https://drive.google.com/file/d/1lGS34oegrlQaQQQ_a3EIlds5KGy9sjsr/view?usp=drive_link","processorUrl":"https://drive.google.com/file/d/1UpSC2Hem6pSyy8qzu90xQOYgpAHmvRdS/view?usp=drive_link","createdAt":"2026-02-25T10:53:47.004Z","updatedAt":"2026-02-25T10:53:47.004Z","__v":0}

InviteModel inviteModelFromJson(String str) => InviteModel.fromJson(json.decode(str));
String inviteModelToJson(InviteModel data) => json.encode(data.toJson());
class InviteModel {
  InviteModel({
      this.status, 
      this.data,});

  InviteModel.fromJson(dynamic json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  int? status;
  Data? data;
InviteModel copyWith({  int? status,
  Data? data,
}) => InviteModel(  status: status ?? this.status,
  data: data ?? this.data,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }

}

/// _id : "699ed4bac3aa43adc6921ad5"
/// manufacturerUrl : "https://drive.google.com/file/d/1lGS34oegrlQaQQQ_a3EIlds5KGy9sjsr/view?usp=drive_link"
/// processorUrl : "https://drive.google.com/file/d/1UpSC2Hem6pSyy8qzu90xQOYgpAHmvRdS/view?usp=drive_link"
/// createdAt : "2026-02-25T10:53:47.004Z"
/// updatedAt : "2026-02-25T10:53:47.004Z"
/// __v : 0

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      this.id, 
      this.manufacturerUrl, 
      this.processorUrl, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  Data.fromJson(dynamic json) {
    id = json['_id'];
    manufacturerUrl = json['manufacturerUrl'];
    processorUrl = json['processorUrl'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? manufacturerUrl;
  String? processorUrl;
  String? createdAt;
  String? updatedAt;
  int? v;
Data copyWith({  String? id,
  String? manufacturerUrl,
  String? processorUrl,
  String? createdAt,
  String? updatedAt,
  int? v,
}) => Data(  id: id ?? this.id,
  manufacturerUrl: manufacturerUrl ?? this.manufacturerUrl,
  processorUrl: processorUrl ?? this.processorUrl,
  createdAt: createdAt ?? this.createdAt,
  updatedAt: updatedAt ?? this.updatedAt,
  v: v ?? this.v,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['manufacturerUrl'] = manufacturerUrl;
    map['processorUrl'] = processorUrl;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}