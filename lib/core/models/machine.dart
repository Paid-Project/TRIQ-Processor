import '../models/employee.dart';

import 'package:equatable/equatable.dart';

class Machine extends Equatable {
  final String? id;
  final String? machineName;
  final String? modelNumber;
  final String? serialNumber;
  final String? remarks;
  final int? operatingHours;
  final Location? location;
  final String? department;
  final TechnicalSpecifications? technicalSpecifications;
  final List<MaintenanceSchedule>? maintenanceSchedule;
  final String? status;
  final String? machine_type;
  final List<Employee>? assignedTechnicians;
  final Warranty? warranty;

  const Machine({
    this.id,
    this.machineName,
    this.modelNumber,
    this.serialNumber,
    this.operatingHours,

    this.location,
    this.department,
    this.technicalSpecifications,
    this.maintenanceSchedule,
    this.status,
    this.machine_type,
    this.remarks,
    this.assignedTechnicians,
    this.warranty,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['_id'],
      machineName: json['machineName'],
      modelNumber: json['modelNumber'],
      serialNumber: json['serialNumber'],
      operatingHours: json['operatingHours'],
      remarks: json['remarks'],
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      department: json['department'],
      technicalSpecifications:
          json['technicalSpecifications'] != null
              ? TechnicalSpecifications.fromJson(
                json['technicalSpecifications'],
              )
              : null,
      maintenanceSchedule:
          json['maintenanceSchedule'] != null
              ? (json['maintenanceSchedule'] as List)
                  .map((item) => MaintenanceSchedule.fromJson(item))
                  .toList()
              : null,
      status: json['status'],
      machine_type: json['machine_type'],
      assignedTechnicians:
          json['assignedTechnicians'] != null
              ? (json['assignedTechnicians'] as List)
                  .map((item) => Employee.fromJson(item))
                  .toList()
              : null,
      warranty:
          json['warranty'] != null
              ? json['warranty'].runtimeType == List
                  ? json['warranty'].length > 0
                      ? Warranty.fromJson(json['warranty'][0])
                      : null
                  : Warranty.fromJson(json['warranty'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    if (machineName != null) data['machineName'] = machineName;
    if (modelNumber != null) data['modelNumber'] = modelNumber;
    if (serialNumber != null) data['serialNumber'] = serialNumber;
    if (operatingHours != null) data['operatingHours'] = operatingHours;
    if (location != null) data['location'] = location!.toJson();
    if (department != null) data['department'] = department;
    if (technicalSpecifications != null) {
      data['technicalSpecifications'] = technicalSpecifications!.toJson();
    }
    if (maintenanceSchedule != null) {
      data['maintenanceSchedule'] =
          maintenanceSchedule!.map((item) => item.toJson()).toList();
    }
    if (status != null) data['status'] = status;
    if (machine_type != null) data['machine_type'] = machine_type;
    if (assignedTechnicians != null) {
      data['responsibleEmployeeIds'] =
          assignedTechnicians!.map((employee) => employee.id).toList();
    }
    if (warranty != null) data['warranty'] = warranty;
    return data;
  }

  @override
  List<Object?> get props => [
    id,
    machineName,
    modelNumber,
    serialNumber,
    operatingHours,
    location,
    warranty,
    department,
    technicalSpecifications,
    maintenanceSchedule,
    status,
    machine_type,
    assignedTechnicians,
  ];
}

class Location extends Equatable {
  final String? building;
  final String? room;
  final String? floor;
  final String? facility;

  const Location({this.building, this.room, this.floor, this.facility});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      building: json['building'],
      room: json['room'],
      facility: json['facility'],
      floor: json['floor'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (building != null) data['building'] = building;
    if (room != null) data['room'] = room;
    if (facility != null) data['facility'] = facility;
    if (floor != null) data['floor'] = floor;
    return data;
  }

  @override
  List<Object?> get props => [building, room, floor, facility];
}

class TechnicalSpecifications extends Equatable {
  final String? capacity;
  final Dimensions? dimensions;
  final ProcessingArea? processingArea;
  final PowerRequirements? powerRequirements;
  final Weight? weight;
  final MachineType machineType;
  final List<AdditionalInfo>? additionalInfo;

  const TechnicalSpecifications({
    this.capacity,
    this.dimensions,
    this.processingArea,
    this.powerRequirements,
    this.weight,
    this.machineType = MachineType.manual,
    this.additionalInfo,
  });

  factory TechnicalSpecifications.fromJson(Map<String, dynamic> json) {
    return TechnicalSpecifications(
      capacity: json['capacity'],
      dimensions:
          json['dimensions'] != null
              ? Dimensions.fromJson(json['dimensions'])
              : null,
      processingArea:
          json['processingArea'] != null
              ? ProcessingArea.fromJson(json['processingArea'])
              : null,
      powerRequirements:
          json['powerRequirements'] != null
              ? PowerRequirements.fromJson(json['powerRequirements'])
              : null,
      weight: json['weight'] != null ? Weight.fromJson(json['weight']) : null,
      machineType: MachineType.values.firstWhere(
        (element) =>
            element.name ==
            ((json.containsKey('machineType') && json['machineType'] != null)
                ? json['machineType']
                : 'fullyAutomatic'),
      ),
      additionalInfo:
          json['additionalInfo'] != null
              ? (json['additionalInfo'] as List)
                  .map((item) => AdditionalInfo.fromJson(item))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (capacity != null) data['capacity'] = capacity;
    if (dimensions != null) data['dimensions'] = dimensions!.toJson();
    if (processingArea != null)
      data['processingArea'] = processingArea!.toJson();
    if (powerRequirements != null) {
      data['powerRequirements'] = powerRequirements!.toJson();
    }
    if (weight != null) data['weight'] = weight!.toJson();
    data['machineType'] = machineType.name;
    if (additionalInfo != null) {
      data['additionalInfo'] =
          additionalInfo!.map((item) => item.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [
    capacity,
    dimensions,
    powerRequirements,
    weight,
    machineType,
    additionalInfo,
  ];
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

class Dimensions extends Equatable {
  final double? width;
  final double? height;
  final double? depth;
  final String? unit;

  const Dimensions({this.width, this.height, this.depth, this.unit});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      depth: json['depth']?.toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (width != null) data['width'] = width;
    if (height != null) data['height'] = height;
    if (depth != null) data['depth'] = depth;
    if (unit != null) data['unit'] = unit;
    return data;
  }

  @override
  List<Object?> get props => [width, height, depth, unit];
}

class ProcessingArea extends Equatable {
  final double? max;
  final double? min;
  final String? unit;

  const ProcessingArea({this.max, this.min, this.unit});

  factory ProcessingArea.fromJson(Map<String, dynamic> json) {
    return ProcessingArea(
      max: json['max']?.toDouble(),
      min: json['min']?.toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (max != null) data['max'] = max;
    if (min != null) data['min'] = min;
    if (unit != null) data['unit'] = unit;
    return data;
  }

  @override
  List<Object?> get props => [max, min, unit];
}

class PowerRequirements extends Equatable {
  final int? voltage;
  final int? amperage;
  final int? phase;
  final double? powerConsumption;

  const PowerRequirements({
    this.voltage,
    this.amperage,
    this.phase,
    this.powerConsumption,
  });

  factory PowerRequirements.fromJson(Map<String, dynamic> json) {
    return PowerRequirements(
      voltage: json['voltage'],
      amperage: json['amperage'],
      phase: json['phase'],
      powerConsumption: json['powerConsumption']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (voltage != null) data['voltage'] = voltage;
    if (amperage != null) data['amperage'] = amperage;
    if (phase != null) data['phase'] = phase;
    if (powerConsumption != null) data['powerConsumption'] = powerConsumption;
    return data;
  }

  @override
  List<Object?> get props => [voltage, amperage, phase, powerConsumption];
}

class Weight extends Equatable {
  final double? value;
  final String? unit;

  const Weight({this.value, this.unit});

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(value: json['value']?.toDouble(), unit: json['unit']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (value != null) data['value'] = value;
    if (unit != null) data['unit'] = unit;
    return data;
  }

  @override
  List<Object?> get props => [value, unit];
}

class MaintenanceSchedule extends Equatable {
  final String? type;
  final String? description;
  final int? interval;
  final bool? isActive;

  const MaintenanceSchedule({
    this.type,
    this.description,
    this.interval,
    this.isActive,
  });

  factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
    return MaintenanceSchedule(
      type: json['type'],
      description: json['description'],
      interval: json['interval'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (type != null) data['type'] = type;
    if (description != null) data['description'] = description;
    if (interval != null) data['interval'] = interval;
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }

  @override
  List<Object?> get props => [type, description, interval, isActive];
}

enum MachineType {
  fullyAutomatic,
  semiAutomatic,
  manual;

  @override
  String toString() {
    // Convert camelCase to words with spaces
    final result = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Capitalize first letter
    return '${result[0].toUpperCase()}${result.substring(1)}';
  }
}

class Address {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;

  Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pinCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pinCode: json['pinCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
    };
  }
}

class Warranty extends Equatable {
  final String? status;
  final String? startDate;
  final String? expirationDate;
  final String? purchaseDate;
  final String? invoiceNo;
  final String? installationDate;
  const Warranty({
    this.status,
    this.startDate,
    this.expirationDate,
    this.purchaseDate,
    this.invoiceNo,
    this.installationDate,
  });

  factory Warranty.fromJson(Map<String, dynamic> json) {
    return Warranty(
      status: json['status'],
      startDate: json['startDate'],
      expirationDate: json['expirationDate'],
      purchaseDate: json['purchaseDate'],
      invoiceNo: json['invoiceNo'],
      installationDate: json['installationDate'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (startDate != null) data['startDate'] = startDate;
    if (expirationDate != null) data['expirationDate'] = expirationDate;
    if (purchaseDate != null) data['purchaseDate'] = purchaseDate;
    if (invoiceNo != null) data['invoiceNo'] = invoiceNo;
    if (installationDate != null) data['installationDate'] = installationDate;
    return data;
  }

  @override
  List<Object?> get props => [
    status,
    startDate,
    expirationDate,
    purchaseDate,
    invoiceNo,
    installationDate,
  ];
}
