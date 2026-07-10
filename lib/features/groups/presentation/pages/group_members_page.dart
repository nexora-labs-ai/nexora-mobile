import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../domain/entities/group_entity.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class GroupMembersPage extends StatelessWidget {
  const GroupMembersPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    // Note: We expect the GroupCubit to already have loaded members,
    // or we can reload it if needed. For simplicity, we just use the BlocBuilder
    // and provide the existing cubit if available, or fetch it from DI.
    // If we navigate here from GroupDetailPage, the Cubit might be available via context.
    return BlocProvider(
      create: (context) => sl<GroupCubit>()..loadGroupDetail(groupId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Members'),
        ),
        body: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, state) {
            if (state is GroupLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GroupFailureState) {
              return ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<GroupCubit>().loadGroupDetail(groupId),
              );
            } else if (state is GroupDetailLoaded) {
              return BlocBuilder<AuthCubit, AuthState>(
                bloc: sl<AuthCubit>(),
                builder: (context, authState) {
                  String currentUserId = '';
                  if (authState is AuthAuthenticated) {
                    currentUserId = authState.user.id;
                  }

                  final currentUserRole = state.members
                      .where((m) => m.userId == currentUserId)
                      .firstOrNull
                      ?.role;

                  final isCurrentUserOwner = currentUserRole == GroupRole.owner;

                  return ListView.builder(
                    itemCount: state.members.length,
                    itemBuilder: (context, index) {
                      final member = state.members[index];
                      final isMe = member.userId == currentUserId;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: member.avatarUrl != null
                              ? NetworkImage(member.avatarUrl!)
                              : null,
                          child: member.avatarUrl == null
                              ? Text(member.displayName[0].toUpperCase())
                              : null,
                        ),
                        title:
                            Text(member.displayName + (isMe ? ' (You)' : '')),
                        subtitle: Text(
                          member.role == GroupRole.owner ? 'Owner' : 'Member',
                          style: TextStyle(
                            color: member.role == GroupRole.owner
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: member.role == GroupRole.owner
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: (isCurrentUserOwner && !isMe)
                            ? PopupMenuButton<String>(
                                icon: const Icon(Icons.more_horiz,
                                    color: AppColors.textSecondary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onSelected: (value) {
                                  if (value == 'kick') {
                                    _showKickConfirmation(
                                        context, groupId, member);
                                  } else if (value == 'make_owner') {
                                    context.read<GroupCubit>().updateMemberRole(
                                          groupId: groupId,
                                          userId: member.userId,
                                          role: GroupRole.owner,
                                        );
                                  } else if (value == 'revoke_owner') {
                                    context.read<GroupCubit>().updateMemberRole(
                                          groupId: groupId,
                                          userId: member.userId,
                                          role: GroupRole.member,
                                        );
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (member.role == GroupRole.member)
                                    const PopupMenuItem(
                                      value: 'make_owner',
                                      child: Text('Make Owner'),
                                    )
                                  else
                                    const PopupMenuItem(
                                      value: 'revoke_owner',
                                      child: Text('Revoke Owner'),
                                    ),
                                  const PopupMenuItem(
                                    value: 'kick',
                                    child: Text('Kick Member',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showKickConfirmation(
      BuildContext context, String groupId, GroupMemberEntity member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kick Member'),
        content: Text(
            'Are you sure you want to remove ${member.displayName} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<GroupCubit>()
                  .kickMember(groupId: groupId, userId: member.userId);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
