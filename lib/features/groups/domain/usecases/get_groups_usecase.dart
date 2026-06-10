import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

@injectable
class GetGroupsUseCase implements UseCase<List<GroupEntity>, NoParams> {
  const GetGroupsUseCase(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, List<GroupEntity>>> call(NoParams params) =>
      _repository.getGroups();
}

@injectable
class GetGroupDetailUseCase implements UseCase<GroupEntity, String> {
  const GetGroupDetailUseCase(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, GroupEntity>> call(String groupId) =>
      _repository.getGroupById(groupId);
}
