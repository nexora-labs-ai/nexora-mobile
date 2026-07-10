import 'package:equatable/equatable.dart';

import '../../domain/entities/group_message_entity.dart';

abstract class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object?> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class GroupChatLoading extends GroupChatState {}

class GroupChatLoaded extends GroupChatState {
  const GroupChatLoaded({
    required this.messages,
    this.hasReachedMax = false,
  });

  final List<GroupMessageEntity> messages;
  final bool hasReachedMax;

  GroupChatLoaded copyWith({
    List<GroupMessageEntity>? messages,
    bool? hasReachedMax,
  }) {
    return GroupChatLoaded(
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [messages, hasReachedMax];
}

class GroupChatError extends GroupChatState {
  const GroupChatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
