/// Data-layer exceptions.
///
/// Thrown inside datasources, caught by repository implementations, and
/// converted to domain [Failure] objects before crossing layer boundaries.
library;

// ─── Network ─────────────────────────────────────────────────────────────────

class NetworkException implements Exception {
  const NetworkException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
}

class TimeoutException implements Exception {
  const TimeoutException();
}

class UnauthorizedException implements Exception {
  const UnauthorizedException({this.message = 'Unauthorized'});
  final String message;
}

class ForbiddenException implements Exception {
  const ForbiddenException({this.message = 'Forbidden'});
  final String message;
}

class NotFoundException implements Exception {
  const NotFoundException({this.message = 'Not found'});
  final String message;
}

class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
}

class ConflictException implements Exception {
  const ConflictException({required this.message});
  final String message;
}

// ─── Cache / Storage ─────────────────────────────────────────────────────────

class CacheException implements Exception {
  const CacheException({required this.message});
  final String message;
}

// ─── Auth ─────────────────────────────────────────────────────────────────────

class TokenExpiredException implements Exception {
  const TokenExpiredException();
}
