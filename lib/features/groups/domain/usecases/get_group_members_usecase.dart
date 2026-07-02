import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

@injectable
class GetGroupMembersUseCase
    implements UseCase<List<GroupMemberEntity>, String> {
  const GetGroupMembersUseCase(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, List<GroupMemberEntity>>> call(String groupId) =>
      _repository.getGroupMembers(groupId);
}
