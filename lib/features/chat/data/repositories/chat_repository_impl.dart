import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/socket/event_dispatcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._dioClient, this._eventDispatcher);

  final DioClient _dioClient;
  final EventDispatcher _eventDispatcher;

  @override
  Future<Either<Failure, ChatSessionEntity>> createSession({
    required String userId,
    String? groupId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.aiChatSessions,
        data: {'group_id': groupId},
      );
      final data = response.data as Map<String, dynamic>;
      return Right(ChatSessionEntity(
        id: data['id'] as String,
        userId: userId,
        createdAt: DateTime.parse(data['created_at'] as String),
        groupId: groupId,
        title: data['title'] as String?,
      ));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(String sessionId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.aiChatMessages(sessionId));
      final items = response.data['data'] as List;
      return Right(items.map((e) => _toMessageEntity(e as Map<String, dynamic>, sessionId)).toList());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.aiChatMessages(sessionId),
        data: {'content': content},
      );
      return Right(_toMessageEntity(response.data as Map<String, dynamic>, sessionId));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, String>> streamMessage({
    required String sessionId,
    required String content,
  }) async* {
    try {
      // Emit via socket for streaming response chunks
      _eventDispatcher.emit('ai:stream_message', {
        'session_id': sessionId,
        'content': content,
      });

      yield* _eventDispatcher
          .on<Map<String, dynamic>>('ai:stream_chunk_$sessionId')
          .map<Either<Failure, String>>((data) => Right(data['chunk'] as String));
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }

  MessageEntity _toMessageEntity(Map<String, dynamic> data, String sessionId) {
    return MessageEntity(
      id: data['id'] as String,
      sessionId: sessionId,
      role: data['role'] == 'USER' ? MessageRole.user : MessageRole.assistant,
      content: data['content'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      tokenCount: data['token_count'] as int?,
    );
  }
}
