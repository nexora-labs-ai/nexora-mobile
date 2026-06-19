import 'package:json_annotation/json_annotation.dart';

part 'auth_token_model.g.dart';

@JsonSerializable()
class AuthTokenModel {
  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    // Handle backend returning expiresIn instead of expiresAt
    if (json.containsKey('expiresIn') && !json.containsKey('expiresAt')) {
      final expiresIn = json['expiresIn'] as int;
      json['expiresAt'] = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();
    }
    return _$AuthTokenModelFromJson(json);
  }

  final String accessToken;
  final String refreshToken;
  final String expiresAt;

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);
}
