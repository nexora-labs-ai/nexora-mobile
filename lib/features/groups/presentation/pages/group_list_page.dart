import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../app/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/components/error_view.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';
import '../widgets/group_card.dart';

class GroupListPage extends StatelessWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupCubit>()..loadGroups(),
      child: const _GroupListView(),
    );
  }
}

class _GroupListView extends StatelessWidget {
  const _GroupListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push(RouteNames.createGroup);
              if (context.mounted) {
                context.read<GroupCubit>().loadGroups();
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            GroupLoading() => const Center(child: CircularProgressIndicator()),
            GroupListLoaded(:final groups) => groups.isEmpty
                ? EmptyView(
                    title: 'No groups yet',
                    message:
                        'Create a group to start planning with your friends.',
                    icon: Icons.group_outlined,
                    action: () async {
                      await context.push(RouteNames.createGroup);
                      if (context.mounted) {
                        context.read<GroupCubit>().loadGroups();
                      }
                    },
                    actionLabel: 'Create Group',
                  )
                : RefreshIndicator(
                    onRefresh: () => context.read<GroupCubit>().loadGroups(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => GroupCard(
                        group: groups[index],
                        onTap: () =>
                            context.push('/groups/${groups[index].id}'),
                      ),
                    ),
                  ),
            GroupFailureState(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<GroupCubit>().loadGroups(),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
