// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

/// This is the ROOT class for the response.
/// It contains the 'profile' object and the 'qrCode'.
class ProfileModel {
  Profile? profile;
  String? qrCode;
  String? message;
  int? completionPercentage;

  ProfileModel({
    this.profile,
    this.qrCode,
    this.message,
    this.completionPercentage,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    profile: json["profile"] == null ? null : Profile.fromJson(json["profile"]),
    qrCode: json["qrCode"],
    message: json["message"],
    completionPercentage: json["completionPercentage"]??0,
  );

  Map<String, dynamic> toJson() => {
    "profile": profile?.toJson(),
    "qrCode": qrCode,
    "message": message,
    "completionPercentage": completionPercentage,
  };
}

/// This class represents the nested 'profile' object.
class Profile {
  bool? autoChatLanguage;
  String? id;
  User? user;
  String? unitName; // <-- REMOVED
  String? designation; // <-- REMOVED
  String? organizationName; // <-- REMOVED
  Address? corporateAddress; // <-- ADDED BACK
  Address? factoryAddress; // <-- ADDED BACK
  String? profileImage;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isSameAddress;
  int? v;
  String? chatLanguage;
  String? message;

  Profile({
    this.autoChatLanguage,
    this.id,
    this.user,
    this.unitName, // <-- REMOVED
    this.designation, // <-- REMOVED
    this.organizationName, // <-- REMOVED
    this.corporateAddress, // <-- ADDED BACK
    this.factoryAddress, // <-- ADDED BACK
    this.profileImage,
    this.createdAt,
    this.updatedAt,
    this.isSameAddress,
    this.v,
    this.chatLanguage,
    this.message,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    autoChatLanguage: json['AutoChatLanguage'],
    id: json["_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    unitName: json["unitName"], // <-- REMOVED
    designation: json["designation"], // <-- REMOVED
    organizationName: json["organizationName"], // <-- REMOVED
    corporateAddress: json["corporateAddress"] == null ? null : Address.fromJson(json["corporateAddress"]), // <-- ADDED BACK
    factoryAddress: json["factoryAddress"] == null ? null : Address.fromJson(json["factoryAddress"]), // <-- ADDED BACK
    profileImage: json["profileImage"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    isSameAddress: json["isSameAddress"],
    v: json["__v"],
    chatLanguage: json["chatLanguage"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "AutoChatLanguage":autoChatLanguage,
    "_id": id,
    "user": user?.toJson(),
    "unitName": unitName, // <-- REMOVED
    "designation": designation, // <-- REMOVED
    "organizationName": organizationName, // <-- REMOVED
    "corporateAddress": corporateAddress?.toJson(), // <-- ADDED BACK
    "factoryAddress": factoryAddress?.toJson(), // <-- ADDED BACK
    "profileImage": profileImage,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "isSameAddress":isSameAddress,
    "__v": v,
    "chatLanguage": chatLanguage,
    "message": message,
  };
}

/// --- ADDED BACK ---
/// This class handles the corporateAddress and factoryAddress objects.
class Address {
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? id;

  Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.id,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
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


/// This class represents the nested 'user' object.
class User {
  String? id;
  String? fullName;
  String? email;
  String? password;
  String? phone;
  String? countryCode;
  List<String>? roles;
  String? emailOtp;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  dynamic resetPasswordOtp;
  dynamic resetPasswordExpires;
  bool? isOtpVerifiedForReset;
  int? v;
  String? fcmToken;
  String? processorType; // <-- ADDED

  User({
    this.id,
    this.fullName,
    this.email,
    this.password,
    this.phone,
    this.countryCode,
    this.roles,
    this.emailOtp,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.resetPasswordOtp,
    this.resetPasswordExpires,
    this.isOtpVerifiedForReset,
    this.v,
    this.fcmToken,
    this.processorType, // <-- ADDED
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
    password: json["password"],
    phone: json["phone"],
    countryCode: json["countryCode"],
    roles: json["roles"] == null ? [] : List<String>.from(json["roles"]!.map((x) => x)),
    emailOtp: json["emailOTP"],
    isEmailVerified: json["isEmailVerified"],
    isPhoneVerified: json["isPhoneVerified"],
    resetPasswordOtp: json["resetPasswordOTP"],
    resetPasswordExpires: json["resetPasswordExpires"],
    isOtpVerifiedForReset: json["isOtpVerifiedForReset"],
    v: json["__v"],
    fcmToken: json["fcmToken"],
    processorType: json["processorType"], // <-- ADDED
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
    "password": password,
    "phone": phone,
    "countryCode": countryCode,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "emailOTP": emailOtp,
    "isEmailVerified": isEmailVerified,
    "isPhoneVerified": isPhoneVerified,
    "resetPasswordOTP": resetPasswordOtp,
    "resetPasswordExpires": resetPasswordExpires,
    "isOtpVerifiedForReset": isOtpVerifiedForReset,
    "__v": v,
    "fcmToken": fcmToken,
    "processorType": processorType, // <-- ADDED
  };
}