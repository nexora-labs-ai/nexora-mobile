import 'dart:math';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../app/bindings/injection_container.dart';
import '../logger/app_logger.dart';
import '../network/dio_client.dart';

/// Retries idempotent requests up to [maxRetries] times using
/// exponential back-off with jitter.
@injectable
class RetryInterceptor extends Interceptor {
  RetryInterceptor();

  final int maxRetries = 3;

  static const _retryCountKey = '_retryCount';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final method = options.method.toUpperCase();

    // Only retry safe/idempotent methods
    if (!{'GET', 'HEAD', 'PUT', 'DELETE'}.contains(method)) {
      return handler.next(err);
    }

    // Only retry on network/timeout errors, not 4xx
    final shouldRetry = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (!shouldRetry) return handler.next(err);

    final retryCount = (options.extra[_retryCountKey] as int?) ?? 0;
    if (retryCount >= maxRetries) return handler.next(err);

    options.extra[_retryCountKey] = retryCount + 1;

    final delay = _backoffDelay(retryCount);
    AppLogger.warning(
        'Retrying request (${retryCount + 1}/$maxRetries) in ${delay.inMilliseconds}ms');
    await Future.delayed(delay);

    try {
      final dio = sl<DioClient>().dio;
      final response = await dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Duration _backoffDelay(int retryCount) {
    final jitter = Random().nextInt(300);
    return Duration(milliseconds: (200 * pow(2, retryCount)).toInt() + jitter);
  }
}
