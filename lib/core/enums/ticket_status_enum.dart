enum TicketStatus {
  pending('Pending'),
  inProgress('In Progress'),
  resolved('Resolved'),
  rejected('Rejected');

  const TicketStatus(this.displayName);

  final String displayName;

  static TicketStatus? fromString(String? status) {
    if (status == null) return null;

    switch (status.toLowerCase()) {
      case 'pending':
        return TicketStatus.pending;
      case 'in progress':
      case 'inprogress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'rejected':
        return TicketStatus.rejected;
      default:
        return null;
    }
  }

  bool get isActive {
    return this == TicketStatus.pending || this == TicketStatus.inProgress;
  }

  bool get isResolved {
    return this == TicketStatus.resolved;
  }

  bool get isRejected {
    return this == TicketStatus.rejected;
  }
}
