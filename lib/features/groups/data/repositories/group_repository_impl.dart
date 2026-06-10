import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../../../../../shared/enums/app_enums.dart';

@Injectable(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  const GroupRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Either<Failure, List<GroupEntity>>> getGroups() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.groups);
      final items = response.data['data'] as List;
      return Right(items.map(_toEntity).toList());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroupById(String groupId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.groupById(groupId));
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
    required String eventType,
    required String currency,
    String? description,
    double? targetBudget,
    DateTime? eventDateStart,
    DateTime? eventDateEnd,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.groups,
        data: {
          'name': name,
          'event_type': eventType,
          'currency': currency,
          if (description != null) 'description': description,
          if (targetBudget != null) 'target_budget': targetBudget,
          if (eventDateStart != null) 'event_date_start': eventDateStart.toIso8601String(),
          if (eventDateEnd != null) 'event_date_end': eventDateEnd.toIso8601String(),
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
      final response = await _dioClient.dio.patch(ApiEndpoints.groupById(groupId), data: fields);
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
  Future<Either<Failure, List<GroupMemberEntity>>> getGroupMembers(String groupId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.groupMembers(groupId));
      final items = response.data['data'] as List;
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
      await _dioClient.dio.post(ApiEndpoints.groupInvite(groupId), data: {'email': email});
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
      await _dioClient.dio.delete('${ApiEndpoints.groupMembers(groupId)}/$userId');
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
      eventType: _mapEventType(data['event_type'] as String? ?? 'OTHER'),
      currency: data['currency'] as String? ?? 'VND',
      createdBy: data['created_by'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      memberCount: data['member_count'] as int? ?? 0,
      description: data['description'] as String?,
      coverImageUrl: data['cover_image_url'] as String?,
      eventDateStart: data['event_date_start'] != null ? DateTime.parse(data['event_date_start'] as String) : null,
      eventDateEnd: data['event_date_end'] != null ? DateTime.parse(data['event_date_end'] as String) : null,
      targetBudget: (data['target_budget'] as num?)?.toDouble(),
      fundBalance: (data['fund_balance'] as num?)?.toDouble() ?? 0,
    );
  }

  GroupMemberEntity _toMemberEntity(dynamic data) {
    final m = data as Map<String, dynamic>;
    return GroupMemberEntity(
      id: m['id'] as String,
      groupId: m['group_id'] as String,
      userId: m['user_id'] as String,
      role: m['group_role'] == 'OWNER' ? GroupRole.owner : GroupRole.member,
      joinedAt: DateTime.parse(m['joined_at'] as String),
      displayName: m['display_name'] as String? ?? '',
      avatarUrl: m['avatar_url'] as String?,
    );
  }

  GroupEventType _mapEventType(String raw) => switch (raw.toUpperCase()) {
        'TRIP' => GroupEventType.trip,
        'WORKSHOP' => GroupEventType.workshop,
        'PARTY' => GroupEventType.party,
        'HACKATHON' => GroupEventType.hackathon,
        _ => GroupEventType.other,
      };
}
