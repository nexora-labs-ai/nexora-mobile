import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

@injectable
class UpdateGroupUseCase implements UseCase<GroupEntity, UpdateGroupParams> {
  const UpdateGroupUseCase(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, GroupEntity>> call(UpdateGroupParams params) {
    return _repository.updateGroup(
      groupId: params.groupId,
      fields: params.fields,
    );
  }
}

class UpdateGroupParams extends Equatable {
  const UpdateGroupParams({
    required this.groupId,
    required this.fields,
  });

  final String groupId;
  final Map<String, dynamic> fields;

  @override
  List<Object?> get props => [groupId, fields];
}
