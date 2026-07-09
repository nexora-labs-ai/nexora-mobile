import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/group_message_entity.dart';
import '../../domain/repositories/group_chat_repository.dart';
import 'group_chat_event.dart';
import 'group_chat_state.dart';

@injectable
class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  GroupChatBloc(this._repository) : super(GroupChatInitial()) {
    on<LoadGroupMessages>(_onLoadGroupMessages);
    on<SendGroupMessage>(_onSendGroupMessage);
    on<MessageReceived>(_onMessageReceived);
    on<LeaveGroupChat>(_onLeaveGroupChat);
  }

  final GroupChatRepository _repository;
  StreamSubscription<GroupMessageEntity>? _messageSubscription;

  Future<void> _onLoadGroupMessages(
    LoadGroupMessages event,
    Emitter<GroupChatState> emit,
  ) async {
    emit(GroupChatLoading());
    
    // Join socket room
    await _repository.joinChat(event.groupId);

    // Subscribe to incoming messages if not already
    _messageSubscription ??= _repository.onNewMessage.listen((message) {
      if (message.groupId == event.groupId) {
        add(MessageReceived(message));
      }
    });

    final result = await _repository.getMessages(event.groupId);
    result.fold(
      (failure) => emit(GroupChatError(failure.message)),
      (messages) => emit(GroupChatLoaded(messages: messages)),
    );
  }

  Future<void> _onSendGroupMessage(
    SendGroupMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    // Optimistic UI update could be done here, but since socket returns it quickly, we'll wait for the event.
    final result = await _repository.sendMessage(event.groupId, event.content);
    result.fold(
      (failure) {
        // Emit error, maybe keep old state if needed
      },
      (_) {
        // Success, wait for MessageReceived
      },
    );
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<GroupChatState> emit,
  ) {
    if (state is GroupChatLoaded) {
      final currentState = state as GroupChatLoaded;
      // Prevent duplicates
      if (!currentState.messages.any((m) => m.id == event.message.id)) {
        emit(GroupChatLoaded(
          messages: [...currentState.messages, event.message],
          hasReachedMax: currentState.hasReachedMax,
        ));
      }
    }
  }

  Future<void> _onLeaveGroupChat(
    LeaveGroupChat event,
    Emitter<GroupChatState> emit,
  ) async {
    await _repository.leaveChat(event.groupId);
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
