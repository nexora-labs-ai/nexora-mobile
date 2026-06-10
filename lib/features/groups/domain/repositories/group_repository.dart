import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../entities/group_entity.dart';

abstract interface class GroupRepository {
  Future<Either<Failure, List<GroupEntity>>> getGroups();

  Future<Either<Failure, GroupEntity>> getGroupById(String groupId);

  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String eventType,
    required String currency,
    String? description,
    double? targetBudget,
    DateTime? eventDateStart,
    DateTime? eventDateEnd,
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

  Future<Either<Failure, void>> removeMember({
    required String groupId,
    required String userId,
  });
}
