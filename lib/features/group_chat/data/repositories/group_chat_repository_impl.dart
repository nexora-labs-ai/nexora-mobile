import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/socket/event_dispatcher.dart';
import '../../domain/entities/group_message_entity.dart';
import '../../domain/repositories/group_chat_repository.dart';

@Injectable(as: GroupChatRepository)
class GroupChatRepositoryImpl implements GroupChatRepository {
  const GroupChatRepositoryImpl(this._dioClient, this._eventDispatcher);

  final DioClient _dioClient;
  final EventDispatcher _eventDispatcher;

  @override
  Future<Either<Failure, List<GroupMessageEntity>>> getMessages(
    String groupId, {
    int limit = 50,
    String? before,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.groupMessages(groupId),
        queryParameters: {
          'limit': limit,
          if (before != null) 'before': before,
        },
      );
      final items = response.data['data'] as List;
      return Right(
        items
            .map((e) => GroupMessageEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinChat(String groupId) async {
    try {
      _eventDispatcher.emit('join-chat', {'groupId': groupId});
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveChat(String groupId) async {
    try {
      _eventDispatcher.emit('leave-chat', {'groupId': groupId});
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(
      String groupId, String content) async {
    try {
      _eventDispatcher.emit('send-message', {
        'groupId': groupId,
        'content': content,
      });
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<GroupMessageEntity> get onNewMessage =>
      _eventDispatcher.on<Map<String, dynamic>>('new-message').map(
            (data) => GroupMessageEntity.fromJson(data),
          );
}
