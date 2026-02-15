class Relationship {
  final String? relationshipId;
  final RelationshipStatus? status;
  final bool? isInitiator;
  final String? partnerId;
  final String? partnerName;
  final String? partnerType;
  final String? industry;
  final DateTime? requestedAt;
  final Permissions? permissions;
  final String? requesterId;
  final String? requesterName;
  final String? requesterType;
  final String? partnerLogo;
  final DateTime? confirmedAt;
  final String? partnerEmail;
  final String? partnerCountryCode;
  final List? machineModels;

  Relationship({
    this.relationshipId,
    this.status,
    this.isInitiator,
    this.partnerId,
    this.partnerName,
    this.partnerType,
    this.industry,
    this.requestedAt,
    this.permissions,
    this.requesterId,
    this.requesterName,
    this.requesterType,
    this.partnerLogo,
    this.machineModels,
    this.partnerEmail,
    this.partnerCountryCode,
    this.confirmedAt,
  });

  factory Relationship.fromJson(Map<String, dynamic> json) {
    return Relationship(
      relationshipId: json['relationshipId'] as String?,
      status: RelationshipStatus.values.firstWhere((element) => element.name == json['status']),
      isInitiator: json['isInitiator'] as bool?,
      partnerId: json['processorId'] as String?,
      partnerName: json['partnerName'] as String?,
      partnerType: json['partnerType'] as String?,
      partnerLogo: json['partnerLogo'] as String?,
      partnerCountryCode: json['partnerCountryCode'] as String?,
      partnerEmail: json['partnerEmail'] as String?,
      industry: json['industry'] as String?,
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'])
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'])
          : null,
      permissions: json['permissions'] != null
          ? Permissions.fromJson(json['permissions'])
          : null,
      requesterId: json['requesterId'] as String?,
      requesterName: json['requesterName'] as String?,
      requesterType: json['requesterType'] as String?,
      machineModels: (json['machineModels']??<String>[]),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (relationshipId != null) 'relationshipId': relationshipId,
      if (status != null) 'status': status,
      if (isInitiator != null) 'isInitiator': isInitiator,
      if (partnerId != null) 'processorId': partnerId,
      if (partnerName != null) 'partnerName': partnerName,
      if (partnerType != null) 'partnerType': partnerType,
      if (industry != null) 'industry': industry,
      if (requestedAt != null) 'requestedAt': requestedAt!.toIso8601String(),
      if (permissions != null) 'permissions': permissions!.toJson(),
      if (requesterId != null) 'requesterId': requesterId,
      if (requesterName != null) 'requesterName': requesterName,
      if (requesterType != null) 'requesterType': requesterType,
      if (partnerLogo != null) 'logo': partnerLogo,
      if (machineModels != null) 'machineModels': machineModels,
    };
  }
}

class Permissions {
  final bool? shareEmployeeData;
  final bool? viewInventory;
  final bool? submitOrders;
  final bool? accessDocuments;

  Permissions({
    this.shareEmployeeData,
    this.viewInventory,
    this.submitOrders,
    this.accessDocuments,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      shareEmployeeData: json['shareEmployeeData'] as bool?,
      viewInventory: json['viewInventory'] as bool?,
      submitOrders: json['submitOrders'] as bool?,
      accessDocuments: json['accessDocuments'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (shareEmployeeData != null) 'shareEmployeeData': shareEmployeeData,
      if (viewInventory != null) 'viewInventory': viewInventory,
      if (submitOrders != null) 'submitOrders': submitOrders,
      if (accessDocuments != null) 'accessDocuments': accessDocuments,
    };
  }
}

enum RelationshipStatus {
  all,
  pending,
  active,
  terminated,
  paused,
}