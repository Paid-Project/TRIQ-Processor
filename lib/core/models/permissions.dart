class Permissions {
  TicketManagement? ticketManagement;
  MachineManagement? machineManagement;
  CustomerInteraction? customerInteraction;
  FinancialAccess? financialAccess;
  UserManagement? userManagement;
  ReportAccess? reportAccess;
  CommunicationTools? communicationTools;
  String? accountAccess;

  Permissions({
    this.ticketManagement,
    this.machineManagement,
    this.customerInteraction,
    this.financialAccess,
    this.userManagement,
    this.reportAccess,
    this.communicationTools,
    this.accountAccess,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      ticketManagement:
      json['ticketManagement'] != null
          ? TicketManagement.fromJson(json['ticketManagement'])
          : null,
      machineManagement:
      json['machineManagement'] != null
          ? MachineManagement.fromJson(json['machineManagement'])
          : null,
      customerInteraction:
      json['customerInteraction'] != null
          ? CustomerInteraction.fromJson(json['customerInteraction'])
          : null,
      financialAccess:
      json['financialAccess'] != null
          ? FinancialAccess.fromJson(json['financialAccess'])
          : null,
      userManagement:
      json['userManagement'] != null
          ? UserManagement.fromJson(json['userManagement'])
          : null,
      reportAccess:
      json['reportAccess'] != null
          ? ReportAccess.fromJson(json['reportAccess'])
          : null,
      communicationTools:
      json['communicationTools'] != null
          ? CommunicationTools.fromJson(json['communicationTools'])
          : null,
      accountAccess: json['accountAccess'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketManagement': ticketManagement?.toJson(),
      'machineManagement': machineManagement?.toJson(),
      'customerInteraction': customerInteraction?.toJson(),
      'financialAccess': financialAccess?.toJson(),
      'userManagement': userManagement?.toJson(),
      'reportAccess': reportAccess?.toJson(),
      'communicationTools': communicationTools?.toJson(),
      'accountAccess': accountAccess,
    };
  }
}


class TicketManagement {
  bool? createTicket;
  String? viewTickets;
  bool? assignTickets;
  bool? changeTicketPriority;
  bool? changeTicketStatus;
  bool? closeTicket;
  bool? deleteTicket;

  TicketManagement({
    this.createTicket,
    this.viewTickets,
    this.assignTickets,
    this.changeTicketPriority,
    this.changeTicketStatus,
    this.closeTicket,
    this.deleteTicket,
  });

  factory TicketManagement.fromJson(Map<String, dynamic> json) {
    return TicketManagement(
      createTicket: json['createTicket'],
      viewTickets: json['viewTickets'],
      assignTickets: json['assignTickets'],
      changeTicketPriority: json['changeTicketPriority'],
      changeTicketStatus: json['changeTicketStatus'],
      closeTicket: json['closeTicket'],
      deleteTicket: json['deleteTicket'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createTicket': createTicket,
      'viewTickets': viewTickets,
      'assignTickets': assignTickets,
      'changeTicketPriority': changeTicketPriority,
      'changeTicketStatus': changeTicketStatus,
      'closeTicket': closeTicket,
      'deleteTicket': deleteTicket,
    };
  }
}

class MachineManagement {
  bool? addMachine;
  bool? editMachine;
  bool? scheduleMaintenance;

  MachineManagement({
    this.addMachine,
    this.editMachine,
    this.scheduleMaintenance,
  });

  factory MachineManagement.fromJson(Map<String, dynamic> json) {
    return MachineManagement(
      addMachine: json['addMachine'],
      editMachine: json['editMachine'],
      scheduleMaintenance: json['scheduleMaintenance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addMachine': addMachine,
      'editMachine': editMachine,
      'scheduleMaintenance': scheduleMaintenance,
    };
  }
}

class CustomerInteraction {
  bool? viewCustomer;
  bool? editCustomer;
  bool? contactCustomer;

  CustomerInteraction({
    this.viewCustomer,
    this.editCustomer,
    this.contactCustomer,
  });

  factory CustomerInteraction.fromJson(Map<String, dynamic> json) {
    return CustomerInteraction(
      viewCustomer: json['viewCustomer'],
      editCustomer: json['editCustomer'],
      contactCustomer: json['contactCustomer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewCustomer': viewCustomer,
      'editCustomer': editCustomer,
      'contactCustomer': contactCustomer,
    };
  }
}

class FinancialAccess {
  bool? viewCosts;
  bool? createInvoice;

  FinancialAccess({this.viewCosts, this.createInvoice});

  factory FinancialAccess.fromJson(Map<String, dynamic> json) {
    return FinancialAccess(
      viewCosts: json['viewCosts'],
      createInvoice: json['createInvoice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'viewCosts': viewCosts, 'createInvoice': createInvoice};
  }
}

class UserManagement {
  bool? createUser;
  bool? editPermissions;

  UserManagement({this.createUser, this.editPermissions});

  factory UserManagement.fromJson(Map<String, dynamic> json) {
    return UserManagement(
      createUser: json['createUser'],
      editPermissions: json['editPermissions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'createUser': createUser, 'editPermissions': editPermissions};
  }
}

class ReportAccess {
  bool? basicReports;
  bool? advancedAnalytics;

  ReportAccess({this.basicReports, this.advancedAnalytics});

  factory ReportAccess.fromJson(Map<String, dynamic> json) {
    return ReportAccess(
      basicReports: json['basicReports'],
      advancedAnalytics: json['advancedAnalytics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basicReports': basicReports,
      'advancedAnalytics': advancedAnalytics,
    };
  }
}

class CommunicationTools {
  bool? internalMessaging;
  bool? externalCommunication;

  CommunicationTools({this.internalMessaging, this.externalCommunication});

  factory CommunicationTools.fromJson(Map<String, dynamic> json) {
    return CommunicationTools(
      internalMessaging: json['internalMessaging'],
      externalCommunication: json['externalCommunication'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'internalMessaging': internalMessaging,
      'externalCommunication': externalCommunication,
    };
  }
}

class MachineQualifications {
  List<dynamic>? authorized;
  List<dynamic>? serviceAuthorized;
  List<dynamic>? certificationExpirations;

  MachineQualifications({
    this.authorized,
    this.serviceAuthorized,
    this.certificationExpirations,
  });

  factory MachineQualifications.fromJson(Map<String, dynamic> json) {
    return MachineQualifications(
      authorized: json['authorized'] ?? [],
      serviceAuthorized: json['serviceAuthorized'] ?? [],
      certificationExpirations: json['certificationExpirations'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorized': authorized,
      'serviceAuthorized': serviceAuthorized,
      'certificationExpirations': certificationExpirations,
    };
  }
}
