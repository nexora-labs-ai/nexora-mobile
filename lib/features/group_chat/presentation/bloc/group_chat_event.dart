import 'package:equatable/equatable.dart';

import '../../domain/entities/group_message_entity.dart';

abstract class GroupChatEvent extends Equatable {
  const GroupChatEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupMessages extends GroupChatEvent {
  const LoadGroupMessages(this.groupId);

  final String groupId;

  @override
  List<Object> get props => [groupId];
}

class SendGroupMessage extends GroupChatEvent {
  const SendGroupMessage({
    required this.groupId,
    required this.content,
  });

  final String groupId;
  final String content;

  @override
  List<Object> get props => [groupId, content];
}

class MessageReceived extends GroupChatEvent {
  const MessageReceived(this.message);

  final GroupMessageEntity message;

  @override
  List<Object> get props => [message];
}

class LeaveGroupChat extends GroupChatEvent {
  const LeaveGroupChat(this.groupId);

  final String groupId;

  @override
  List<Object> get props => [groupId];
}
