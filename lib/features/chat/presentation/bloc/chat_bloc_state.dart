import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatSessionStarted extends ChatEvent {
  const ChatSessionStarted({required this.groupId});

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({required this.content});

  final String content;

  @override
  List<Object?> get props => [content];
}

final class ChatMessageStreamReceived extends ChatEvent {
  const ChatMessageStreamReceived({required this.chunk});

  final String chunk;

  @override
  List<Object?> get props => [chunk];
}

final class ChatMessageStreamCompleted extends ChatEvent {
  const ChatMessageStreamCompleted();
}

final class ChatScrolledToTop extends ChatEvent {
  const ChatScrolledToTop();
}

// ─── State ────────────────────────────────────────────────────────────────────

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatSessionLoading extends ChatState {
  const ChatSessionLoading();
}

final class ChatReady extends ChatState {
  const ChatReady({
    required this.sessionId,
    required this.messages,
    this.isSending = false,
    this.isStreaming = false,
  });

  final String sessionId;
  final List<MessageEntity> messages;
  final bool isSending;
  final bool isStreaming;

  ChatReady copyWith({
    List<MessageEntity>? messages,
    bool? isSending,
    bool? isStreaming,
  }) {
    return ChatReady(
      sessionId: sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [sessionId, messages, isSending, isStreaming];
}

final class ChatFailureState extends ChatState {
  const ChatFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
