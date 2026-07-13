import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/data/mappers/auth_mapper.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> data) async {
    try {
      final model = await _remoteDataSource.updateProfile(data);
      return Right(AuthMapper.toUserEntity(model));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? 'Failed to update profile',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> uploadAvatar(File file) async {
    try {
      final model = await _remoteDataSource.uploadAvatar(file);
      return Right(AuthMapper.toUserEntity(model));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? 'Failed to upload avatar',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
