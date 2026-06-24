import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../shared/enums/app_enums.dart';
import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';

@Injectable(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  const GroupRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Either<Failure, List<GroupEntity>>> getGroups() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.groups);
      final raw = response.data;
      final items = switch (raw) {
        {'data': final List<dynamic> data} => data,
        List<dynamic> data => data,
        _ => const <dynamic>[],
      };
      final groups =
          items.whereType<Map<String, dynamic>>().map(_toEntity).toList();
      return Right(groups);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroupById(String groupId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiEndpoints.groupById(groupId));
      return Right(_toEntity(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String currency,
    String? description,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.groups,
        data: {
          'name': name,
          'currency': currency,
          if (description != null) 'description': description,
        },
      );
      return Right(_toEntity(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> updateGroup({
    required String groupId,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final response = await _dioClient.dio
          .patch(ApiEndpoints.groupById(groupId), data: fields);
      return Right(_toEntity(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) async {
    try {
      await _dioClient.dio.delete(ApiEndpoints.groupById(groupId));
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupMemberEntity>>> getGroupMembers(
      String groupId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiEndpoints.groupMembers(groupId));
      final raw = response.data;
      final items = switch (raw) {
        {'data': final List<dynamic> data} => data,
        List<dynamic> data => data,
        _ => const <dynamic>[],
      };
      return Right(items.map(_toMemberEntity).toList());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> inviteMember({
    required String groupId,
    required String email,
  }) async {
    try {
      await _dioClient.dio
          .post(ApiEndpoints.groupInvite(groupId), data: {'email': email});
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptInvitation(String token) async {
    try {
      await _dioClient.dio.post(ApiEndpoints.groupInviteAccept(token));
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectInvitation(String token) async {
    try {
      await _dioClient.dio.post(ApiEndpoints.groupInviteReject(token));
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _dioClient.dio
          .delete('${ApiEndpoints.groupMembers(groupId)}/$userId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  GroupEntity _toEntity(Map<String, dynamic> data) {
    return GroupEntity(
      id: data['id'] as String,
      name: data['name'] as String,
      currency: data['currency'] as String? ?? 'USD',
      createdBy: '', // Not provided in backend list API directly
      createdAt: DateTime.parse(data['createdAt'] as String? ?? data['created_at'] as String),
      memberCount: (data['_count'] as Map<String, dynamic>?)?['members'] as int? ?? 1,
      description: data['description'] as String?,
      avatarUrl: data['avatarUrl'] as String? ?? data['avatar_url'] as String?,
      isActive: data['isActive'] as bool? ?? data['is_active'] as bool? ?? true,
    );
  }

  GroupMemberEntity _toMemberEntity(dynamic data) {
    final m = data as Map<String, dynamic>;
    return GroupMemberEntity(
      id: m['id'] as String,
      groupId: m['groupId'] as String? ?? m['group_id'] as String,
      userId: m['userId'] as String? ?? m['user_id'] as String,
      role: m['role'] == 'OWNER' ? GroupRole.owner : GroupRole.member,
      joinedAt: DateTime.parse(m['joinedAt'] as String? ?? m['joined_at'] as String),
      displayName: m['user']?['profile']?['displayName'] as String? ?? 'User',
      avatarUrl: m['user']?['profile']?['avatarUrl'] as String?,
    );
  }
}
