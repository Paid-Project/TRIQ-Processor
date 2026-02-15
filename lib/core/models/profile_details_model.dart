// To parse this JSON data, do
//
//     final profileResponse = profileResponseFromJson(jsonString);

import 'dart:convert';

// Helper function to parse the full JSON string
ProfileResponse profileResponseFromJson(String str) => ProfileResponse.fromJson(json.decode(str));

// Helper function to encode the model back to a JSON string
String profileResponseToJson(ProfileResponse data) => json.encode(data.toJson());

/// This is the root class for the entire API response.
class ProfileResponse {
  Profile? profile;

  ProfileResponse({
    this.profile,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
    profile: json["profile"] == null ? null : Profile.fromJson(json["profile"]),
  );

  Map<String, dynamic> toJson() => {
    "profile": profile?.toJson(),
  };
}

/// This class represents the main "profile" object.
class Profile {
  String? id;
  User? user;
  int? v;
  String? chatLanguage;
  DateTime? createdAt;
  String? designation;
  String? organizationName;
  String? profileImage;
  String? unitName;
  DateTime? updatedAt;

  Profile({
    this.id,
    this.user,
    this.v,
    this.chatLanguage,
    this.createdAt,
    this.designation,
    this.organizationName,
    this.profileImage,
    this.unitName,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json["_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    v: json["__v"],
    chatLanguage: json["chatLanguage"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    designation: json["designation"],
    organizationName: json["organizationName"],
    profileImage: json["profileImage"],
    unitName: json["unitName"],
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user?.toJson(),
    "__v": v,
    "chatLanguage": chatLanguage,
    "createdAt": createdAt?.toIso8601String(),
    "designation": designation,
    "organizationName": organizationName,
    "profileImage": profileImage,
    "unitName": unitName,
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// This class represents the nested "user" object.
class User {
  dynamic resetPasswordOtp;
  dynamic resetPasswordExpires;
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
  int? v;
  bool? isOtpVerifiedForReset;
  String? fcmToken;

  User({
    this.resetPasswordOtp,
    this.resetPasswordExpires,
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
    this.v,
    this.isOtpVerifiedForReset,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    resetPasswordOtp: json["resetPasswordOTP"],
    resetPasswordExpires: json["resetPasswordExpires"],
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
    v: json["__v"],
    isOtpVerifiedForReset: json["isOtpVerifiedForReset"],
    fcmToken: json["fcmToken"],
  );

  Map<String, dynamic> toJson() => {
    "resetPasswordOTP": resetPasswordOtp,
    "resetPasswordExpires": resetPasswordExpires,
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
    "__v": v,
    "isOtpVerifiedForReset": isOtpVerifiedForReset,
    "fcmToken": fcmToken,
  };
}