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
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
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
    String location = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gợi ý địa điểm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Bạn muốn tìm gì? (VD: Quán ốc, Lẩu Thái...)',
                labelText: 'Chủ đề',
              ),
              onChanged: (val) => query = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Quy Nhơn, Đà Lạt...',
                labelText: 'Vị trí',
              ),
              onChanged: (val) => location = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (query.isNotEmpty && location.isNotEmpty) {
                _recommendationsBloc.add(GenerateRecommendations(widget.groupId, query, location));
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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ chủ đề và vị trí')),
                );
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
        backgroundColor: const Color(0xFFF2F6ED), // Soft green tint background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          title: BlocBuilder<GroupCubit, GroupState>(
            builder: (context, state) {
              if (state is GroupDetailLoaded) {
                final group = state.group;
                final members = state.members;
                final activeCount = members.length;
                return Row(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 36,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: group.avatarUrl == null ? Colors.grey[300] : null,
                              backgroundImage: group.avatarUrl != null 
                                ? NetworkImage(group.avatarUrl!) 
                                : null,
                              child: group.avatarUrl == null ? const Icon(Icons.group, color: Colors.grey) : null,
                            ),
                          ),
                          if (activeCount > 1)
                            Positioned(
                              left: 16,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text('+${activeCount - 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${members.length} members',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.green),
              onPressed: () {},
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

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topics.length,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              final key = _messageKeys[topic['batchId']];
                              if (key != null && key.currentContext != null) {
                                Scrollable.ensureVisible(
                                  key.currentContext!,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              topic['topic']!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              _recommendationsBloc.add(
                                DeleteRecommendationsByBatch(widget.groupId, topic['batchId']!),
                              );
                            },
                            child: const Icon(Icons.close, size: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('• • •', style: TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(width: 12),
              Text(
                '✨ AI is typing...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.purple[300],
                  fontWeight: FontWeight.w500,
                ),
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

      final key = batchId != null ? _messageKeys.putIfAbsent(batchId, () => GlobalKey()) : null;
      final isHidden = batchId != null && _expandedBatches.contains(batchId);

      return Container(
        key: key,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            'NEXORA RECOMMENDATION',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      if (batchId != null)
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isHidden) {
                                _expandedBatches.remove(batchId!);
                              } else {
                                _expandedBatches.add(batchId!);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isHidden ? Icons.expand_more : Icons.expand_less, color: Colors.grey[600], size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHidden 
                      ? 'Recommendation: $topic'
                      : 'Based on your interests and the 24°C forecast, I recommend these spots for $topic:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isHidden) _buildRecommendationsCarousel(isInline: true, batchId: batchId),
            if (!isHidden) const SizedBox(height: 16),
          ],
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
                  : const NetworkImage('https://i.pravatar.cc/150?u=2'), // mock for UI if missing
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
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.colorScheme.primary
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe
                          ? theme.colorScheme.onPrimary
                          : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(message.createdAt.toLocal()),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey[600]),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, size: 14, color: Colors.green),
                    ]
                  ],
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8), // Adjusted right padding
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
            height: 265,
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
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: rec.content.imageUrl != null ? Image.network(
                  rec.content.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ) : Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    _recommendationsBloc.add(ToggleLikeRecommendation(widget.groupId, rec.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: rec.isLiked ? Colors.red : Colors.red[300],
                        ),
                        const SizedBox(width: 4),
                        Text('${rec.likeCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('${rec.content.rating ?? 4.5}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        rec.content.priceRange ?? '\$\$',
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5), // Pale green
                      foregroundColor: theme.colorScheme.primary, // Dark green text
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Add to Itinerary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: _showOptionsSheet,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                ),
                child: Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Message group...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                      onPressed: () {
                         _showGenerateRecommendationDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
