import 'dart:convert';
/// message : "Ticket created successfully"
/// ticket : {"ticketNumber":"804367680757","problem":"Machine overheating frequently","errorCode":"E-101","notes":"Check cooling system and fan","media":[],"ticketType":"General Check Up","type":"Online","status":"Waiting for Accept","isActive":true,"machine":"6979d3a1333dbfbeb2d379ce","processor":"6979fd3730aadcdfe3c1a357","organisation":"6927d747e7fa3560059f1f99","pricing":"6981f772cdac0eef2240e6f6","paymentStatus":"paid","IsShowChatOption":true,"isFirstTimeServiceDone":false,"resolvedAt":null,"resolutionDurationMinutes":null,"_id":"6981f772cdac0eef2240e6f7","createdAt":"2026-02-03T13:26:10.862Z","updatedAt":"2026-02-03T13:26:10.862Z","__v":0}
/// pricing : {"supportMode":"Online","warrantyStatus":"In warranty","ticketType":"General Check Up","cost":0,"currency":"USD","_id":"6981f772cdac0eef2240e6f6"}
/// chatRoom : {"ticket":"6981f772cdac0eef2240e6f7","organisation":"6927d747e7fa3560059f1f99","processor":"6979fd3730aadcdfe3c1a357","_id":"6981f773cdac0eef2240e6fa","createdAt":"2026-02-03T13:26:11.163Z","updatedAt":"2026-02-03T13:26:11.163Z","__v":0}

CreateTicketModel createTicketModelFromJson(String str) => CreateTicketModel.fromJson(json.decode(str));
String createTicketModelToJson(CreateTicketModel data) => json.encode(data.toJson());
class CreateTicketModel {
  CreateTicketModel({
      this.message, 
      this.ticket, 
      this.pricing, 
      this.chatRoom,});

  CreateTicketModel.fromJson(dynamic json) {
    message = json['message'];
    ticket = json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null;
    pricing = json['pricing'] != null ? Pricing.fromJson(json['pricing']) : null;
    chatRoom = json['chatRoom'] != null ? ChatRoom.fromJson(json['chatRoom']) : null;
  }
  String? message;
  Ticket? ticket;
  Pricing? pricing;
  ChatRoom? chatRoom;
CreateTicketModel copyWith({  String? message,
  Ticket? ticket,
  Pricing? pricing,
  ChatRoom? chatRoom,
}) => CreateTicketModel(  message: message ?? this.message,
  ticket: ticket ?? this.ticket,
  pricing: pricing ?? this.pricing,
  chatRoom: chatRoom ?? this.chatRoom,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (ticket != null) {
      map['ticket'] = ticket?.toJson();
    }
    if (pricing != null) {
      map['pricing'] = pricing?.toJson();
    }
    if (chatRoom != null) {
      map['chatRoom'] = chatRoom?.toJson();
    }
    return map;
  }

}

/// ticket : "6981f772cdac0eef2240e6f7"
/// organisation : "6927d747e7fa3560059f1f99"
/// processor : "6979fd3730aadcdfe3c1a357"
/// _id : "6981f773cdac0eef2240e6fa"
/// createdAt : "2026-02-03T13:26:11.163Z"
/// updatedAt : "2026-02-03T13:26:11.163Z"
/// __v : 0

