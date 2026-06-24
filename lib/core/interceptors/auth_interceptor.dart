import 'dart:async';
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

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Don't attach token to refresh endpoint
    if (options.path != ApiEndpoints.refreshToken) {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
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

    // If the refresh token request itself failed with 401, don't try to refresh again
    if (err.requestOptions.path == ApiEndpoints.refreshToken) {
      await _secureStorage.clearTokens();
      return handler.next(err);
    }

    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return handler.next(err);

    if (_isRefreshing) {
      // Wait for the ongoing refresh to complete
      final newAccessToken = await _refreshCompleter?.future;
      if (newAccessToken != null) {
        // Retry original request with the new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final retried = await _dio.fetch(err.requestOptions);
          return handler.resolve(retried);
        } catch (_) {
          return handler.next(err);
        }
      } else {
        // Refresh failed, pass the error
        return handler.next(err);
      }
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
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

      _isRefreshing = false;
      _refreshCompleter?.complete(newAccessToken);

      // Retry original request with new token
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retried = await _dio.fetch(err.requestOptions);
      return handler.resolve(retried);
    } catch (_) {
      _isRefreshing = false;
      if (!(_refreshCompleter?.isCompleted ?? true)) {
        _refreshCompleter?.complete(null);
      }
      await _secureStorage.clearTokens();
      return handler.next(err);
    }
  }
}
