import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';

/// Coordinates [AuthRemoteDatasource] + [AuthLocalDatasource].
///
/// Catches exceptions from the data sources and converts them to [Failure].
/// Returns [Either<Failure, T>] – never throws across layer boundaries.
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  @override
  Future<Either<Failure, AuthTokenEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(email: email, password: password);
      final entity = AuthMapper.toTokenEntity(model);

      await _local.saveTokens(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
      );

      return Right(entity);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> loginWithGoogle(String idToken) async {
    try {
      final model = await _remote.loginWithGoogle(idToken);
      final entity = AuthMapper.toTokenEntity(model);

      await _local.saveTokens(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
      );

      return Right(entity);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final model = await _remote.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      final entity = AuthMapper.toTokenEntity(model);

      await _local.saveTokens(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
      );

      return Right(entity);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final model = await _remote.getCurrentUser();
      return Right(AuthMapper.toUserEntity(model));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> refreshToken(String refreshToken) async {
    try {
      final model = await _remote.refreshToken(refreshToken);
      final entity = AuthMapper.toTokenEntity(model);
      await _local.saveTokens(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
      );
      return Right(entity);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
      await _local.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remote.forgotPassword(email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
