import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the domain layer.
///
/// Immutable. No JSON, no Flutter, no Dio.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.systemRole,
    required this.status,
    this.username,
    this.avatarUrl,
    this.phoneNumber,
    this.bio,
  });

  final String id;
  final String email;
  final String displayName;
  final UserSystemRole systemRole;
  final UserStatus status;
  final String? username;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? bio;

  bool get isAdmin => systemRole == UserSystemRole.admin;
  bool get isActive => status == UserStatus.active;

  @override
  List<Object?> get props =>
      [id, email, displayName, systemRole, status, username, avatarUrl, phoneNumber, bio];
}

enum UserSystemRole { user, admin }

enum UserStatus { active, inactive, banned }
