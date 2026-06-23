import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/logger/app_logger.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_bloc_state.dart';

/// Uses Bloc (not Cubit) because AI streaming requires multi-step async
/// workflow: send → stream chunks → mark complete.
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._repository) : super(const ChatInitial()) {
    on<ChatSessionStarted>(_onSessionStarted);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessageStreamReceived>(_onStreamChunk);
    on<ChatMessageStreamCompleted>(_onStreamCompleted);
  }

  final ChatRepository _repository;
  StreamSubscription<dynamic>? _streamSubscription;

  Future<void> _onSessionStarted(
    ChatSessionStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatSessionLoading());

    // TODO: inject userId from auth context
    const userId = 'current_user';
    final result = await _repository.createSession(
      userId: userId,
      groupId: event.groupId,
    );

    result.fold(
      (failure) => emit(ChatFailureState(message: failure.message)),
      (session) => emit(ChatReady(sessionId: session.id, messages: const [])),
    );
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatReady) return;

    // Optimistic: add user message immediately
    final userMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: current.sessionId,
      role: MessageRole.user,
      content: event.content,
      createdAt: DateTime.now(),
    );

    // Add streaming placeholder for assistant
    final streamingMessage = MessageEntity(
      id: 'streaming',
      sessionId: current.sessionId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    emit(current.copyWith(
      messages: [...current.messages, userMessage, streamingMessage],
      isSending: true,
      isStreaming: true,
    ));

    // Subscribe to streaming response
    await _streamSubscription?.cancel();
    _streamSubscription = _repository
        .streamMessage(sessionId: current.sessionId, content: event.content)
        .listen(
          (either) {
            either.fold(
              (failure) {
                AppLogger.error('Chat stream error: ${failure.message}');
                add(const ChatMessageStreamCompleted());
              },
              (chunk) => add(ChatMessageStreamReceived(chunk: chunk)),
            );
          },
          onDone: () => add(const ChatMessageStreamCompleted()),
          onError: (e) {
            AppLogger.error('Chat stream error', error: e);
            add(const ChatMessageStreamCompleted());
          },
        );
  }

  void _onStreamChunk(
    ChatMessageStreamReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatReady) return;

    final updatedMessages = current.messages.map((m) {
      if (m.id == 'streaming') {
        return m.copyWith(content: m.content + event.chunk);
      }
      return m;
    }).toList();

    emit(current.copyWith(messages: updatedMessages));
  }

  void _onStreamCompleted(
    ChatMessageStreamCompleted event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatReady) return;

    // Finalize the streaming message
    final finalMessages = current.messages.map((m) {
      if (m.id == 'streaming') {
        return MessageEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sessionId: m.sessionId,
          role: m.role,
          content: m.content,
          createdAt: m.createdAt,
          isStreaming: false,
        );
      }
      return m;
    }).toList();

    emit(current.copyWith(
      messages: finalMessages,
      isSending: false,
      isStreaming: false,
    ));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
