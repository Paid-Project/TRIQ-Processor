// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      email: fields[5] as String?,
      token: fields[1] as String?,
      name: fields[3] as String?,
      organizationId: fields[6] as String?,
      organizationName: fields[4] as String?,
      id: fields[2] as String?,
      userType: fields[7] as UserType?,
      organizationType: fields[8] as OrganizationType?,
      userRole: fields[9] as UserRole?,
      phone: fields[10] as String?,
      logoUrl: fields[12] as String?,
      fcmToken: fields[13] as String?,
      industry: fields[14] as String?,
      language: fields[15] as String?,
      address: fields[16] as Address?,
      yourName: fields[17] as String?,
      designation: fields[18] as String?,
      fullName: fields[19] as String?,
      isEmailVerified: fields[20] as bool?,
      isPhoneVerified: fields[21] as bool?,
      countryCode: fields[22] as String?,
      roles: (fields[23] as List?)?.cast<Role>(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(22)
      ..writeByte(1)
      ..write(obj.token)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.organizationName)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.organizationId)
      ..writeByte(7)
      ..write(obj.userType)
      ..writeByte(8)
      ..write(obj.organizationType)
      ..writeByte(9)
      ..write(obj.userRole)
      ..writeByte(10)
      ..write(obj.phone)
      ..writeByte(12)
      ..write(obj.logoUrl)
      ..writeByte(13)
      ..write(obj.fcmToken)
      ..writeByte(14)
      ..write(obj.industry)
      ..writeByte(15)
      ..write(obj.language)
      ..writeByte(16)
      ..write(obj.address)
      ..writeByte(17)
      ..write(obj.yourName)
      ..writeByte(18)
      ..write(obj.designation)
      ..writeByte(19)
      ..write(obj.fullName)
      ..writeByte(20)
      ..write(obj.isEmailVerified)
      ..writeByte(21)
      ..write(obj.isPhoneVerified)
      ..writeByte(22)
      ..write(obj.countryCode)
      ..writeByte(23)
      ..write(obj.roles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoleAdapter extends TypeAdapter<Role> {
  @override
  final int typeId = 11;

  @override
  Role read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Role(
      id: fields[1] as String?,
      name: fields[2] as String?,
      version: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Role obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 10;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      addressLine1: fields[1] as String?,
      addressLine2: fields[2] as String?,
      city: fields[3] as String?,
      state: fields[4] as String?,
      country: fields[5] as String?,
      pinCode: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.addressLine1)
      ..writeByte(2)
      ..write(obj.addressLine2)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.country)
      ..writeByte(6)
      ..write(obj.pinCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserTypeAdapter extends TypeAdapter<UserType> {
  @override
  final int typeId = 12;

  @override
  UserType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserType.employee;
      case 1:
        return UserType.organization;
      default:
        return UserType.employee;
    }
  }

  @override
  void write(BinaryWriter writer, UserType obj) {
    switch (obj) {
      case UserType.employee:
        writer.writeByte(0);
        break;
      case UserType.organization:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrganizationTypeAdapter extends TypeAdapter<OrganizationType> {
  @override
  final int typeId = 13;

  @override
  OrganizationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrganizationType.processor;
      case 1:
        return OrganizationType.manufacturer;
      default:
        return OrganizationType.processor;
    }
  }

  @override
  void write(BinaryWriter writer, OrganizationType obj) {
    switch (obj) {
      case OrganizationType.processor:
        writer.writeByte(0);
        break;
      case OrganizationType.manufacturer:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 14;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.superAdmin;
      case 1:
        return UserRole.organization;
      case 2:
        return UserRole.processor;
      case 3:
        return UserRole.plantHead;
      case 4:
        return UserRole.lineInCharge;
      case 5:
        return UserRole.maintenanceHead;
      case 6:
        return UserRole.maintenanceEngineer;
      case 7:
        return UserRole.machineOperator;
      case 8:
        return UserRole.labour;
      case 9:
        return UserRole.headOfGlobalService;
      case 10:
        return UserRole.countryServiceManager;
      case 11:
        return UserRole.localServiceEngineers;
      case 12:
        return UserRole.installationEngineers;
      default:
        return UserRole.superAdmin;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.superAdmin:
        writer.writeByte(0);
        break;
      case UserRole.organization:
        writer.writeByte(1);
        break;
      case UserRole.processor:
        writer.writeByte(2);
        break;
      case UserRole.plantHead:
        writer.writeByte(3);
        break;
      case UserRole.lineInCharge:
        writer.writeByte(4);
        break;
      case UserRole.maintenanceHead:
        writer.writeByte(5);
        break;
      case UserRole.maintenanceEngineer:
        writer.writeByte(6);
        break;
      case UserRole.machineOperator:
        writer.writeByte(7);
        break;
      case UserRole.labour:
        writer.writeByte(8);
        break;
      case UserRole.headOfGlobalService:
        writer.writeByte(9);
        break;
      case UserRole.countryServiceManager:
        writer.writeByte(10);
        break;
      case UserRole.localServiceEngineers:
        writer.writeByte(11);
        break;
      case UserRole.installationEngineers:
        writer.writeByte(12);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
