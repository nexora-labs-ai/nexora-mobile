import 'package:dio/dio.dart';

import '../logger/app_logger.dart';

/// Logs every HTTP request and response for debugging purposes.
/// Stripped in production via [AppEnv.enableLogging].
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      '→ ${options.method} ${options.uri}\n'
      '  Headers: ${_sanitizeHeaders(options.headers)}\n'
      '  Body: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      '  Body: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '✕ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '  Status: ${err.response?.statusCode}\n'
      '  Message: ${err.message}',
    );
    handler.next(err);
  }

  /// Strips Authorization header value from logs.
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '[REDACTED]';
    }
    return sanitized;
  }
}
