import 'package:json_annotation/json_annotation.dart';

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
    this.username,
    this.displayName,
    this.avatarUrl,
    this.phoneNumber,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract fields from nested 'profile' object if it exists
    if (json.containsKey('profile') && json['profile'] is Map) {
      final profile = json['profile'] as Map<String, dynamic>;
      json['displayName'] = profile['displayName'];
      json['avatarUrl'] = profile['avatarUrl'];
      json['phoneNumber'] = profile['phone'];
      json['bio'] = profile['bio'];
    }
    return _$UserModelFromJson(json);
  }

  final String id;
  final String email;
  final String role;
  final String status;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? bio;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
