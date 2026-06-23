import 'package:dartz/dartz.dart';

import '../errors/failure.dart';

/// Base interface for all use cases.
///
/// [Type]   – return type on success (Right side of Either)
/// [Params] – input parameters; use [NoParams] when no input is needed.
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use cases that return a [Stream] instead of a [Future].
abstract interface class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Sentinel for use cases that require no parameters.
final class NoParams {
  const NoParams();
}
