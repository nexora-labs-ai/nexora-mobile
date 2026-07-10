import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/group_message_entity.dart';

abstract class GroupChatRepository {
  Future<Either<Failure, List<GroupMessageEntity>>> getMessages(String groupId,
      {int limit = 50, String? before});

  Future<Either<Failure, void>> joinChat(String groupId);
  Future<Either<Failure, void>> leaveChat(String groupId);
  Future<Either<Failure, void>> sendMessage(String groupId, String content);

  Stream<GroupMessageEntity> get onNewMessage;
}
