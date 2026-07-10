import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/enums/app_enums.dart';
import '../repositories/group_repository.dart';

class UpdateMemberRoleParams {
  final String groupId;
  final String userId;
  final GroupRole role;

  UpdateMemberRoleParams({
    required this.groupId,
    required this.userId,
    required this.role,
  });
}

@injectable
class UpdateMemberRoleUseCase {
  final GroupRepository _repository;

  UpdateMemberRoleUseCase(this._repository);

  Future<Either<Failure, void>> call(UpdateMemberRoleParams params) async {
    return _repository.updateMemberRole(
      groupId: params.groupId,
      userId: params.userId,
      role: params.role,
    );
  }
}
