import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../entities/message_entity.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, ChatSessionEntity>> createSession({
    required String userId,
    String? groupId,
  });

  Future<Either<Failure, List<MessageEntity>>> getMessages(String sessionId);

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String sessionId,
    required String content,
  });

  /// Returns a stream for real-time AI response streaming.
  Stream<Either<Failure, String>> streamMessage({
    required String sessionId,
    required String content,
  });
}
