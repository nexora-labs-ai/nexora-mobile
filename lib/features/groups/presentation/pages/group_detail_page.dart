import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../../core/utils/currency_utils.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId),
      child: BlocListener<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupLeft) {
            context.go('/groups');
          } else if (state is GroupFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: _GroupDetailView(groupId: groupId),
      ),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView({required this.groupId});

  final String groupId;

  void _showLeaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GroupCubit>().leaveGroup(groupId);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        return switch (state) {
          GroupLoading() =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
          GroupDetailLoaded(:final group) => Scaffold(
              appBar: AppBar(
                title: Text(group.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () => context.push('/groups/$groupId/invite'),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'settings') {
                        context.push('/groups/$groupId/settings');
                      } else if (value == 'leave') {
                        _showLeaveConfirmation(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                      const PopupMenuItem(
                        value: 'leave',
                        child: Text('Leave Group'),
                      ),
                    ],
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (group.fund != null)
                      _FundBanner(
                        balance: group.fund!.balance,
                        currency: group.currency,
                        groupId: group.id,
                      ),
                    // Group Header
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: group.avatarUrl != null
                                  ? NetworkImage(group.avatarUrl!)
                                  : null,
                              child: group.avatarUrl == null
                                  ? const Icon(Icons.group, size: 40)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            if (group.description != null &&
                                group.description!.isNotEmpty)
                              Text(
                                group.description!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Quick action buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _QuickAction(
                                icon: Icons.forum_outlined,
                                label: 'Group Chat',
                                onTap: () =>
                                    context.push('/groups/$groupId/chat'),
                              ),
                              const SizedBox(width: 8),
                              _QuickAction(
                                icon: Icons.receipt_long_outlined,
                                label: 'Expenses',
                                onTap: () =>
                                    context.push('/groups/$groupId/expenses'),
                              ),
                              const SizedBox(width: 8),
                              _QuickAction(
                                icon: Icons.map_outlined,
                                label: 'Itinerary',
                                onTap: () =>
                                    context.push('/groups/$groupId/itinerary'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _QuickAction(
                                icon: Icons.smart_toy_outlined,
                                label: 'AI Planner',
                                onTap: () =>
                                    context.push('/groups/$groupId/ai-chat'),
                              ),
                              const SizedBox(width: 8),
                              _QuickAction(
                                icon: Icons.people_outline,
                                label: 'Members',
                                onTap: () =>
                                    context.push('/groups/$groupId/members'),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          GroupFailureState(:final message) => Scaffold(
              body: ErrorView(
                message: message,
                onRetry: () =>
                    context.read<GroupCubit>().loadGroupDetail(groupId),
              ),
            ),
          _ => const Scaffold(body: SizedBox.shrink()),
        };
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _FundBanner extends StatelessWidget {
  const _FundBanner({
    required this.balance,
    required this.currency,
    required this.groupId,
  });

  final int balance;
  final String currency;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/groups/$groupId/fund',
          extra: context.read<GroupCubit>()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Fund',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  () {
                    final amount = minorUnitsToDouble(balance);
                    final hasDecimals = amount.truncateToDouble() != amount;
                    final decimalDigits =
                        currency == 'VND' ? 0 : (hasDecimals ? 2 : 0);
                    final formattedBalance =
                        amount.toStringAsFixed(decimalDigits);
                    return '$currency $formattedBalance';
                  }(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Icon(Icons.account_balance_wallet,
                color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }
}
