import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../environment/app_env.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/response_interceptor.dart';
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
        validateStatus: (status) =>
            status != null && (status >= 200 && status < 300 || status == 304),
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor,
      _retryInterceptor,
      ResponseWrapperInterceptor(),
      LoggingInterceptor(),
    ]);

    _initCacheInterceptor();
  }

  late final Dio _dio;
  final AuthInterceptor _authInterceptor;
  final RetryInterceptor _retryInterceptor;

  Future<void> _initCacheInterceptor() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheStore = HiveCacheStore(tempDir.path);

      final cacheOptions = CacheOptions(
        store: cacheStore,
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
        priority: CachePriority.normal,
        cipher: null,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      );

      _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    } catch (e) {
      // Ignore cache init error
    }
  }

  Dio get dio => _dio;
}
