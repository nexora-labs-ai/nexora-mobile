import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({
    required this.groupId,
    required this.expenseId,
    super.key,
  });

  final String groupId;
  final String expenseId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId),
        ),
        BlocProvider(
          create: (_) => sl<ExpenseCubit>()
            ..loadExpenseDetail(groupId: groupId, expenseId: expenseId),
        ),
      ],
      child: _ExpenseDetailView(groupId: groupId, expenseId: expenseId),
    );
  }
}

class _ExpenseDetailView extends StatefulWidget {
  const _ExpenseDetailView({required this.groupId, required this.expenseId});

  final String groupId;
  final String expenseId;

  @override
  State<_ExpenseDetailView> createState() => _ExpenseDetailViewState();
}

class _ExpenseDetailViewState extends State<_ExpenseDetailView> {
  List<CategoryEntity> _categories = [];
  List<GroupMemberEntity> _members = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final usecase = sl<GetCategoriesUseCase>();
    final result = await usecase(const NoParams());
    result.fold(
      (l) => null,
      (r) {
        if (mounted) {
          setState(() {
            _categories = r;
          });
        }
      },
    );
  }

  String _getCategoryName(String categoryId) {
    return _categories
        .firstWhere((c) => c.id == categoryId,
            orElse: () => const CategoryEntity(
                id: '',
                name: 'Unknown Category',
                icon: '',
                color: '',
                isDefault: false))
        .name;
  }

  String _getMemberName(String userId) {
    return _members
        .firstWhere((m) => m.userId == userId,
            orElse: () => GroupMemberEntity(
                id: '',
                groupId: '',
                userId: userId,
                role: GroupRole.member,
                joinedAt: DateTime.now(),
                displayName: 'Unknown Member'))
        .displayName;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GroupCubit, GroupState>(
          listener: (context, state) {
            if (state is GroupDetailLoaded) {
              setState(() {
                _members = state.members;
              });
            }
          },
        ),
      ],
      child: BlocConsumer<ExpenseCubit, ExpenseState>(
        listenWhen: (prev, current) =>
            current is ExpenseDeleted || current is ExpenseFailureState,
        listener: (context, state) {
          if (state is ExpenseDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense deleted')),
            );
            context.pop();
          }
          if (state is ExpenseFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        buildWhen: (prev, current) =>
            current is ExpenseLoading ||
            current is ExpenseFailureState ||
            current is ExpenseDetailLoaded,
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Expense Details')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ExpenseFailureState) {
            return Scaffold(
              appBar: AppBar(title: const Text('Expense Details')),
              body: ErrorView(
                message: state.message,
                onRetry: () => context.read<ExpenseCubit>().loadExpenseDetail(
                    groupId: widget.groupId, expenseId: widget.expenseId),
              ),
            );
          }

          if (state is ExpenseDetailLoaded) {
            final expense = state.expense;
            final fmt = NumberFormat.currency(symbol: '', decimalDigits: 0);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Expense Details'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      final result = await context.push(
                          '/groups/${widget.groupId}/expenses/${expense.id}/edit');
                      if (context.mounted && result == true) {
                        context.read<ExpenseCubit>().loadExpenseDetail(
                            groupId: widget.groupId,
                            expenseId: widget.expenseId);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    onPressed: () => _confirmDelete(context, expense.id),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${fmt.format(expense.amount)} ${expense.currency}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormat('MMM dd, yyyy')
                            .format(expense.expenseDate.toLocal())),
                    const SizedBox(height: 12),
                    _DetailRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: _getCategoryName(expense.category)),
                    const SizedBox(height: 12),
                    _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Paid by',
                        value: _getMemberName(expense.paidByUserId)),
                    const SizedBox(height: 12),
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      _DetailRow(
                          icon: Icons.notes,
                          label: 'Notes',
                          value: expense.description!),
                    const Divider(height: 48),
                    Text('Split Details',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ...expense.splits.map((split) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.person,
                                color: AppColors.primary),
                          ),
                          title: Text(_getMemberName(split.userId)),
                          trailing: Text(
                            '${fmt.format(split.amountOwed)} ${expense.currency}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Expense Details')),
            body: const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String expenseId) async {
    final cubit = context.read<ExpenseCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cubit.deleteExpense(groupId: widget.groupId, expenseId: expenseId);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
