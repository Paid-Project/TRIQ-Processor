import 'package:equatable/equatable.dart';

class Organization extends Equatable {
  final String? id;
  final String? name;
  final String? yourName;
  final String? designation;
  final String? logo;
  final String? phone;
  final String? phone2;
  final String? email;
  final String? email2;
  final Address? address;
  final List<Units>? units; // Changed from Units? to List<Unit>?
  final Address? factoryAddress;
  final int? establishedYear;
  final String? description;
  final String? preferredLanguage;

  const Organization({
    this.id,
    this.name,
    this.yourName,
    this.designation,
    this.logo,
    this.phone,
    this.phone2,
    this.email,
    this.email2,
    this.address,
    this.factoryAddress,
    this.establishedYear,
    this.description,
    this.preferredLanguage,
    this.units
  });

  @override
  List<Object?> get props => [
    id,
    name,
    yourName,
    designation,
    logo,
    phone,
    phone2,
    email,
    email2,
    address,
    factoryAddress,
    establishedYear,
    description,
    preferredLanguage,
    units
  ];

  Organization copyWith({
    String? id,
    String? name,
    String? yourName,
    String? designation,
    String? logo,
    String? phone,
    String? phone2,
    String? email,
    String? email2,
    Address? address,
    Address? factoryAddress,
    int? establishedYear,
    String? description,
    String? preferredLanguage,
    List<Units>? units // Changed from Units? to List<Unit>?
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      yourName: yourName ?? this.yourName,
      designation: designation ?? this.designation,
      logo: logo ?? this.logo,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      email: email ?? this.email,
      email2: email2 ?? this.email2,
      address: address ?? this.address,
      factoryAddress: factoryAddress ?? this.factoryAddress,
      establishedYear: establishedYear ?? this.establishedYear,
      description: description ?? this.description,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      units: units ?? this.units,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'yourName': yourName,
      'designation': designation,
      'logo': logo,
      'phone': phone,
      'phone2': phone2,
      'email': email,
      'email2': email2,
      'address': address?.toJson(),
      'factoryAddress': factoryAddress?.toJson(),
      'establishedYear': establishedYear,
      'description': description,
      'preferredLanguage': preferredLanguage,
      'units': units?.map((unit) => unit.toJson()).toList()
    };
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      yourName: json['yourName'],
      designation: json['designation'],
      logo: json['logo'],
      phone: json['phone'],
      phone2: json['phone2'],
      email: json['email'],
      email2: json['email2'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      factoryAddress: json['factoryAddress'] != null
          ? Address.fromJson(json['factoryAddress'])
          : null,
      establishedYear: json['establishedYear'],
      description: json['description'],
      preferredLanguage: json['preferredLanguage'],
      units: json['units'] != null
          ? (json['units'] as List).map((unit) => Units.fromJson(unit)).toList()
          : null,
    );
  }

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, email: $email)';
  }
}

class Address extends Equatable {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
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

  Address copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? pinCode,
  }) {
    return Address(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pinCode: pinCode ?? this.pinCode,
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

  @override
  String toString() {
    return 'Address(addressLine1: $addressLine1, city: $city, state: $state, country: $country)';
  }
}




class Units extends Equatable {
  final String? id;
  final String? name;
  final String? country;
  final String? locality;

  const Units({
    this.id,
    this.name,
    this.country,
    this.locality,
  });

  factory Units.fromJson(Map<String, dynamic> json) {
    return Units(
      id: json['_id'] is Map ? json['_id']['\$oid'] ?? json['_id'].toString() : json['_id']?.toString(),
      name: json['name'],
      country: json['country'],
      locality: json['locality'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'country': country,
      'locality': locality,
    };
  }

  @override
  List<Object?> get props => [id, name, country, locality];

  Units copyWith({
    String? id,
    String? name,
    String? country,
    String? locality,
  }) {
    return Units(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      locality: locality ?? this.locality,
    );
  }
}