import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../entities/auth_token_entity.dart';
import '../entities/user_entity.dart';

/// Contract defining all authentication operations.
///
/// Implementation lives in the data layer – domain never knows the details.
abstract interface class AuthRepository {
  Future<Either<Failure, AuthTokenEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, AuthTokenEntity>> refreshToken(String refreshToken);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword(String email);
}
