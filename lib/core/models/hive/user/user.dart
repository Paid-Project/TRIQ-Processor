import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends Equatable {
  @HiveField(1)
  final String? token;

  @HiveField(2)
  final String? id;

  @HiveField(3)
  final String? name;

  @HiveField(4)
  final String? organizationName;

  @HiveField(5)
  final String? email;

  @HiveField(6)
  final String? organizationId;

  @HiveField(7)
  final UserType? userType;

  @HiveField(8)
  final OrganizationType? organizationType;

  @HiveField(9)
  final UserRole? userRole;

  @HiveField(10)
  final String? phone;

  @HiveField(12)
  final String? logoUrl;

  @HiveField(13)
  final String? fcmToken;

  // New fields added as nullable to maintain backward compatibility
  @HiveField(14)
  final String? industry;

  @HiveField(15)
  final String? language;

  @HiveField(16)
  final Address? address;

  @HiveField(17)
  final String? yourName;

  @HiveField(18)
  final String? designation;

  @HiveField(19)
  final String? fullName;

  @HiveField(20)
  final bool? isEmailVerified;

  @HiveField(21)
  final bool? isPhoneVerified;

  @HiveField(22)
  final String? countryCode;

  @HiveField(23)
  final List<Role>? roles;

  const User({
    this.email,
    this.token,
    this.name,
    this.organizationId,
    this.organizationName,
    this.id,
    this.userType,
    this.organizationType,
    this.userRole,
    this.phone,
    this.logoUrl,
    this.fcmToken,
    this.industry,
    this.language,
    this.address,
    this.yourName,
    this.designation,
    this.fullName,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.countryCode,
    this.roles,
  });

  @override
  List<Object?> get props => [
    token,
    email,
    id,
    name,
    organizationId,
    token,
    organizationName,
    userType,
    organizationType,
    userRole,
    phone,
    fcmToken,
    logoUrl,
    industry,
    language,
    address,
    yourName,
    designation,
    fullName,
    isEmailVerified,
    isPhoneVerified,
    countryCode,
    roles,
  ];

  // For backward compatibility
  String? get logo => logoUrl;

  // Helper method to get the primary role name from roles array
  String? get primaryRoleName {
    if (roles != null && roles!.isNotEmpty) {
      return roles!.first.name;
    }
    return null;
  }

  UserRole? get primaryRole {
    if (roles != null && roles!.isNotEmpty) {
      final roleName = roles!.first.name;
      if (roleName != null) {
        try {
          // Try to find by display name first
          for (final role in UserRole.values) {
            if (role.displayName.toLowerCase() == roleName.toLowerCase()) {
              return role;
            }
          }
          // Try to find by enum name
          for (final role in UserRole.values) {
            if (role.name.toLowerCase() == roleName.toLowerCase()) {
              return role;
            }
          }
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle both _id and id from backend
    final userId = json['_id'] ?? json['id'];

    return User(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      token: json['token'] as String?,
      name: (json['name'] ?? json['fullName']) as String?,
      organizationId: json['organizationId'] as String?,
      organizationName: json['organizationName'] as String?,
      id: userId as String?,
      userRole: _extractUserRole(json),
      userType:
          json['userType'] == null
              ? null
              : UserType.values.byName(json['userType'] as String),
      organizationType:
          json['organizationType'] == null
              ? null
              : OrganizationType.values.byName(
                (json['organizationType'] as String).toLowerCase(),
              ),
      // Handle both logo and logoUrl fields from backend
      logoUrl: json['logo'] ?? json['logoUrl'] as String?,
      fcmToken: json['fcmToken'] as String?,
      industry: json['industry'] as String?,
      language: json['language'] as String?,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      yourName: json['yourName'] as String?,
      designation: json['designation'] as String?,
      fullName: json['fullName'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      isPhoneVerified: json['isPhoneVerified'] as bool?,
      countryCode: json['countryCode'] as String?,
      roles:
          json['roles'] != null
              ? (json['roles'] as List)
                  .map((role) => Role.fromJson(role))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'token': token,
    'phone': phone,
    'name': name,
    'organizationId': organizationId,
    'organizationName': organizationName,
    'id': id,
    'userType': userType?.name,
    'organizationType': organizationType?.name,
    'role': userRole?.name,
    'logoUrl': logoUrl,
    'fcmToken': fcmToken,
    'industry': industry,
    'language': language,
    'address': address?.toJson(),
    'yourName': yourName,
    'designation': designation,
    'fullName': fullName,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
    'countryCode': countryCode,
    'roles': roles?.map((role) => role.toJson()).toList(),
  };

  /// Extract user role from the API response
  /// Handles both old format (single role string) and new format (roles array)
  static UserRole? _extractUserRole(Map<String, dynamic> json) {
    // Try to get role from the new roles array format
    if (json['roles'] != null && json['roles'] is List) {
      final roles = json['roles'] as List;
      if (roles.isNotEmpty) {
        final firstRole = roles.first;
        if (firstRole is Map<String, dynamic> && firstRole['name'] != null) {
          final roleName = firstRole['name'] as String;
          try {
            // Try to find by display name first
            for (final role in UserRole.values) {
              if (role.displayName.toLowerCase() == roleName.toLowerCase()) {
                return role;
              }
            }
            // Try to find by enum name
            for (final role in UserRole.values) {
              if (role.name.toLowerCase() == roleName.toLowerCase()) {
                return role;
              }
            }
          } catch (e) {
            return null;
          }
        }
      }
    }

    // Fallback to old single role format
    if (json['role'] != null) {
      final roleName = json['role'] as String;
      try {
        // Try to find by display name first
        for (final role in UserRole.values) {
          if (role.displayName == roleName) {
            return role;
          }
        }
        // Try to find by enum name
        for (final role in UserRole.values) {
          if (role.name == roleName) {
            return role;
          }
        }
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  User copyWith({
    String? token,
    String? id,
    String? name,
    String? organizationName,
    String? email,
    String? organizationId,
    UserType? userType,
    OrganizationType? organizationType,
    UserRole? userRole,
    String? phone,
    String? fcmToken,
    String? logoUrl,
    String? industry,
    String? language,
    Address? address,
    String? yourName,
    String? designation,
    String? fullName,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? countryCode,
    List<Role>? roles,
  }) {
    return User(
      token: token ?? this.token,
      id: id ?? this.id,
      name: name ?? this.name,
      organizationName: organizationName ?? this.organizationName,
      email: email ?? this.email,
      organizationId: organizationId ?? this.organizationId,
      userType: userType ?? this.userType,
      organizationType: organizationType ?? this.organizationType,
      userRole: userRole ?? this.userRole,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      industry: industry ?? this.industry,
      language: language ?? this.language,
      address: address ?? this.address,
      yourName: yourName ?? this.yourName,
      designation: designation ?? this.designation,
      fullName: fullName ?? this.fullName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      countryCode: countryCode ?? this.countryCode,
      roles: roles ?? this.roles,
    );
  }
}

@HiveType(typeId: 11)
class Role extends Equatable {
  @HiveField(1)
  final String? id;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final int? version;

  const Role({this.id, this.name, this.version});

  @override
  List<Object?> get props => [id, name, version];

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      version: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'name': name,
    '__v': version,
  };
}

@HiveType(typeId: 10)
class Address extends Equatable {
  @HiveField(1)
  final String? addressLine1;

  @HiveField(2)
  final String? addressLine2;

  @HiveField(3)
  final String? city;

  @HiveField(4)
  final String? state;

  @HiveField(5)
  final String? country;

  @HiveField(6)
  final String? pinCode;

  const Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pinCode,
  });

  @override
  List<Object?> get props => [
    addressLine1,
    addressLine2,
    city,
    state,
    country,
    pinCode,
  ];

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      pinCode: json['pinCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'country': country,
    'pinCode': pinCode,
  };
}

@HiveType(typeId: 12)
enum UserType {
  @HiveField(0)
  employee,
  @HiveField(1)
  organization;

  @override
  String toString() => name;

  String toJson() => name;

  static UserType fromJson(String json) => values.byName(json);
}

@HiveType(typeId: 13)
enum OrganizationType {
  @HiveField(0)
  processor,
  @HiveField(1)
  manufacturer;

  @override
  String toString() => name;

  String toJson() => name;

  static OrganizationType fromJson(String json) => values.byName(json);
}

@HiveType(typeId: 14)
enum UserRole {
  // Common Roles
  @HiveField(0)
  superAdmin('superAdmin'),
  @HiveField(1)
  organization('organization'),
  @HiveField(2)
  processor('processor'),

  //processor roles
  @HiveField(3)
  plantHead("Plant Head"),
  @HiveField(4)
  lineInCharge("Line InCharge"),
  @HiveField(5)
  maintenanceHead("Maintenance Head"),
  @HiveField(6)
  maintenanceEngineer("Maintenance Engineer"),
  @HiveField(7)
  machineOperator("Machine Operator"),
  @HiveField(8)
  labour("Labour"),

  // Manufacturer-specific Roles
  @HiveField(9)
  headOfGlobalService("Head of Global Service"),
  @HiveField(10)
  countryServiceManager("Country Service Manager"),
  @HiveField(11)
  localServiceEngineers("Local Service Engineers"),
  @HiveField(12)
  installationEngineers("Installation Engineers");

  final String displayName;

  const UserRole(this.displayName);

  @override
  String toString() => name;

  String toJson() => _toLowerCamelCase(name);

  static UserRole fromJson(String json) {
    return values.firstWhere(
      (role) => role.displayName == json,
      orElse: () => throw ArgumentError('Unknown user role: $json'),
    );
  }

  static String _toLowerCamelCase(String input) {
    return input[0].toLowerCase() + input.substring(1);
  }

  static List<UserRole> rolesForOrganization(OrganizationType type) {
    switch (type) {
      case OrganizationType.manufacturer:
        return values
            .where(
              (role) =>
                  ![
                    UserRole.headOfGlobalService,
                    UserRole.countryServiceManager,
                    UserRole.localServiceEngineers,
                    UserRole.installationEngineers,
                  ].contains(role),
            )
            .toList();
      default:
        return values
            .where(
              (role) =>
                  ![
                    UserRole.plantHead,
                    UserRole.lineInCharge,
                    UserRole.maintenanceHead,
                    UserRole.maintenanceEngineer,
                    UserRole.machineOperator,
                    UserRole.labour,
                  ].contains(role),
            )
            .toList();
    }
  }
}

enum EmployeeType {
  technician,
  admin,
  manager,
  employee;

  @override
  String toString() => name;

  String toJson() => name;

  static EmployeeType fromJson(String json) => values.byName(json);
}
