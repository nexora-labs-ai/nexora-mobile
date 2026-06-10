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
    this.avatarUrl,
    this.phoneNumber,
  });

  final String id;
  final String email;
  final String displayName;
  final UserSystemRole systemRole;
  final UserStatus status;
  final String? avatarUrl;
  final String? phoneNumber;

  bool get isAdmin => systemRole == UserSystemRole.admin;
  bool get isActive => status == UserStatus.active;

  @override
  List<Object?> get props => [id, email, displayName, systemRole, status, avatarUrl, phoneNumber];
}

enum UserSystemRole { user, admin }
enum UserStatus { active, inactive, banned }
