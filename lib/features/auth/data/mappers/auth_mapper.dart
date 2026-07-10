import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Converts between [AuthTokenModel] ↔ [AuthTokenEntity]
/// and [UserModel] ↔ [UserEntity].
///
/// Keeps mapping logic isolated from both domain and data classes.
abstract final class AuthMapper {
  static AuthTokenEntity toTokenEntity(AuthTokenModel model) {
    return AuthTokenEntity(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      expiresAt: DateTime.parse(model.expiresAt),
    );
  }

  static UserEntity toUserEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      displayName: model.displayName ?? model.email.split('@').first,
      systemRole: _mapSystemRole(model.role),
      status: _mapStatus(model.status),
      avatarUrl: model.avatarUrl,
      phoneNumber: model.phoneNumber,
    );
  }

  static UserSystemRole _mapSystemRole(String raw) =>
      switch (raw.toUpperCase()) {
        'ADMIN' => UserSystemRole.admin,
        _ => UserSystemRole.user,
      };

  static UserStatus _mapStatus(String raw) => switch (raw.toUpperCase()) {
        'INACTIVE' => UserStatus.inactive,
        'BANNED' => UserStatus.banned,
        _ => UserStatus.active,
      };
}
