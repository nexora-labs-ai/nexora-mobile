import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../logger/app_logger.dart';
import '../network/api_endpoints.dart';
import '../storage/secure_storage.dart';

/// Automatically attaches [Authorization] headers to every request and
/// refreshes the access token on 401 responses without the caller knowing.
@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage, this._dio);

  final SecureStorage _secureStorage;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return handler.next(err);

      AppLogger.info('Access token expired – attempting refresh');

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String?;

      await _secureStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.saveRefreshToken(newRefreshToken);
      }

      // Retry original request with new token
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retried = await _dio.fetch(err.requestOptions);
      return handler.resolve(retried);
    } catch (_) {
      await _secureStorage.clearTokens();
      return handler.next(err);
    }
  }
}
