import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
///
/// Failures are typed, serialisable error representations used as the
/// Left side of [Either] in use cases and repositories.
///
/// Never throw exceptions across layer boundaries – return [Failure] instead.
sealed class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

// ─── Network Failures ──────────────────────────────────────────────────────────

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out', super.code});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized. Please log in again.', super.code});
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'You do not have permission.', super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found.', super.code});
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

final class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, super.code});
}

// ─── Cache / Storage Failures ─────────────────────────────────────────────────

final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

// ─── Validation Failures ──────────────────────────────────────────────────────

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.fieldErrors = const {}, super.code});

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

// ─── Auth Failures ────────────────────────────────────────────────────────────

final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

final class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure({super.message = 'Session expired. Please log in again.', super.code});
}

// ─── Unknown ──────────────────────────────────────────────────────────────────

final class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred.', super.code});
}
