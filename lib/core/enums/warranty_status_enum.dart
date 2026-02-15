enum WarrantyStatus {
  available('Available'),
  assigned('Assigned'),
  underMaintenance('Under Maintenance');

  const WarrantyStatus(this.displayName);

  final String displayName;

  static WarrantyStatus? fromString(String? status) {
    if (status == null) return null;

    switch (status.toLowerCase()) {
      case 'available':
        return WarrantyStatus.available;
      case 'assigned':
        return WarrantyStatus.assigned;
      case 'under maintenance':
      case 'undermaintenance':
        return WarrantyStatus.underMaintenance;
      default:
        return null;
    }
  }

  bool get isAvailable => this == WarrantyStatus.available;
  bool get isAssigned => this == WarrantyStatus.assigned;
  bool get isUnderMaintenance => this == WarrantyStatus.underMaintenance;
}
