import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'user.dart';

part 'saved_account.g.dart';

@HiveType(typeId: 2) // Make sure this typeId doesn't conflict with existing ones
class SavedAccount extends Equatable {
  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final DateTime lastLogin;

  const SavedAccount({
    required this.email,
    required this.name,
    required this.lastLogin,
  });

  @override
  List<Object?> get props => [email, name, lastLogin];

  SavedAccount copyWith({
    String? email,
    String? name,
    String? logoUrl,
    String? organizationName,
    DateTime? lastLogin,
  }) {
    return SavedAccount(
      email: email ?? this.email,
      name: name ?? this.name,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'lastLogin': lastLogin.toIso8601String(),
  };

  factory SavedAccount.fromJson(Map<String, dynamic> json) {
    return SavedAccount(
      email: json['email'] as String,
      name: json['name'] as String,
      lastLogin: DateTime.parse(json['lastLogin'] as String),
    );
  }

  factory SavedAccount.fromUser(User user) {
    return SavedAccount(
      email: user.email ?? '',
      name: user.name ?? user.fullName ?? '',
      lastLogin: DateTime.now(),
    );
  }
}