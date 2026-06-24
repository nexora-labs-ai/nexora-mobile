import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../shared/enums/app_enums.dart';
import '../entities/group_entity.dart';

abstract interface class GroupRepository {
  Future<Either<Failure, List<GroupEntity>>> getGroups();

  Future<Either<Failure, GroupEntity>> getGroupById(String groupId);

  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String currency,
    String? description,
  });

  Future<Either<Failure, GroupEntity>> updateGroup({
    required String groupId,
    required Map<String, dynamic> fields,
  });

  Future<Either<Failure, void>> deleteGroup(String groupId);

  Future<Either<Failure, List<GroupMemberEntity>>> getGroupMembers(String groupId);

  Future<Either<Failure, void>> inviteMember({
    required String groupId,
    required String email,
  });

  Future<Either<Failure, void>> acceptInvitation(String token);

  Future<Either<Failure, void>> rejectInvitation(String token);

  Future<Either<Failure, void>> removeMember({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, void>> leaveGroup(String groupId);

  Future<Either<Failure, void>> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupRole role,
  });
}
