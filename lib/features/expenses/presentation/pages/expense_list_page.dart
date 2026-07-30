import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_card.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({required this.groupId, this.isTab = false, super.key});

  final String groupId;
  final bool isTab;

  @override
  Widget build(BuildContext context) {
    return _ExpenseListView(groupId: groupId, isTab: isTab);
  }
}

class _ExpenseListView extends StatefulWidget {
  const _ExpenseListView({required this.groupId, this.isTab = false});

  final String groupId;
  final bool isTab;

  @override
  State<_ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends State<_ExpenseListView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ExpenseCubit>().loadMore();
    }
  }

  String _formatCurrency(int minorAmount, String currency) {
    final amount = minorUnitsToDouble(minorAmount);
    final hasDecimals = amount.truncateToDouble() != amount;
    final decimalDigits = currency == 'VND' ? 0 : (hasDecimals ? 2 : 0);
    final symbol = switch (currency) {
      'USD' => '\$',
      'EUR' => '€',
      'SGD' => 'S\$',
      _ => '₫',
    };
    final formatter =
        NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;

    final catState = context.watch<CategoryCubit>().state;
    final List<CategoryEntity> categories =
        catState is CategoryLoaded ? catState.categories : [];

    final body = BlocConsumer<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return BlocBuilder<GroupCubit, GroupState>(
          builder: (context, groupState) {
            return switch (state) {
              ExpenseLoading() =>
                const Center(child: CircularProgressIndicator()),
              ExpenseLoaded(:final expenses, :final isLoadingMore) =>
                _buildContent(expenses, isLoadingMore, currentUser?.id,
                    groupState, categories),
              ExpenseFailureState(:final message) => ErrorView(
                  message: message,
                  onRetry: () =>
                      context.read<ExpenseCubit>().loadExpenses(widget.groupId),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        );
      },
    );

    if (widget.isTab) {
      return body;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
                style: AppTextStyles.bodyMedium,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  context.read<ExpenseCubit>().applySearch(val);
                },
              )
            : Row(
                children: [
                  const Icon(Icons.hub, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Nexora',
                      style: AppTextStyles.displayMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: AppColors.onSurface),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  context.read<ExpenseCubit>().applySearch('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(currentUser?.avatarUrl ??
                'https://i.pravatar.cc/150?u=a042581f4e29026704d'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'expense_list_fab',
        backgroundColor: AppColors.primaryContainer,
        onPressed: () async {
          final result =
              await context.push('/groups/${widget.groupId}/expenses/create');
          if (context.mounted) {
            if (result is ExpenseEntity) {
              context.read<ExpenseCubit>().addExpenseLocally(result);
            }
          }
        },
        child: const Icon(Icons.add, color: AppColors.onPrimaryContainer),
      ),
      body: body,
    );
  }

  Widget _buildContent(
      List<ExpenseEntity> expenses,
      bool isLoadingMore,
      String? currentUserId,
      GroupState groupState,
      List<CategoryEntity> categories) {
    int totalAmount = expenses.fold(0, (sum, e) => sum + e.amount);
    String currency = 'USD';
    if (groupState is GroupDetailLoaded) {
      currency = groupState.group.currency;
    } else if (expenses.isNotEmpty) {
      currency = expenses.first.currency;
    }

    int yourShare = 0;
    int todayShare = 0;
    if (currentUserId != null) {
      final now = DateTime.now();
      for (var expense in expenses) {
        final amountOwed = expense.amountOwedBy(currentUserId);
        yourShare += amountOwed;

        if (expense.expenseDate.year == now.year &&
            expense.expenseDate.month == now.month &&
            expense.expenseDate.day == now.day) {
          todayShare += amountOwed;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: 'expense_fab_${widget.groupId}',
        onPressed: () async {
          final result =
              await context.push('/groups/${widget.groupId}/expenses/create');
          if (!mounted) return;
          if (result != null) {
            context.read<ExpenseCubit>().loadExpenses(widget.groupId);
            context.read<GroupCubit>().loadGroupDetail(widget.groupId);
          }
        },
        backgroundColor: const Color(0xFF386B1E),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 200) {
            context.read<ExpenseCubit>().loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          controller: widget.isTab ? null : _scrollController,
          key: widget.isTab ? const PageStorageKey('expense_tab') : null,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Group Total',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatCurrency(totalAmount, currency),
                                style: AppTextStyles.headlineMedium
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text('Across ${expenses.length} expenses',
                                style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Share',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatCurrency(yourShare, currency),
                                style: AppTextStyles.headlineMedium
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                                '+${_formatCurrency(todayShare, currency)} today',
                                style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Expenses',
                        style: AppTextStyles.headlineMedium
                            .copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            if (expenses.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  icon: Icons.receipt_long_outlined,
                  title: 'No expenses yet',
                  message: 'Add the first expense to get started.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: expenses.length + (isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == expenses.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    String? paidByUserName;
                    if (groupState is GroupDetailLoaded) {
                      final member = groupState.members
                          .where(
                              (m) => m.userId == expenses[index].paidByUserId)
                          .firstOrNull;
                      paidByUserName = member?.displayName;
                    }

                    final catState = context.read<CategoryCubit>().state;
                    final List<CategoryEntity> categories =
                        catState is CategoryLoaded ? catState.categories : [];

                    return ExpenseCard(
                      expense: expenses[index],
                      currentUserId: currentUserId,
                      paidByUserName: paidByUserName,
                      category: categories.isNotEmpty
                          ? categories.firstWhere(
                              (c) => c.id == expenses[index].categoryId,
                              orElse: () => const CategoryEntity(
                                id: '',
                                name: 'Unknown',
                                icon: '',
                                color: '',
                                isDefault: false,
                              ),
                            )
                          : null,
                      onTap: () async {
                        final result = await context.push(
                            '/groups/${widget.groupId}/expenses/${expenses[index].id}');
                        if (context.mounted) {
                          if (result is ExpenseEntity) {
                            context
                                .read<ExpenseCubit>()
                                .updateExpenseLocally(result);
                          } else {
                            context
                                .read<ExpenseCubit>()
                                .loadExpenses(widget.groupId);
                          }
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
      ),
    );
  }
}
