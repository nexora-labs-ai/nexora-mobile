import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/group_balance_summary_widget.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId)),
        BlocProvider(create: (_) => sl<ExpenseCubit>()..loadExpenses(groupId)),
      ],
      child: _ExpenseListView(groupId: groupId),
    );
  }
}

class _ExpenseListView extends StatefulWidget {
  const _ExpenseListView({required this.groupId});

  final String groupId;

  @override
  State<_ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends State<_ExpenseListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ExpenseCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/groups/${widget.groupId}/expenses/create');
              if (context.mounted) {
                context.read<ExpenseCubit>().loadExpenses(widget.groupId);
                context.read<GroupCubit>().loadGroupDetail(widget.groupId);
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return BlocBuilder<GroupCubit, GroupState>(
            builder: (context, groupState) {
              final members = groupState is GroupDetailLoaded
                  ? groupState.members
                  : const <GroupMemberEntity>[];
              final currency = groupState is GroupDetailLoaded
                  ? groupState.group.currency
                  : 'USD';

              return switch (state) {
                ExpenseLoading() =>
                  const Center(child: CircularProgressIndicator()),
                ExpenseLoaded(
                  :final expenses,
                  :final isLoadingMore,
                  :final balances
                ) =>
                  Column(
                    children: [
                      if (balances != null && balances.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: GroupBalanceSummaryWidget(
                            balances: balances,
                            members: members,
                            currency: currency,
                          ),
                        ),
                      Expanded(
                        child: expenses.isEmpty
                            ? const ErrorView(
                                title: 'No expenses yet',
                                message:
                                    'Add the first expense to get started.',
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount:
                                    expenses.length + (isLoadingMore ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (index == expenses.length) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  return ExpenseCard(
                                    expense: expenses[index],
                                    onTap: () async {
                                      await context.push(
                                          '/groups/${widget.groupId}/expenses/${expenses[index].id}');
                                      if (context.mounted) {
                                        context
                                            .read<ExpenseCubit>()
                                            .loadExpenses(widget.groupId);
                                        context
                                            .read<GroupCubit>()
                                            .loadGroupDetail(widget.groupId);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ExpenseFailureState(:final message) => ErrorView(
                    message: message,
                    onRetry: () => context
                        .read<ExpenseCubit>()
                        .loadExpenses(widget.groupId),
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          );
        },
      ),
    );
  }
}
