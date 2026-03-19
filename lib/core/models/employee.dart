

class Employee {
  // ==================== IDs & Basic Info ====================
  final String? id;
  String? name;              // FROM MODEL A (keep separate from fullName)
  String? fullName;          // FROM MODEL B
  String? email;
  String? phone;
  String? employeeId;

  // ==================== Employment Info ====================
  String? employmentStatus;
  String? employeeType;
  String? role;
  String? shift;             // FROM MODEL B
  String? shiftTiming;       // FROM MODEL A (keep both)
  String? joiningDate;

  // ==================== Department & Designation ====================
  EmployeeDepartment? department;   // FIXED: Changed from String? to Object
  EmployeeDesignation? designation; // FIXED: Changed from String? to Object

  // ==================== Location & Reporting ====================
  String? country;
  String? area;              // FROM MODEL A
  String? reportTo;          // FROM MODEL A (keep separate from reportingManager)
  String? reportingManager;  // FROM MODEL B
  String? workRegion;
  String? workLocation;

  // ==================== Personal Details ====================
  String? dateOfBirth;
  String? gender;
  String? bloodGroup;

  // ==================== Contact Info ====================
  String? personalPhone;
  String? whatsappNumber;
  String? personalEmail;
  String? workEmail;
  String? workPhone;

  // ==================== Profile & Documents ====================
  String? profilePhoto;      // FROM MODEL A
  String? profilePictureUrl; // FROM MODEL B (keep both)
  String? localIdPassportUrl;
  List<String>? localIdPassportUrls;
  List<String>? resumeUrls;
  List<String>? degreeCertificateUrls;
  List<String>? experienceLetterUrls;
  Map<String, List<String>>? documents;

  // ==================== Current Address ====================
  String? currentAddressLine1;
  String? currentAddressLine2;
  String? currentCity;
  String? currentState;
  String? currentCountry;
  String? currentZipCode;

  // ==================== Permanent Address ====================
  String? permanentAddressLine1;
  String? permanentAddressLine2;
  String? permanentCity;
  String? permanentState;
  String? permanentCountry;
  String? permanentZipCode;
  bool? sameAsCurrentAddress;

  // ==================== Emergency Contact ====================
  String? emergencyContactName;
  String? emergencyRelationship;
  String? emergencyPhone;

  // ==================== Nested Objects ====================
  final Permissions? permissions;           // ✅ Already added
  final PersonalAddress? personalAddress;   // ✅ Already added
  final EmergencyContact? emergencyContact; // ✅ Already added

  // ==================== Identification & HR ====================
  String? nationalTaxId;
  String? panAadharSsnNin;
  String? bankDetails;
  bool? isHRApproved;

  // ==================== Team & Supervision ====================
  String? supervisorId;
  String? teamId;
  String? salary;

  // ==================== Account Status ====================
  String? accountStatus;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  dynamic phoneVerificationOTP;
  dynamic phoneVerificationOTPExpires;
  bool? isActive;

  // ==================== Onboarding ====================
  bool? profileCompleted;
  double? profileCompletionPercentage;
  bool? documentsVerified;
  bool? backgroundCheckCompleted;
  String? onboardingStatus;

  // ==================== Preferences ====================
  String? preferredLanguage;

  // ==================== Metadata ====================
  String? flag;              // FROM MODEL A
  String? user;              // FROM MODEL A (if needed)
   String? linkedUser;
  String? createdAt;
  String? updatedAt;
  String? lastLoginAt;
  String? profileUpdatedAt;
  String? terminationDate;
  String? terminationReason;
  int? v;
  String? organizationId;

