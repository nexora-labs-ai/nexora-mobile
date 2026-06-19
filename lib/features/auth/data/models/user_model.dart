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
    required this.role,
    required this.status,
    this.displayName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract fields from nested 'profile' object if it exists
    if (json.containsKey('profile') && json['profile'] is Map) {
      final profile = json['profile'] as Map<String, dynamic>;
      json['displayName'] = profile['displayName'];
      json['avatarUrl'] = profile['avatarUrl'];
      json['phoneNumber'] = profile['phone'];
    }
    return _$UserModelFromJson(json);
  }

  final String id;
  final String email;
  final String role;
  final String status;
  final String? displayName;
  final String? avatarUrl;
  final String? phoneNumber;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
