import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Calls auth-related REST endpoints.
///
/// Returns raw [Model] objects only – no mapping, no business logic.
abstract interface class AuthRemoteDatasource {
  Future<AuthTokenModel> login({required String email, required String password});
  Future<AuthTokenModel> loginWithGoogle(String idToken);
  Future<AuthTokenModel> register({required String email, required String password, required String displayName});
  Future<UserModel> getCurrentUser();
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<void> logout();
  Future<void> forgotPassword(String email);
}

@Injectable(as: AuthRemoteDatasource)
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<AuthTokenModel> login({required String email, required String password}) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokenModel> register({required String email, required String password, required String displayName}) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'displayName': displayName},
    );
    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokenModel> loginWithGoogle(String idToken) async {
    final response = await _dioClient.dio.post(
      '/auth/google/token',
      data: {'idToken': idToken},
    );
    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() => _dioClient.dio.post(ApiEndpoints.logout);

  @override
  Future<void> forgotPassword(String email) => _dioClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
}