  Employee({
    // IDs & Basic
    this.id,
    this.name,              // ADD
    this.fullName,
    this.email,
    this.phone,
    this.employeeId,

    // Employment
    this.employmentStatus,
    this.employeeType,
    this.role,
    this.shift,
    this.shiftTiming,       // ADD
    this.joiningDate,

    // Department & Designation
    this.department,
    this.designation,

    // Location & Reporting
    this.country,
    this.area,              // ADD
    this.reportTo,          // ADD
    this.reportingManager,
    this.workRegion,
    this.workLocation,

    // Personal
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,

    // Contact
    this.personalPhone,
    this.whatsappNumber,
    this.personalEmail,
    this.workEmail,
    this.workPhone,

    // Profile & Documents
    this.profilePhoto,      // ADD
    this.profilePictureUrl,
    this.localIdPassportUrl,
    this.localIdPassportUrls,
    this.resumeUrls,
    this.degreeCertificateUrls,
    this.experienceLetterUrls,
    this.documents,

    // Current Address
    this.currentAddressLine1,
    this.currentAddressLine2,
    this.currentCity,
    this.currentState,
    this.currentCountry,
    this.currentZipCode,

    // Permanent Address
    this.permanentAddressLine1,
    this.permanentAddressLine2,
    this.permanentCity,
    this.permanentState,
    this.permanentCountry,
    this.permanentZipCode,
    this.sameAsCurrentAddress,

    // Emergency Contact
    this.emergencyContactName,
    this.emergencyRelationship,
    this.emergencyPhone,

    // Nested Objects
    this.permissions,
    this.personalAddress,
    this.emergencyContact,

    // Identification & HR
    this.nationalTaxId,
    this.panAadharSsnNin,
    this.bankDetails,
    this.isHRApproved,

    // Team & Supervision
    this.supervisorId,
    this.teamId,
    this.salary,

    // Account Status
    this.accountStatus,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.phoneVerificationOTP,
    this.phoneVerificationOTPExpires,
    this.isActive,

    // Onboarding
    this.profileCompleted,
    this.profileCompletionPercentage,
    this.documentsVerified,
    this.backgroundCheckCompleted,
    this.onboardingStatus,

    // Preferences
    this.preferredLanguage,

    // Metadata
    this.flag,              // ADD
    this.user,              // ADD (optional)
    this.linkedUser,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.profileUpdatedAt,
    this.terminationDate,
    this.terminationReason,
    this.v,
    this.organizationId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      // IDs & Basic
      id: json['_id'],
      name: json['name'],                    // ADD
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      employeeId: json['employeeId'],

      // Employment
      employmentStatus: json['employmentStatus'],
      employeeType: json['employeeType'],
      role: json['role'],
      shift: json['shift'],
      shiftTiming: json['shiftTiming'],      // ADD
      joiningDate: json['joiningDate'],

      // Department & Designation - FIXED
      department: json["department"] != null
          ? EmployeeDepartment.fromJson(json["department"])
          : null,
      designation: json["designation"] != null
          ? EmployeeDesignation.fromJson(json["designation"])
          : null,

      // Location & Reporting
      country: json['country'],
      area: json['area'],                    // ADD
      reportTo: json['reportTo'],            // ADD
      reportingManager: json['reportingManager'],
      workRegion: json['workRegion'],
      workLocation: json['workLocation'],

      // Personal
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],

      // Contact
      personalPhone: json['personalPhone'],
      whatsappNumber: json['whatsappNumber'],
      personalEmail: json['personalEmail'],
      workEmail: json['workEmail'],
      workPhone: json['workPhone'],

      // Profile & Documents
      profilePhoto: json['profilePhoto'],    // ADD
      profilePictureUrl: json['profilePictureUrl'],
      localIdPassportUrl: json['localIdPassportUrl'],
      localIdPassportUrls: json['localIdPassportUrls'] != null
          ? List<String>.from(json['localIdPassportUrls'])
          : null,
      resumeUrls: json['resumeUrls'] != null
          ? List<String>.from(json['resumeUrls'])
          : null,
      degreeCertificateUrls: json['degreeCertificateUrls'] != null
          ? List<String>.from(json['degreeCertificateUrls'])
          : null,
      experienceLetterUrls: json['experienceLetterUrls'] != null
          ? List<String>.from(json['experienceLetterUrls'])
          : null,
      documents: json['documents'] != null
          ? Map<String, List<String>>.from(
          json['documents'].map((key, value) =>
              MapEntry(key, List<String>.from(value))))
          : null,

      // Current Address
      currentAddressLine1: json['currentAddressLine1'],
      currentAddressLine2: json['currentAddressLine2'],
      currentCity: json['currentCity'],
      currentState: json['currentState'],
      currentCountry: json['currentCountry'],
      currentZipCode: json['currentZipCode'],

      // Permanent Address
      permanentAddressLine1: json['permanentAddressLine1'],
      permanentAddressLine2: json['permanentAddressLine2'],
      permanentCity: json['permanentCity'],
      permanentState: json['permanentState'],
      permanentCountry: json['permanentCountry'],
      permanentZipCode: json['permanentZipCode'],
      sameAsCurrentAddress: json['sameAsCurrentAddress'],

      // Emergency Contact
      emergencyContactName: json['emergencyContactName'],
      emergencyRelationship: json['emergencyRelationship'],
      emergencyPhone: json['emergencyPhone'],

      // Nested Objects
      permissions: json['permissions'] != null
          ? Permissions.fromJson(json['permissions'])
          : null,
      personalAddress: json["personalAddress"] != null
          ? PersonalAddress.fromJson(json["personalAddress"])
          : null,
      emergencyContact: json["emergencyContact"] != null
          ? EmergencyContact.fromJson(json["emergencyContact"])
          : null,

      // Identification & HR
      nationalTaxId: json['nationalTaxId'],
      panAadharSsnNin: json['panAadharSsnNin'],
      bankDetails: json['bankDetails'],
      isHRApproved: json['isHRApproved'],

      // Team & Supervision
      supervisorId: json['supervisorId'],
      teamId: json['teamId'],
      salary: json['salary'],

      // Account Status
      accountStatus: json['accountStatus'],
      isEmailVerified: json['isEmailVerified'],
      isPhoneVerified: json['isPhoneVerified'],
      phoneVerificationOTP: json['phoneVerificationOTP'],
      phoneVerificationOTPExpires: json['phoneVerificationOTPExpires'],
      isActive: json['isActive'],

      // Onboarding
      profileCompleted: json['profileCompleted'],
      profileCompletionPercentage: json['profileCompletionPercentage']?.toDouble(),
      documentsVerified: json['documentsVerified'],
      backgroundCheckCompleted: json['backgroundCheckCompleted'],
      onboardingStatus: json['onboardingStatus'],

      // Preferences
      preferredLanguage: json['preferredLanguage'],
      linkedUser: json["linkedUser"],
      // Metadata
      flag: json['flag'],                    // ADD
      user: json['user'],                    // ADD
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      lastLoginAt: json['lastLoginAt'],
      profileUpdatedAt: json['profileUpdatedAt'],
      terminationDate: json['terminationDate'],
      terminationReason: json['terminationReason'],
      v: json['__v'],
      organizationId: json['organizationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // IDs & Basic
      '_id': id,
      'name': name,                          // ADD
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'employeeId': employeeId,

      // Employment
      'employmentStatus': employmentStatus,
      'employeeType': employeeType,
      'role': role,
      'shift': shift,
      'shiftTiming': shiftTiming,            // ADD
      'joiningDate': joiningDate,

      // Department & Designation - FIXED
      'department': department?.toJson(),
      'designation': designation?.toJson(),

      // Location & Reporting
      'country': country,
      'area': area,                          // ADD
      'reportTo': reportTo,                  // ADD
      'reportingManager': reportingManager,
      'workRegion': workRegion,
      'workLocation': workLocation,

      // Personal
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,

      // Contact
      'personalPhone': personalPhone,
      'whatsappNumber': whatsappNumber,
      'personalEmail': personalEmail,
      'workEmail': workEmail,
      'workPhone': workPhone,

      // Profile & Documents
      'profilePhoto': profilePhoto,          // ADD
      'profilePictureUrl': profilePictureUrl,
      'localIdPassportUrl': localIdPassportUrl,
      'localIdPassportUrls': localIdPassportUrls,
      'resumeUrls': resumeUrls,
      'degreeCertificateUrls': degreeCertificateUrls,
      'experienceLetterUrls': experienceLetterUrls,
      'documents': documents,

      // Current Address
      'currentAddressLine1': currentAddressLine1,
      'currentAddressLine2': currentAddressLine2,
      'currentCity': currentCity,
      'currentState': currentState,
      'currentCountry': currentCountry,
      'currentZipCode': currentZipCode,

      // Permanent Address
      'permanentAddressLine1': permanentAddressLine1,
      'permanentAddressLine2': permanentAddressLine2,
      'permanentCity': permanentCity,
      'permanentState': permanentState,
      'permanentCountry': permanentCountry,
      'permanentZipCode': permanentZipCode,
      'sameAsCurrentAddress': sameAsCurrentAddress,

      // Emergency Contact
      'emergencyContactName': emergencyContactName,
      'emergencyRelationship': emergencyRelationship,
      'emergencyPhone': emergencyPhone,

      // Nested Objects
      'permissions': permissions?.toJson(),
      "personalAddress": personalAddress?.toJson(),
      "emergencyContact": emergencyContact?.toJson(),

      // Identification & HR
      'nationalTaxId': nationalTaxId,
      'panAadharSsnNin': panAadharSsnNin,
      'bankDetails': bankDetails,
      'isHRApproved': isHRApproved,

      // Team & Supervision
      'supervisorId': supervisorId,
      'teamId': teamId,
      'salary': salary,

      // Account Status
      'accountStatus': accountStatus,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'phoneVerificationOTP': phoneVerificationOTP,
      'phoneVerificationOTPExpires': phoneVerificationOTPExpires,
      'isActive': isActive,

      // Onboarding
      'profileCompleted': profileCompleted,
      'profileCompletionPercentage': profileCompletionPercentage,
      'documentsVerified': documentsVerified,
      'backgroundCheckCompleted': backgroundCheckCompleted,
      'onboardingStatus': onboardingStatus,

      // Preferences
      'preferredLanguage': preferredLanguage,

      // Metadata
      'flag': flag,                          // ADD
      'user': user,                          // ADD
      "linkedUser": linkedUser,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
      'profileUpdatedAt': profileUpdatedAt,
      'terminationDate': terminationDate,
      'terminationReason': terminationReason,
      '__v': v,
      'organizationId': organizationId,
    };
  }

