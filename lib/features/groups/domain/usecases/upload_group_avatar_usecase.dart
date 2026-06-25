import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../repositories/group_repository.dart';

@injectable
class UploadGroupAvatarUseCase implements UseCase<void, UploadGroupAvatarParams> {
  const UploadGroupAvatarUseCase(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, void>> call(UploadGroupAvatarParams params) {
    return _repository.uploadGroupAvatar(
      groupId: params.groupId,
      file: params.file,
    );
  }
}

class UploadGroupAvatarParams extends Equatable {
  const UploadGroupAvatarParams({
    required this.groupId,
    required this.file,
  });

  final String groupId;
  final File file;

  @override
  List<Object?> get props => [groupId, file];
}
