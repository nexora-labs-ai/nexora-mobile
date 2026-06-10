import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../environment/app_env.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/retry_interceptor.dart';

/// Pre-configured [Dio] instance registered as a singleton in the DI container.
///
/// Capabilities:
/// - Base URL from [AppEnv]
/// - Connect / receive / send timeouts
/// - Auth header injection with automatic token refresh
/// - Request retry with exponential back-off
/// - Structured request/response logging
@singleton
class DioClient {
  DioClient(
    this._authInterceptor,
    this._retryInterceptor,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.instance.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client': 'nexora-mobile',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor,
      _retryInterceptor,
      LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;
  final AuthInterceptor _authInterceptor;
  final RetryInterceptor _retryInterceptor;

  Dio get dio => _dio;
}
