import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/components/error_view.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId),
      child: _GroupDetailView(groupId: groupId),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        return switch (state) {
          GroupLoading() => const Scaffold(body: Center(child: CircularProgressIndicator())),
          GroupDetailLoaded(:final group, :final members) => Scaffold(
              appBar: AppBar(
                title: Text(group.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () => context.push('/groups/$groupId/invite'),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick action buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _QuickAction(
                            icon: Icons.receipt_long_outlined,
                            label: 'Expenses',
                            onTap: () => context.push('/groups/$groupId/expenses'),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.chat_outlined,
                            label: 'AI Chat',
                            onTap: () => context.push('/groups/$groupId/chat'),
                          ),
                          const SizedBox(width: 12),
                          _QuickAction(
                            icon: Icons.map_outlined,
                            label: 'Itinerary',
                            onTap: () {}, // TODO
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
                onRetry: () => context.read<GroupCubit>().loadGroupDetail(groupId),
              ),
            ),
          _ => const Scaffold(body: SizedBox.shrink()),
        };
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

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
