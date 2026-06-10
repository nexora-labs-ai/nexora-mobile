import 'package:injectable/injectable.dart';

import '../../../../core/storage/secure_storage.dart';

/// Persists and reads auth tokens from secure storage.
abstract interface class AuthLocalDatasource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

@Injectable(as: AuthLocalDatasource)
class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  AuthLocalDatasourceImpl(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  @override
  Future<String?> getAccessToken() => _secureStorage.getAccessToken();

  @override
  Future<String?> getRefreshToken() => _secureStorage.getRefreshToken();

  @override
  Future<void> clearTokens() => _secureStorage.clearTokens();
}
