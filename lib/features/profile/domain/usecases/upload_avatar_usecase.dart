import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UploadAvatarUseCase implements UseCase<UserEntity, File> {
  UploadAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(File params) async {
    return _repository.uploadAvatar(params);
  }
}
