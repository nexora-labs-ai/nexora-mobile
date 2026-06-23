import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/components/error_view.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_card.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpenseCubit>()..loadExpenses(groupId),
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
            onPressed: () =>
                context.push('/groups/${widget.groupId}/expenses/create'),
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
          return switch (state) {
            ExpenseLoading() =>
              const Center(child: CircularProgressIndicator()),
            ExpenseLoaded(:final expenses, :final isLoadingMore) =>
              expenses.isEmpty
                  ? const ErrorView(
                      title: 'No expenses yet',
                      message: 'Add the first expense to get started.',
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: expenses.length + (isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == expenses.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return ExpenseCard(
                          expense: expenses[index],
                          onDelete: () =>
                              context.read<ExpenseCubit>().deleteExpense(
                                    groupId: widget.groupId,
                                    expenseId: expenses[index].id,
                                  ),
                        );
                      },
                    ),
            ExpenseFailureState(:final message) => ErrorView(
                message: message,
                onRetry: () =>
                    context.read<ExpenseCubit>().loadExpenses(widget.groupId),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
