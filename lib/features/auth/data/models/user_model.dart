import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// Transport object for user data received from the API.
///
/// Handles JSON parsing only – no business logic.
@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.systemRole,
    required this.status,
    this.displayName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  final String id;
  final String email;
  @JsonKey(name: 'system_role')
  final String systemRole;
  final String status;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
