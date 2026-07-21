import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, UserEntity>> uploadAvatar(File file);
}
