import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../app/bindings/injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/group_message_entity.dart';
import '../bloc/group_chat_bloc.dart';
import '../bloc/group_chat_event.dart';
import '../bloc/group_chat_state.dart';
import '../../../recommendations/presentation/bloc/recommendations_bloc.dart';
import '../../../recommendations/presentation/bloc/recommendations_event.dart';
import '../../../recommendations/presentation/bloc/recommendations_state.dart';
import '../../../recommendations/domain/entities/recommendation_entity.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late GroupChatBloc _chatBloc;
  late RecommendationsBloc _recommendationsBloc;
  String? _currentUserId;
  bool _showRecommendations = true;
  
  final Set<String> _expandedBatches = {};
  final Map<String, GlobalKey> _messageKeys = {};

  @override
  void initState() {
    super.initState();
    _chatBloc = sl<GroupChatBloc>();
    _chatBloc.add(LoadGroupMessages(widget.groupId));

    _recommendationsBloc = sl<RecommendationsBloc>();
    _recommendationsBloc.add(LoadRecommendations(widget.groupId));

    final authState = sl<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }
  }

  @override
  void dispose() {
    _chatBloc.add(LeaveGroupChat(widget.groupId));
    _chatBloc.close();
    _recommendationsBloc.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _chatBloc.add(SendGroupMessage(
      groupId: widget.groupId,
      content: text,
    ));
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showGenerateRecommendationDialog() {
    String query = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gợi ý địa điểm'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Bạn muốn tìm gì? (VD: Quán ốc, Lẩu Thái...)'),
          onChanged: (val) => query = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (query.isNotEmpty) {
                _recommendationsBloc.add(GenerateRecommendations(widget.groupId, query));
                Navigator.of(ctx).pop();
                
                // Scroll to bottom to see loading
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.place),
                title: const Text('💡 Gợi ý địa điểm AI'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showGenerateRecommendationDialog();
                },
              ),
              // More options could be added here
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatBloc),
        BlocProvider.value(value: _recommendationsBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group Chat'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(_showRecommendations ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showRecommendations = !_showRecommendations;
                });
              },
            ),
          ],
        ),
        body: BlocListener<RecommendationsBloc, RecommendationsState>(
          listenWhen: (previous, current) {
            if (previous is RecommendationsLoaded && current is RecommendationsLoaded) {
              return (previous.errorMessage != current.errorMessage && current.errorMessage != null) || 
                     (previous.isGenerating != current.isGenerating && current.isGenerating);
            }
            return current is RecommendationsLoaded && (current.errorMessage != null || current.isGenerating);
          },
          listener: (context, state) {
            if (state is RecommendationsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Không thể tạo gợi ý: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is RecommendationsLoaded) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Không thể tạo gợi ý: ${state.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
                context.read<RecommendationsBloc>().add(ClearRecommendationError());
              } else if (state.isGenerating) {
                // Scroll to bottom when loading indicator appears
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            }
          },
          child: Column(
            children: [
              if (_showRecommendations) _buildTopRecommendationsBar(),
            Expanded(
              child: BlocBuilder<GroupChatBloc, GroupChatState>(
                builder: (context, state) {
                  if (state is GroupChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GroupChatError) {
                    return Center(child: Text(state.message));
                  } else if (state is GroupChatLoaded) {
                    if (state.messages.isEmpty) {
                      return const Center(child: Text('No messages yet.'));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[state.messages.length - 1 - index];
                        final isMe = msg.userId == _currentUserId;
                        return _buildMessageItem(msg, isMe);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            BlocBuilder<RecommendationsBloc, RecommendationsState>(
              builder: (context, recState) {
                if (recState is RecommendationsLoaded && recState.isGenerating) {
                  return _buildLoadingMessage();
                }
                return const SizedBox.shrink();
              },
            ),
            _buildInputArea(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildTopRecommendationsBar() {
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        if (state is RecommendationsLoaded && state.recommendations.isNotEmpty) {
          final Set<String> uniqueBatches = {};
          final List<Map<String, String>> topics = [];

          for (var r in state.recommendations) {
            final bId = r.metadata?['batchId'] as String?;
            final topic = r.metadata?['topic'] as String? ?? 'Gợi ý mới';
            if (bId != null && !uniqueBatches.contains(bId)) {
              uniqueBatches.add(bId);
              topics.add({'batchId': bId, 'topic': topic});
            }
          }

          if (topics.isEmpty) return const SizedBox.shrink();

          return Container(
            height: 48,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: InputChip(
                    avatar: const Icon(Icons.bolt, size: 16),
                    label: Text(topic['topic']!),
                    onPressed: () {
                      final key = _messageKeys[topic['batchId']];
                      if (key != null && key.currentContext != null) {
                        Scrollable.ensureVisible(
                          key.currentContext!,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    onDeleted: () {
                      _recommendationsBloc.add(
                        DeleteRecommendationsByBatch(widget.groupId, topic['batchId']!),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'AI đang tìm kiếm gợi ý...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(GroupMessageEntity message, bool isMe) {
    final theme = Theme.of(context);
    
    // Check if it's a system recommendation message
    if (message.content.startsWith('[RECOMMENDATION_SYSTEM_MESSAGE]')) {
      final jsonStr = message.content.replaceFirst('[RECOMMENDATION_SYSTEM_MESSAGE]', '').trim();
      String topic = 'Gợi ý địa điểm';
      String? batchId;
      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        topic = data['topic'] as String? ?? topic;
        batchId = data['batchId'] as String?;
      } catch (e) {
        // Fallback for old messages
      }

      final isExpanded = batchId != null && _expandedBatches.contains(batchId);
      final key = batchId != null ? _messageKeys.putIfAbsent(batchId, () => GlobalKey()) : null;

      return Center(
        key: key,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  final currentBatchId = batchId;
                  if (currentBatchId != null) {
                    setState(() {
                      if (isExpanded) {
                        _expandedBatches.remove(currentBatchId);
                      } else {
                        _expandedBatches.add(currentBatchId);
                      }
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '💡 Chủ đề: $topic',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (batchId != null) ...[
                        const SizedBox(width: 8),
                        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20),
                      ]
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 8),
                _buildRecommendationsCarousel(isInline: true, batchId: batchId),
              ],
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.user?.profile?.avatarUrl != null
                  ? NetworkImage(message.user!.profile!.avatarUrl!)
                  : null,
              child: message.user?.profile?.avatarUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  Text(
                    message.user?.profile?.displayName ?? 'Unknown',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.createdAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCarousel({bool isInline = false, String? batchId}) {
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        if (state is RecommendationsLoaded && state.recommendations.isNotEmpty) {
          final filteredRecs = batchId != null
              ? state.recommendations.where((r) => r.metadata != null && r.metadata!['batchId'] == batchId).toList()
              : state.recommendations;

          if (filteredRecs.isEmpty) return const SizedBox.shrink();

          return Container(
            height: 200,
            margin: EdgeInsets.symmetric(vertical: isInline ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredRecs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final rec = filteredRecs[index];
                      return _buildRecommendationCard(rec);
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecommendationCard(RecommendationEntity rec) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final url = rec.content.googleMapsUrl;
        if (url != null && url.isNotEmpty) {
          try {
            await launchUrlString(url, mode: LaunchMode.externalApplication);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không thể mở bản đồ')),
              );
            }
          }
        }
      },
      child: Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rec.content.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                rec.content.imageUrl!,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (rec.content.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('${rec.content.rating}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rec.content.priceRange ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
                      ),
                      InkWell(
                        onTap: () {
                          _recommendationsBloc.add(ToggleLikeRecommendation(widget.groupId, rec.id));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: rec.isLiked ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                rec.isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: rec.isLiked ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text('${rec.likeCount}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
               icon: const Icon(Icons.add_circle_outline),
              onPressed: _showOptionsSheet,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
