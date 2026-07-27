import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../app/bindings/injection_container.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../environment/app_env.dart';
import '../logger/app_logger.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

/// Automatically attaches [Authorization] headers to every request and
/// refreshes the access token on 401 responses without the caller knowing.
@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  // Use a dedicated Dio instance for refresh token to avoid circular dependencies
  // and interceptor deadlocks.
  late final Dio _tokenDio = Dio(
    BaseOptions(
      baseUrl: AppEnv.instance.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

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
      sl<AuthCubit>().checkAuth(); // Kick user to login screen
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
        if (err.requestOptions.data is FormData) {
          return handler.next(err);
        }
        try {
          // Use the main DioClient instance to ensure the retried request
          // goes through all interceptors (like ResponseWrapper).
          final dio = sl<DioClient>().dio;
          final retried = await dio.fetch(err.requestOptions);
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

      final response = await _tokenDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final dynamic data = response.data;
      final responseData =
          data is Map<String, dynamic> && data.containsKey('data')
              ? data['data']
              : data;

      final newAccessToken = responseData['accessToken'] as String;
      final newRefreshToken = responseData['refreshToken'] as String?;

      await _secureStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.saveRefreshToken(newRefreshToken);
      }

      _isRefreshing = false;
      _refreshCompleter?.complete(newAccessToken);

      // Retry original request with new token using main DioClient
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      if (err.requestOptions.data is FormData) {
        return handler.next(err);
      }
      final dio = sl<DioClient>().dio;
      final retried = await dio.fetch(err.requestOptions);
      return handler.resolve(retried);
    } catch (e) {
      AppLogger.error('Token refresh failed: $e');
      _isRefreshing = false;
      if (!(_refreshCompleter?.isCompleted ?? true)) {
        _refreshCompleter?.complete(null);
      }
      await _secureStorage.clearTokens();
      sl<AuthCubit>().checkAuth(); // Kick user to login screen
      return handler.next(err);
    }
  }
}
