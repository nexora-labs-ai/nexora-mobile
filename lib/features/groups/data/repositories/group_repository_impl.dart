import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';

import '../../../../../shared/enums/app_enums.dart';
import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_fund_entity.dart';
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
    DateTime? startDate,
    DateTime? endDate,
    double? budgetGoal,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.groups,
        data: {
          'name': name,
          'currency': currency,
          if (description != null) 'description': description,
          if (startDate != null)
            'startDate': startDate.toUtc().toIso8601String(),
          if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
          if (budgetGoal != null) 'budgetGoal': budgetGoal,
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
      // The backend /groups/:id endpoint returns the group with its members included.
      final response =
          await _dioClient.dio.get(ApiEndpoints.groupById(groupId));
      final raw = response.data;
      final items = raw['members'] as List<dynamic>? ?? <dynamic>[];
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
          .post(ApiEndpoints.groupInvite(groupId), data: {'identifier': email});
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

  @override
  Future<Either<Failure, GroupFundEntity>> contributeFund({
    required String groupId,
    required int amount,
    String? note,
    String? evidenceUrl,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.groupFundContribute(groupId),
        data: {
          'amount': amount / 100.0,
          if (note != null) 'note': note,
          if (evidenceUrl != null) 'evidenceUrl': evidenceUrl,
        },
      );
      final fundData = response.data['fund'] as Map<String, dynamic>;
      return Right(_toFundEntity(fundData));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId) async {
    try {
      await _dioClient.dio.post(ApiEndpoints.groupLeave(groupId));
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupRole role,
  }) async {
    try {
      await _dioClient.dio.patch(
        ApiEndpoints.groupMemberRole(groupId, userId),
        data: {'role': role.name.toUpperCase()},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupFundEntity>> withdrawFund({
    required String groupId,
    required int amount,
    String? note,
    String? evidenceUrl,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.groupFundWithdraw(groupId),
        data: {
          'amount': amount / 100.0,
          if (note != null) 'note': note,
          if (evidenceUrl != null) 'evidenceUrl': evidenceUrl,
        },
      );
      final fundData = response.data['fund'] as Map<String, dynamic>;
      return Right(_toFundEntity(fundData));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadGroupAvatar({
    required String groupId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      String contentType = 'image/jpeg';
      if (fileExtension == 'png') {
        contentType = 'image/png';
      } else if (fileExtension == 'webp') {
        contentType = 'image/webp';
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      });

      await _dioClient.dio.post(
        '${ApiEndpoints.groups}/$groupId/avatar',
        data: formData,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FundTransactionEntity>>> getFundTransactions(
      String groupId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiEndpoints.groupFundTransactions(groupId));
      final items = response.data as List<dynamic>? ?? [];
      return Right(items
          .map((e) => _toFundTransactionEntity(e as Map<String, dynamic>))
          .toList());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  FundTransactionEntity _toFundTransactionEntity(Map<String, dynamic> m) {
    return FundTransactionEntity(
      id: m['id'] as String,
      fundId: m['fundId'] as String,
      createdBy: m['createdBy'] as String,
      type: m['type'] as String,
      amount: toMinorUnitsFromJson(m['amount']),
      note: m['note'] as String?,
      expenseId: m['expenseId'] as String?,
      evidenceUrl: m['evidenceUrl'] as String?,
      creatorName: m['creator']?['profile']?['displayName'] as String? ??
          m['creator']?['email'] as String? ??
          'Unknown',
      createdAt: DateTime.parse(m['createdAt'] as String),
    );
  }

  GroupEntity _toEntity(Map<String, dynamic> data) {
    return GroupEntity(
      id: data['id'] as String,
      name: data['name'] as String,
      currency: data['currency'] as String? ?? 'USD',
      createdBy: '', // Not provided in backend list API directly
      createdAt: DateTime.parse(
          data['createdAt'] as String? ?? data['created_at'] as String),
      memberCount:
          (data['_count'] as Map<String, dynamic>?)?['members'] as int? ?? 1,
      description: data['description'] as String?,
      avatarUrl: data['avatarUrl'] as String? ?? data['avatar_url'] as String?,
      isActive: data['isActive'] as bool? ?? data['is_active'] as bool? ?? true,
      fund: data['fund'] != null
          ? _toFundEntity(data['fund'] as Map<String, dynamic>)
          : null,
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'] as String)
          : null,
      endDate: data['endDate'] != null
          ? DateTime.parse(data['endDate'] as String)
          : null,
      budgetGoal: data['budgetGoal'] != null
          ? (data['budgetGoal'] is String
              ? double.tryParse(data['budgetGoal'] as String)
              : (data['budgetGoal'] as num).toDouble())
          : null,
      totalSpent: data['totalSpent'] != null
          ? (data['totalSpent'] is String
              ? double.tryParse(data['totalSpent'] as String)
              : (data['totalSpent'] as num).toDouble())
          : null,
    );
  }

  GroupFundEntity _toFundEntity(Map<String, dynamic> data) {
    return GroupFundEntity(
      id: data['id'] as String,
      groupId: data['groupId'] as String? ?? data['group_id'] as String,
      balance: toMinorUnitsFromJson(data['balance']),
    );
  }

  GroupMemberEntity _toMemberEntity(dynamic data) {
    final m = data as Map<String, dynamic>;
    return GroupMemberEntity(
      id: m['id'] as String,
      groupId: m['groupId'] as String? ?? m['group_id'] as String,
      userId: m['userId'] as String? ?? m['user_id'] as String,
      role: m['role'] == 'OWNER' ? GroupRole.owner : GroupRole.member,
      joinedAt:
          DateTime.parse(m['joinedAt'] as String? ?? m['joined_at'] as String),
      displayName: m['user']?['profile']?['displayName'] as String? ?? 'User',
      avatarUrl: m['user']?['profile']?['avatarUrl'] as String?,
    );
  }
}
