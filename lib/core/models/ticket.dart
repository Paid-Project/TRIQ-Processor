import 'package:equatable/equatable.dart';
import 'machine.dart';

class Ticket extends Equatable {
  final String id;
  final String? ticketId;
  final Machine? machine;
  final Resolution? resolution;
  final ResponseTime? responseTime;
  final String? processorId;
  final ProcessorInfo? processorInfo;
  final String? manufacturerId;
  final ManufacturerInfo? manufacturerInfo;
  final String? raisedBy;
  final String? title;
  final String? description;
  final String? ticketType;
  final String? priority;
  final String? status;
  final List<String>? attachments;
  final List<Comment>? comments;
  final String? createdAt;
  final String? updatedAt;
  final String? lastPingTime;
  final List<AdditionalInfo>? additionalInfo;
  final DateTime? completedDate;
  final int? resolveRequest;
  final String? closingRemark;

  final DateTime? rescheduleTime;

  const Ticket({
    required this.id,
    this.ticketId,
    this.machine,
    this.resolution,
    this.responseTime,
    this.processorId,
    this.processorInfo,
    this.manufacturerId,
    this.manufacturerInfo,
    this.raisedBy,
    this.title,
    this.description,
    this.ticketType,
    this.priority,
    this.status,
    this.attachments,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.lastPingTime,
    this.additionalInfo,
    this.completedDate,
    this.resolveRequest,
    this.closingRemark,
    this.rescheduleTime,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'],
      ticketId: json['ticketId'] ?? json['_id'],
      machine: json['machine']?['machineId'] != null
          ? Machine.fromJson(json['machine']['machineId'])
          : null,
      resolution: json['resolution'] != null ? Resolution.fromJson(json['resolution']) : null,
      responseTime: json['responseTime'] != null ? ResponseTime.fromJson(json['responseTime']) : null,
      processorId: json['processorId'] is String ? json['processorId'] : json['processorId']?['_id'],
      processorInfo: json['processorId'] is Map ? ProcessorInfo.fromJson(json['processorId']) : null,
      manufacturerId: json['manufacturerId'] is String ? json['manufacturerId'] : json['manufacturerId']?['_id'],
      manufacturerInfo: json['manufacturerId'] is Map ? ManufacturerInfo.fromJson(json['manufacturerId']) : null,
      raisedBy: json['raisedBy'],
      title: json['title'],
      description: json['description'],
      ticketType: json['ticketType'],
      priority: json['priority'],
      status: json['status'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((comment) => Comment.fromJson(comment)).toList()
          : [],
      additionalInfo: json['additionalInfo'] != null
          ? (json['additionalInfo'] as List).map((item) => AdditionalInfo.fromJson(item)).toList()
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      lastPingTime: json['lastPingTime'],
      completedDate: json['completedDate'] != null ? DateTime.tryParse(json['completedDate']) : null,
      resolveRequest: json['resolveRequest'],
      closingRemark: json['closingRemark'],
      rescheduleTime: json['rescheduleTime'] != null ? DateTime.tryParse(json['rescheduleTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'machine': machine?.toJson(),
      'resolution': resolution?.toJson(),
      'responseTime': responseTime?.toJson(),
      'processorId': processorId,
      'manufacturerId': manufacturerId,
      'raisedBy': raisedBy,
      'title': title,
      'description': description,
      'ticketType': ticketType,
      'priority': priority,
      'status': status,
      'attachments': attachments,
      'additionalInfo': additionalInfo?.map((info) => info.toJson()).toList(),
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastPingTime': lastPingTime,
      'completedDate': completedDate?.toIso8601String(),
      'resolveRequest': resolveRequest,
      'closingRemark': closingRemark,
      'rescheduleTime': rescheduleTime?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    ticketId,
    machine,
    resolution,
    responseTime,
    processorId,
    processorInfo,
    manufacturerId,
    manufacturerInfo,
    raisedBy,
    title,
    description,
    ticketType,
    priority,
    status,
    attachments,
    comments,
    createdAt,
    updatedAt,
    lastPingTime,
    additionalInfo,
    completedDate,
    resolveRequest,
    closingRemark,
    rescheduleTime,
  ];
}

class Resolution extends Equatable {
  final List<String>? replacementParts;

  const Resolution({this.replacementParts});

  factory Resolution.fromJson(Map<String, dynamic> json) {
    return Resolution(
      replacementParts: json['replacementParts'] != null
          ? List<String>.from(json['replacementParts'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'replacementParts': replacementParts};
  }

  @override
  List<Object?> get props => [replacementParts];
}

class ResponseTime extends Equatable {
  final bool? slaBreached;

  const ResponseTime({this.slaBreached});

  factory ResponseTime.fromJson(Map<String, dynamic> json) {
    return ResponseTime(slaBreached: json['slaBreached']);
  }

  Map<String, dynamic> toJson() {
    return {'slaBreached': slaBreached};
  }

  @override
  List<Object?> get props => [slaBreached];
}

class ProcessorInfo extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? countryCode;

  const ProcessorInfo({this.id, this.name, this.email, this.countryCode});

  factory ProcessorInfo.fromJson(Map<String, dynamic> json) {
    return ProcessorInfo(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      countryCode: json['countryCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'countryCode': countryCode};
  }

  @override
  List<Object?> get props => [id, name, email, countryCode];
}

class ManufacturerInfo extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? countryCode;

  const ManufacturerInfo({this.id, this.name, this.email, this.countryCode});

  factory ManufacturerInfo.fromJson(Map<String, dynamic> json) {
    return ManufacturerInfo(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      countryCode: json['countryCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'countryCode': countryCode};
  }

  @override
  List<Object?> get props => [id, name, email, countryCode];
}

class Comment extends Equatable {
  final String? id;
  final String? userId;
  final String? userName;
  final String? text;
  final String? createdAt;

  const Comment({this.id, this.userId, this.userName, this.text, this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      userId: json['userId'],
      userName: json['userName'],
      text: json['text'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, userId, userName, text, createdAt];
}

class AdditionalInfo extends Equatable {
  final String? title;
  final String? description;

  const AdditionalInfo({this.title, this.description});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    return data;
  }

  @override
  List<Object?> get props => [title, description];
}
