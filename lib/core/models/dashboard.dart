  class DashboardModel {
    Customer ticket;
    Customer task;
    Customer customer;

    DashboardModel({
      required this.ticket,
      required this.task,
      required this.customer,
    });

    factory DashboardModel.fromJson(Map<String, dynamic> json) {
      return DashboardModel(
        ticket: Customer.fromJson(_asMap(json['ticket'])),
        task: Customer.fromJson(_asMap(json['task'])),
        customer: Customer.fromJson(_asMap(json['customer'])),
      );
    }

    static Map<String, dynamic> _asMap(dynamic value) {
      return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    }
  }
  class Customer {
    bool hasNew;

    Customer({
      required this.hasNew,
    });

    factory Customer.fromJson(Map<String, dynamic> json) {
      return Customer(
        hasNew: json['hasNew'] ?? false, // 🔥 FIX
      );
    }
  }


  // class Dashboard {
  //   final List<DashboardCard> cards;
  //   final DashboardStats stats;
  //
  //   Dashboard({
  //     required this.cards,
  //     required this.stats,
  //   });
  //
  //   factory Dashboard.fromJson(Map<String, dynamic> json) {
  //     return Dashboard(
  //       cards: (json['cards'] as List)
  //           .map((cardJson) => DashboardCard.fromJson(cardJson))
  //           .toList(),
  //       stats: DashboardStats.fromJson(json['stats']),
  //     );
  //   }
  // }
  //
  // class DashboardCard {
  //   final String id;
  //   final String title;
  //   final String description;
  //   final String route;
  //   final dynamic colorCode; // Changed to dynamic to handle both int and String
  //   final String iconUrl;
  //   final String imageUrl;
  //
  //   DashboardCard({
  //     required this.id,
  //     required this.title,
  //     required this.description,
  //     required this.route,
  //     required this.colorCode,
  //     required this.iconUrl,
  //     required this.imageUrl,
  //   });
  //
  //   factory DashboardCard.fromJson(Map<String, dynamic> json) {
  //     return DashboardCard(
  //       id: json['id'] ?? '',
  //       title: json['title'] ?? '',
  //       description: json['description'] ?? '',
  //       route: json['route'] ?? '',
  //       colorCode: json['colorCode'] ?? 0xFF72B6B6, // Can be int or String
  //       iconUrl: json['iconUrl'] ?? '',
  //       imageUrl: json['imageUrl'] ?? '',
  //     );
  //   }
  // }
  //
  // class DashboardStats {
  //   final TicketStats tickets;
  //   final MachineStats machines;
  //
  //   DashboardStats({
  //     required this.tickets,
  //     required this.machines,
  //   });
  //
  //   factory DashboardStats.fromJson(Map<String, dynamic> json) {
  //     return DashboardStats(
  //       tickets: TicketStats.fromJson(json['tickets']),
  //       machines: MachineStats.fromJson(json['machines']),
  //     );
  //   }
  // }
  //
  // class TicketStats {
  //   final int total;
  //   final int open;
  //   final int inProgress;
  //   final int resolved;
  //   final int closed;
  //
  //   TicketStats({
  //     required this.total,
  //     required this.open,
  //     required this.inProgress,
  //     required this.resolved,
  //     required this.closed,
  //   });
  //
  //   factory TicketStats.fromJson(Map<String, dynamic> json) {
  //     return TicketStats(
  //       total: json['total'] ?? 0,
  //       open: json['open'] ?? 0,
  //       inProgress: json['inProgress'] ?? 0,
  //       resolved: json['resolved'] ?? 0,
  //       closed: json['closed'] ?? 0,
  //     );
  //   }
  // }
  //
  // class MachineStats {
  //   final int total;
  //   final int operational;
  //   final int underMaintenance;
  //   final int outOfService;
  //   final int decommissioned;
  //
  //   MachineStats({
  //     required this.total,
  //     required this.operational,
  //     required this.underMaintenance,
  //     required this.outOfService,
  //     required this.decommissioned,
  //   });
  //
  //   factory MachineStats.fromJson(Map<String, dynamic> json) {
  //     return MachineStats(
  //       total: json['total'] ?? 0,
  //       operational: json['operational'] ?? 0,
  //       underMaintenance: json['underMaintenance'] ?? 0,
  //       outOfService: json['outOfService'] ?? 0,
  //       decommissioned: json['decommissioned'] ?? 0,
  //     );
  //   }
  // }