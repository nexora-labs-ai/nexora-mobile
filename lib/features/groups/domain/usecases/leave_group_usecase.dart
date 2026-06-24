import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/group_repository.dart';

@injectable
class LeaveGroupUseCase {
  final GroupRepository _repository;

  LeaveGroupUseCase(this._repository);

  Future<Either<Failure, void>> call(String groupId) async {
    return _repository.leaveGroup(groupId);
  }
}