ChatRoom chatRoomFromJson(String str) => ChatRoom.fromJson(json.decode(str));
String chatRoomToJson(ChatRoom data) => json.encode(data.toJson());
class ChatRoom {
  ChatRoom({
      this.ticket, 
      this.organisation, 
      this.processor, 
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  ChatRoom.fromJson(dynamic json) {
    ticket = json['ticket'];
    organisation = json['organisation'];
    processor = json['processor'];
    id = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? ticket;
  String? organisation;
  String? processor;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;
ChatRoom copyWith({  String? ticket,
  String? organisation,
  String? processor,
  String? id,
  String? createdAt,
  String? updatedAt,
  int? v,
}) => ChatRoom(  ticket: ticket ?? this.ticket,
  organisation: organisation ?? this.organisation,
  processor: processor ?? this.processor,
  id: id ?? this.id,
  createdAt: createdAt ?? this.createdAt,
  updatedAt: updatedAt ?? this.updatedAt,
  v: v ?? this.v,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ticket'] = ticket;
    map['organisation'] = organisation;
    map['processor'] = processor;
    map['_id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}

/// supportMode : "Online"
/// warrantyStatus : "In warranty"
/// ticketType : "General Check Up"
/// cost : 0
/// currency : "USD"
/// _id : "6981f772cdac0eef2240e6f6"

Pricing pricingFromJson(String str) => Pricing.fromJson(json.decode(str));
String pricingToJson(Pricing data) => json.encode(data.toJson());
class Pricing {
  Pricing({
      this.supportMode, 
      this.warrantyStatus, 
      this.ticketType, 
      this.cost, 
      this.currency, 
      this.id,});

  Pricing.fromJson(dynamic json) {
    supportMode = json['supportMode'];
    warrantyStatus = json['warrantyStatus'];
    ticketType = json['ticketType'];
    cost = json['cost'];
    currency = json['currency'];
    id = json['_id'];
  }
  String? supportMode;
  String? warrantyStatus;
  String? ticketType;
  int? cost;
  String? currency;
  String? id;
Pricing copyWith({  String? supportMode,
  String? warrantyStatus,
  String? ticketType,
  int? cost,
  String? currency,
  String? id,
}) => Pricing(  supportMode: supportMode ?? this.supportMode,
  warrantyStatus: warrantyStatus ?? this.warrantyStatus,
  ticketType: ticketType ?? this.ticketType,
  cost: cost ?? this.cost,
  currency: currency ?? this.currency,
  id: id ?? this.id,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['supportMode'] = supportMode;
    map['warrantyStatus'] = warrantyStatus;
    map['ticketType'] = ticketType;
    map['cost'] = cost;
    map['currency'] = currency;
    map['_id'] = id;
    return map;
  }

}

/// ticketNumber : "804367680757"
/// problem : "Machine overheating frequently"
/// errorCode : "E-101"
/// notes : "Check cooling system and fan"
/// media : []
/// ticketType : "General Check Up"
/// type : "Online"
/// status : "Waiting for Accept"
/// isActive : true
/// machine : "6979d3a1333dbfbeb2d379ce"
/// processor : "6979fd3730aadcdfe3c1a357"
/// organisation : "6927d747e7fa3560059f1f99"
/// pricing : "6981f772cdac0eef2240e6f6"
/// paymentStatus : "paid"
/// IsShowChatOption : true
/// isFirstTimeServiceDone : false
/// resolvedAt : null
/// resolutionDurationMinutes : null
/// _id : "6981f772cdac0eef2240e6f7"
/// createdAt : "2026-02-03T13:26:10.862Z"
/// updatedAt : "2026-02-03T13:26:10.862Z"
/// __v : 0

Ticket ticketFromJson(String str) => Ticket.fromJson(json.decode(str));
String ticketToJson(Ticket data) => json.encode(data.toJson());
class Ticket {
  Ticket({
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
      this.pricing, 
      this.paymentStatus, 
      this.isShowChatOption, 
      this.isFirstTimeServiceDone, 
      this.resolvedAt, 
      this.resolutionDurationMinutes, 
      this.id, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  Ticket.fromJson(dynamic json) {
    ticketNumber = json['ticketNumber'];
    problem = json['problem'];
    errorCode = json['errorCode'];
    notes = json['notes'];
    if (json['media'] != null) {
      media = [];
      json['media'].forEach((v) {
        media?.add(v);
      });
    }
    ticketType = json['ticketType'];
    type = json['type'];
    status = json['status'];
    isActive = json['isActive'];
    machine = json['machine'];
    processor = json['processor'];
    organisation = json['organisation'];
    pricing = json['pricing'];
    paymentStatus = json['paymentStatus'];
    isShowChatOption = json['IsShowChatOption'];
    isFirstTimeServiceDone = json['isFirstTimeServiceDone'];
    resolvedAt = json['resolvedAt'];
    resolutionDurationMinutes = json['resolutionDurationMinutes'];
    id = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? ticketNumber;
  String? problem;
  String? errorCode;
  String? notes;
  List<String>? media;
  String? ticketType;
  String? type;
  String? status;
  bool? isActive;
  String? machine;
  String? processor;
  String? organisation;
  String? pricing;
  String? paymentStatus;
  bool? isShowChatOption;
  bool? isFirstTimeServiceDone;
  dynamic resolvedAt;
  dynamic resolutionDurationMinutes;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;
Ticket copyWith({  String? ticketNumber,
  String? problem,
  String? errorCode,
  String? notes,
  List<String>? media,
  String? ticketType,
  String? type,
  String? status,
  bool? isActive,
  String? machine,
  String? processor,
  String? organisation,
  String? pricing,
  String? paymentStatus,
  bool? isShowChatOption,
  bool? isFirstTimeServiceDone,
  dynamic resolvedAt,
  dynamic resolutionDurationMinutes,
  String? id,
  String? createdAt,
  String? updatedAt,
  int? v,
}) => Ticket(  ticketNumber: ticketNumber ?? this.ticketNumber,
  problem: problem ?? this.problem,
  errorCode: errorCode ?? this.errorCode,
  notes: notes ?? this.notes,
  media: media ?? this.media,
  ticketType: ticketType ?? this.ticketType,
  type: type ?? this.type,
  status: status ?? this.status,
  isActive: isActive ?? this.isActive,
  machine: machine ?? this.machine,
  processor: processor ?? this.processor,
  organisation: organisation ?? this.organisation,
  pricing: pricing ?? this.pricing,
  paymentStatus: paymentStatus ?? this.paymentStatus,
  isShowChatOption: isShowChatOption ?? this.isShowChatOption,
  isFirstTimeServiceDone: isFirstTimeServiceDone ?? this.isFirstTimeServiceDone,
  resolvedAt: resolvedAt ?? this.resolvedAt,
  resolutionDurationMinutes: resolutionDurationMinutes ?? this.resolutionDurationMinutes,
  id: id ?? this.id,
  createdAt: createdAt ?? this.createdAt,
  updatedAt: updatedAt ?? this.updatedAt,
  v: v ?? this.v,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ticketNumber'] = ticketNumber;
    map['problem'] = problem;
    map['errorCode'] = errorCode;
    map['notes'] = notes;
    if (media != null) {
      map['media'] = media?.map((v) => v).toList();
    }
    map['ticketType'] = ticketType;
    map['type'] = type;
    map['status'] = status;
    map['isActive'] = isActive;
    map['machine'] = machine;
    map['processor'] = processor;
    map['organisation'] = organisation;
    map['pricing'] = pricing;
    map['paymentStatus'] = paymentStatus;
    map['IsShowChatOption'] = isShowChatOption;
    map['isFirstTimeServiceDone'] = isFirstTimeServiceDone;
    map['resolvedAt'] = resolvedAt;
    map['resolutionDurationMinutes'] = resolutionDurationMinutes;
    map['_id'] = id;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}