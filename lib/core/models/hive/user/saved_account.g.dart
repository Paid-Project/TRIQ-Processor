// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedAccountAdapter extends TypeAdapter<SavedAccount> {
  @override
  final int typeId = 2;

  @override
  SavedAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedAccount(
      email: fields[1] as String,
      name: fields[2] as String,
      lastLogin: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedAccount obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.lastLogin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