  // Helper method to get display name
  String get displayName {
    // Priority: fullName > name > 'N/A'
    if (fullName?.isNotEmpty == true) return fullName!;
    if (name?.isNotEmpty == true) return name!;
    return 'N/A';
  }

  // Helper method to get primary email
  String get primaryEmail => email?.isNotEmpty == true ? email! : (personalEmail ?? '');

  // Helper method to get primary phone
  String get primaryPhone => phone?.isNotEmpty == true ? phone! : (personalPhone ?? '');

  // Helper method to check if profile is complete
  bool get isProfileComplete => profileCompleted ?? false;

  // Helper method to calculate profile completion
  double calculateProfileCompletion() {
    if (profileCompletionPercentage != null) {
      return profileCompletionPercentage!;
    }

    int totalFields = 15;
    int filledFields = 0;

    if (fullName?.isNotEmpty == true || name?.isNotEmpty == true) filledFields++;
    if (dateOfBirth?.isNotEmpty == true) filledFields++;
    if (gender?.isNotEmpty == true) filledFields++;
    if (bloodGroup?.isNotEmpty == true) filledFields++;
    if (personalPhone?.isNotEmpty == true || phone?.isNotEmpty == true) filledFields++;
    if (personalEmail?.isNotEmpty == true || email?.isNotEmpty == true) filledFields++;
    if (currentAddressLine1?.isNotEmpty == true) filledFields++;
    if (currentCity?.isNotEmpty == true) filledFields++;
    if (currentState?.isNotEmpty == true) filledFields++;
    if (currentCountry?.isNotEmpty == true) filledFields++;
    if (country?.isNotEmpty == true) filledFields++;
    if (currentZipCode?.isNotEmpty == true) filledFields++;
    if (emergencyContactName?.isNotEmpty == true) filledFields++;
    if (emergencyRelationship?.isNotEmpty == true) filledFields++;
    if (emergencyPhone?.isNotEmpty == true) filledFields++;
    if (profilePictureUrl?.isNotEmpty == true || profilePhoto?.isNotEmpty == true) filledFields++;

    return (filledFields / totalFields) * 100;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  // Updated copyWith method with ALL fields
  Employee copyWith({
    String? id,
    String? name,                // ADD
    String? fullName,
    String? email,
    String? phone,
    String? employmentStatus,
    String? employeeType,
    String? role,
    String? shift,
    String? shiftTiming,         // ADD
    Permissions? permissions,
    String? accountStatus,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    dynamic phoneVerificationOTP,
    dynamic phoneVerificationOTPExpires,
    String? createdAt,
    String? updatedAt,
    int? v,
    String? organizationId,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? personalPhone,
    String? whatsappNumber,
    String? personalEmail,
    String? currentAddressLine1,
    String? currentAddressLine2,
    String? currentCity,
    String? currentState,
    String? currentCountry,
    String? country,
    String? currentZipCode,
    String? permanentAddressLine1,
    String? permanentAddressLine2,
    String? permanentCity,
    String? permanentState,
    String? permanentCountry,
    String? permanentZipCode,
    bool? sameAsCurrentAddress,
    String? emergencyContactName,
    String? emergencyRelationship,
    String? emergencyPhone,
    String? nationalTaxId,
    String? localIdPassportUrl,
    List<String>? localIdPassportUrls,
    String? profilePhoto,        // ADD
    String? profilePictureUrl,
    List<String>? resumeUrls,
    List<String>? degreeCertificateUrls,
    List<String>? experienceLetterUrls,
    Map<String, List<String>>? documents,
    String? preferredLanguage,
    bool? isHRApproved,
    String? panAadharSsnNin,
    String? bankDetails,
    String? workRegion,
    String? reportingManager,
    String? reportTo,            // ADD
    String? joiningDate,
    EmployeeDepartment? department,    // FIXED type
    EmployeeDesignation? designation,  // FIXED type
    String? employeeId,
    String? workLocation,
    String? salary,
    String? workEmail,
    String? workPhone,
    String? supervisorId,
    String? teamId,
    bool? profileCompleted,
    double? profileCompletionPercentage,
    bool? documentsVerified,
    bool? backgroundCheckCompleted,
    String? onboardingStatus,
    String? lastLoginAt,
    String? profileUpdatedAt,
    bool? isActive,
    String? terminationDate,
    String? terminationReason,
    String? flag,                // ADD
    String? area,                // ADD
    String? user,                // ADD
    String? linkedUser,                // ADD
    PersonalAddress? personalAddress,
    EmergencyContact? emergencyContact,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,                        // ADD
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      employeeType: employeeType ?? this.employeeType,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      shiftTiming: shiftTiming ?? this.shiftTiming,   // ADD
      permissions: permissions ?? this.permissions,
      accountStatus: accountStatus ?? this.accountStatus,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      phoneVerificationOTP: phoneVerificationOTP ?? this.phoneVerificationOTP,
      phoneVerificationOTPExpires: phoneVerificationOTPExpires ?? this.phoneVerificationOTPExpires,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      organizationId: organizationId ?? this.organizationId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      personalPhone: personalPhone ?? this.personalPhone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      personalEmail: personalEmail ?? this.personalEmail,
      currentAddressLine1: currentAddressLine1 ?? this.currentAddressLine1,
      currentAddressLine2: currentAddressLine2 ?? this.currentAddressLine2,
      currentCity: currentCity ?? this.currentCity,
      currentState: currentState ?? this.currentState,
      currentCountry: currentCountry ?? this.currentCountry,
      country: country ?? this.country,
      currentZipCode: currentZipCode ?? this.currentZipCode,
      permanentAddressLine1: permanentAddressLine1 ?? this.permanentAddressLine1,
      permanentAddressLine2: permanentAddressLine2 ?? this.permanentAddressLine2,
      permanentCity: permanentCity ?? this.permanentCity,
      permanentState: permanentState ?? this.permanentState,
      permanentCountry: permanentCountry ?? this.permanentCountry,
      permanentZipCode: permanentZipCode ?? this.permanentZipCode,
      sameAsCurrentAddress: sameAsCurrentAddress ?? this.sameAsCurrentAddress,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyRelationship: emergencyRelationship ?? this.emergencyRelationship,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      nationalTaxId: nationalTaxId ?? this.nationalTaxId,
      localIdPassportUrl: localIdPassportUrl ?? this.localIdPassportUrl,
      localIdPassportUrls: localIdPassportUrls ?? this.localIdPassportUrls,
      profilePhoto: profilePhoto ?? this.profilePhoto,                // ADD
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      resumeUrls: resumeUrls ?? this.resumeUrls,
      degreeCertificateUrls: degreeCertificateUrls ?? this.degreeCertificateUrls,
      experienceLetterUrls: experienceLetterUrls ?? this.experienceLetterUrls,
      documents: documents ?? this.documents,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isHRApproved: isHRApproved ?? this.isHRApproved,
      panAadharSsnNin: panAadharSsnNin ?? this.panAadharSsnNin,
      bankDetails: bankDetails ?? this.bankDetails,
      workRegion: workRegion ?? this.workRegion,
      reportingManager: reportingManager ?? this.reportingManager,
      reportTo: reportTo ?? this.reportTo,                            // ADD
      joiningDate: joiningDate ?? this.joiningDate,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      employeeId: employeeId ?? this.employeeId,
      workLocation: workLocation ?? this.workLocation,
      salary: salary ?? this.salary,
      workEmail: workEmail ?? this.workEmail,
      workPhone: workPhone ?? this.workPhone,
      supervisorId: supervisorId ?? this.supervisorId,
      teamId: teamId ?? this.teamId,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
      documentsVerified: documentsVerified ?? this.documentsVerified,
      backgroundCheckCompleted: backgroundCheckCompleted ?? this.backgroundCheckCompleted,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileUpdatedAt: profileUpdatedAt ?? this.profileUpdatedAt,
      isActive: isActive ?? this.isActive,
      terminationDate: terminationDate ?? this.terminationDate,
      terminationReason: terminationReason ?? this.terminationReason,
      flag: flag ?? this.flag,                                        // ADD
      area: area ?? this.area,                                        // ADD
      user: user ?? this.user,                                        // ADD
      linkedUser: linkedUser ?? this.linkedUser,                                        // ADD
      personalAddress: personalAddress ?? this.personalAddress,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }
}


class EmployeeDepartment {
  final String? id;
  final String? name;

  EmployeeDepartment({this.id, this.name});

  factory EmployeeDepartment.fromJson(Map<String, dynamic> json) {
    return EmployeeDepartment(
      id: json["_id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}

class EmployeeDesignation {
  final String? id;
  final String? name;

  EmployeeDesignation({this.id, this.name});

  factory EmployeeDesignation.fromJson(Map<String, dynamic> json) {
    return EmployeeDesignation(
      id: json["_id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}

class PersonalAddress {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? id;

  PersonalAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.id,
  });

  factory PersonalAddress.fromJson(Map<String, dynamic> json) =>
      PersonalAddress(
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        pincode: json["pincode"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
    "city": city,
    "state": state,
    "country": country,
    "pincode": pincode,
    "_id": id,
  };
}

// NEW: Nested Model for EmergencyContact
class EmergencyContact {
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactEmail;
  final String? id;

  EmergencyContact({
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactEmail,
    this.id,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        emergencyContactName: json["emergencyContactName"],
        emergencyContactPhone: json["emergencyContactPhone"],
        emergencyContactEmail: json["emergencyContactEmail"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
    "emergencyContactName": emergencyContactName,
    "emergencyContactPhone": emergencyContactPhone,
    "emergencyContactEmail": emergencyContactEmail,
    "_id": id,
  };
}

// NEW: Nested Model for Permissions
class Permissions {
  final PermissionDetail? serviceDepartment;
  final PermissionDetail? accessLevel;
  final PermissionDetail? machineOperation;
  final PermissionDetail? ticketManagement;
  final PermissionDetail? approvalAuthority;
  final PermissionDetail? reportAccess;

  Permissions({
    this.serviceDepartment,
    this.accessLevel,
    this.machineOperation,
    this.ticketManagement,
    this.approvalAuthority,
    this.reportAccess,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
    serviceDepartment: json["serviceDepartment"] != null
        ? PermissionDetail.fromJson(json["serviceDepartment"])
        : null,
    accessLevel: json["accessLevel"] != null
        ? PermissionDetail.fromJson(json["accessLevel"])
        : null,
    machineOperation: json["machineOperation"] != null
        ? PermissionDetail.fromJson(json["machineOperation"])
        : null,
    ticketManagement: json["ticketManagement"] != null
        ? PermissionDetail.fromJson(json["ticketManagement"])
        : null,
    approvalAuthority: json["approvalAuthority"] != null
        ? PermissionDetail.fromJson(json["approvalAuthority"])
        : null,
    reportAccess: json["reportAccess"] != null
        ? PermissionDetail.fromJson(json["reportAccess"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "serviceDepartment": serviceDepartment?.toJson(),
    "accessLevel": accessLevel?.toJson(),
    "machineOperation": machineOperation?.toJson(),
    "ticketManagement": ticketManagement?.toJson(),
    "approvalAuthority": approvalAuthority?.toJson(),
    "reportAccess": reportAccess?.toJson(),
  };

  factory Permissions.initial() => Permissions(
    serviceDepartment: PermissionDetail.initial(),
    accessLevel: PermissionDetail.initial(),
    machineOperation: PermissionDetail.initial(),
    ticketManagement: PermissionDetail.initial(),
    approvalAuthority: PermissionDetail.initial(),
    reportAccess: PermissionDetail.initial(),
  );

  Permissions copyWith({
    PermissionDetail? serviceDepartment,
    PermissionDetail? accessLevel,
    PermissionDetail? machineOperation,
    PermissionDetail? ticketManagement,
    PermissionDetail? approvalAuthority,
    PermissionDetail? reportAccess,
  }) {
    return Permissions(
      serviceDepartment: serviceDepartment ?? this.serviceDepartment,
      accessLevel: accessLevel ?? this.accessLevel,
      machineOperation: machineOperation ?? this.machineOperation,
      ticketManagement: ticketManagement ?? this.ticketManagement,
      approvalAuthority: approvalAuthority ?? this.approvalAuthority,
      reportAccess: reportAccess ?? this.reportAccess,
    );
  }
}

// NEW: Nested Model for individual permission details (view/edit)
class PermissionDetail {
  final bool? view;
  final bool? edit;

  PermissionDetail({this.view, this.edit});

  factory PermissionDetail.fromJson(Map<String, dynamic> json) =>
      PermissionDetail(
        view: json["view"],
        edit: json["edit"],
      );

  Map<String, dynamic> toJson() => {
    "view": view,
    "edit": edit,
  };
  factory PermissionDetail.initial() => PermissionDetail(view: false, edit: false);

  PermissionDetail copyWith({bool? view, bool? edit}) {
    return PermissionDetail(
      view: view ?? this.view,
      edit: edit ?? this.edit,
    );
  }
}
