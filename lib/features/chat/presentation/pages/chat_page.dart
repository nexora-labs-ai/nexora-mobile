import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/components/error_view.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_bloc_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>()..add(ChatSessionStarted(groupId: groupId)),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer]),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Nexora AI'),
          ],
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatReady) _scrollToBottom();
        },
        builder: (context, state) {
          return switch (state) {
            ChatSessionLoading() =>
              const Center(child: CircularProgressIndicator()),
            ChatReady(:final messages, :final isStreaming) => Column(
                children: [
                  Expanded(
                    child: messages.isEmpty
                        ? _WelcomePrompt(
                            groupId: context.read<ChatBloc>().state is ChatReady
                                ? ''
                                : '')
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: messages.length,
                            itemBuilder: (context, index) => ChatBubble(
                              message: messages[index],
                              key: ValueKey(messages[index].id),
                            ),
                          ),
                  ),
                  ChatInput(
                    isLoading: isStreaming,
                    onSend: (content) => context.read<ChatBloc>().add(
                          ChatMessageSent(content: content),
                        ),
                  ),
                ],
              ),
            ChatFailureState(:final message) => ErrorView(message: message),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _WelcomePrompt extends StatelessWidget {
  const _WelcomePrompt({required this.groupId});

  final String groupId;

  static const _suggestions = [
    'Plan a 3-day trip to Da Nang for 6 people',
    'Suggest restaurants near Hoi An for tonight',
    'Help us split the hotel bill equally',
    'Summarize our group spending this week',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.auto_awesome, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Hello! I\'m your Nexora AI',
              style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'I can help plan your trip, suggest places, and manage group expenses.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () =>
                    context.read<ChatBloc>().add(ChatMessageSent(content: s)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(s,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
