import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/group_repository.dart';

class InviteMemberParams {
  const InviteMemberParams({required this.groupId, required this.email});
  final String groupId;
  final String email;
}

@injectable
class InviteMemberUseCase implements UseCase<void, InviteMemberParams> {
  const InviteMemberUseCase(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, void>> call(InviteMemberParams params) {
    return _repository.inviteMember(
      groupId: params.groupId,
      email: params.email,
    );
  }
}
