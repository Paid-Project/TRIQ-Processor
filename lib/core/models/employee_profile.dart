class EmployeeProfile {
  final String? id;
  String? fullName;
  DateTime? dateOfBirth;
  String? gender;
  String? bloodGroup;

  String? phoneNumber;
  String? whatsappNumber;
  String? email;

  String? currentAddress;
  String? permanentAddress;
  String? country;
  String? city;
  String? zipCode;

  String? emergencyContactName;
  String? emergencyContactRelationship;
  String? emergencyContactPhone;

  String? localIdOrPassport;
  String? nationalTaxId;

  String? passportPhoto;
  String? resume;
  String? degreeCertificates;
  String? experienceLetters;

  String? preferredLanguage;

  EmployeeProfile({
    this.id,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.phoneNumber,
    this.whatsappNumber,
    this.email,
    this.currentAddress,
    this.permanentAddress,
    this.country,
    this.city,
    this.zipCode,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactPhone,
    this.localIdOrPassport,
    this.nationalTaxId,
    this.passportPhoto,
    this.resume,
    this.degreeCertificates,
    this.experienceLetters,
    this.preferredLanguage,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      id: json['id'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      phoneNumber: json['phoneNumber'],
      whatsappNumber: json['whatsappNumber'],
      email: json['email'],
      currentAddress: json['currentAddress'],
      permanentAddress: json['permanentAddress'],
      country: json['country'],
      city: json['city'],
      zipCode: json['zipCode'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactRelationship: json['emergencyContactRelationship'],
      emergencyContactPhone: json['emergencyContactPhone'],
      localIdOrPassport: json['localIdOrPassport'],
      nationalTaxId: json['nationalTaxId'],
      passportPhoto: json['passportPhoto'],
      resume: json['resume'],
      degreeCertificates: json['degreeCertificates'],
      experienceLetters: json['experienceLetters'],
      preferredLanguage: json['preferredLanguage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'currentAddress': currentAddress,
      'permanentAddress': permanentAddress,
      'country': country,
      'city': city,
      'zipCode': zipCode,
      'emergencyContactName': emergencyContactName,
      'emergencyContactRelationship': emergencyContactRelationship,
      'emergencyContactPhone': emergencyContactPhone,
      'localIdOrPassport': localIdOrPassport,
      'nationalTaxId': nationalTaxId,
      'passportPhoto': passportPhoto,
      'resume': resume,
      'degreeCertificates': degreeCertificates,
      'experienceLetters': experienceLetters,
      'preferredLanguage': preferredLanguage,
    };
  }
}
