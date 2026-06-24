import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/group_repository.dart';

class KickMemberParams {
  final String groupId;
  final String userId;

  KickMemberParams({
    required this.groupId,
    required this.userId,
  });
}

@injectable
class KickMemberUseCase {
  final GroupRepository _repository;

  KickMemberUseCase(this._repository);

  Future<Either<Failure, void>> call(KickMemberParams params) async {
    return _repository.removeMember(
      groupId: params.groupId,
      userId: params.userId,
    );
  }
}
