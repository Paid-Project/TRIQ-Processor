import 'package:flutter/material.dart';

class HierarchyNode extends ChangeNotifier {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? profilePhoto;
  final String? employeeId;
  final String? bloodGroup;
  final String? country;
  final String? area;
  final String? employeeType;
  final String? shiftTiming;
  final String? joiningDate;
  final int? autoLevel;
  final bool isActive;
  final Designation? designation;
  final Department? department;
  final List<HierarchyNode> children;

  bool _isExpanded;

  HierarchyNode({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.profilePhoto,
    this.employeeId,
    this.bloodGroup,
    this.country,
    this.area,
    this.employeeType,
    this.shiftTiming,
    this.autoLevel,
    this.joiningDate,
    this.isActive = true,
    this.designation,
    this.department,
    this.children = const [],
    bool isInitiallyExpanded = false,
  }) : _isExpanded = isInitiallyExpanded;

  bool get isExpanded => _isExpanded;

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  // Color based on designation level
  Color get color {
    if (designation == null) return const Color(0xFFB8EFD2);

    switch (autoLevel) {
      case 1:
        return const Color(0xFFF0D8EE); // Purple - Director
      case 2:
        return const Color(0xFFCDE9DB); // Green - CEO
      case 3:
        return const Color(0xFFFFE7BB); // Orange
      case 4:
        return const Color(0xFFE9ECCF);
      case 5:
        return const Color(0xFFFCDCE1); // Light Green
      default:
        return const Color(0xFFB8EFD2);
    }
  }

  factory HierarchyNode.fromJson(Map<String, dynamic> json) {
    return HierarchyNode(
      id: json['_id'] ?? '',
      name: json['fullName'] ?? json['name'] ?? 'Unknown',
      email: json['email'],
      phone: json['phone'],
      profilePhoto: json['profilePhoto'],
      employeeId: json['employeeId'],
      bloodGroup: json['bloodGroup'],
      country: json['country'],
      area: json['area'],
      employeeType: json['employeeType'],
      shiftTiming: json['shiftTiming'],
      joiningDate: json['joiningDate'],
      isActive: json['isActive'] ?? true,
      autoLevel: json['autoLevel'],
      designation: json['designation'] != null
          ? Designation.fromJson(json['designation'])
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      children: json['children'] != null
          ? (json['children'] as List)
          .map((child) => HierarchyNode.fromJson(child))
          .toList()
          : [],
      isInitiallyExpanded: false,
    );
  }
}

class Designation {
  final String? id;
  final String name;
  final int level;

  Designation({
    this.id,
    required this.name,
    required this.level,
  });

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(
      id: json['_id'],
      name: json['name'] ?? 'Unknown',
      level: json['level'] ?? 1,
    );
  }
}

class Department {
  final String id;
  final String name;

  Department({
    required this.id,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Department',
    );
  }
}