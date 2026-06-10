import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/app_enums.dart';

/// A single AI chat message in a session.
class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.tokenCount,
    this.isStreaming = false,
  });

  final String id;
  final String sessionId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final int? tokenCount;
  final bool isStreaming;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  MessageEntity copyWith({String? content, bool? isStreaming}) {
    return MessageEntity(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
      tokenCount: tokenCount,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [id, role, content, isStreaming];
}

class ChatSessionEntity extends Equatable {
  const ChatSessionEntity({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.groupId,
    this.title,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final String? groupId;
  final String? title;

  @override
  List<Object?> get props => [id, userId, groupId];
}
