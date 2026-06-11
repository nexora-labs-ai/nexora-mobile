import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// Utility to convert [DioException] into typed [Failure] objects.
///
/// Call from repository catch blocks:
/// ```dart
/// } on DioException catch (e) {
///   return Left(DioErrorMapper.toFailure(e));
/// }
/// ```
abstract final class DioErrorMapper {
  static Failure toFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'No internet connection. Please check your network.');

      case DioExceptionType.badResponse:
        return _fromStatusCode(e);

      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request cancelled.');

      default:
        return UnknownFailure(message: e.message ?? 'Unknown network error');
    }
  }

  static Failure _fromStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = _extractMessage(e) ?? 'Server error';

    return switch (statusCode) {
      400 => ValidationFailure(message: message),
      401 => const UnauthorizedFailure(),
      403 => const ForbiddenFailure(),
      404 => NotFoundFailure(message: message),
      409 => ConflictFailure(message: message),
      int code when code >= 500 => ServerFailure(message: message, code: code.toString()),
      _ => ServerFailure(message: message),
    };
  }

  static String? _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) return data['message'] as String?;
      return null;
    } catch (_) {
      return null;
    }
  }
}
