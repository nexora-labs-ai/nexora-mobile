import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/ai_widget_container.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../expenses/presentation/cubit/expense_cubit.dart';
import '../../../expenses/presentation/cubit/expense_state.dart';
import '../../../expenses/presentation/widgets/new_expense_bottom_sheet.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_fund_cubit.dart';
import '../cubit/group_state.dart';

class GroupFundPage extends StatelessWidget {
  const GroupFundPage({required this.groupId, this.isTab = false, super.key});

  final String groupId;
  final bool isTab;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider(create: (_) {
          final cubit = sl<GroupFundCubit>();
          if (groupId.isNotEmpty) cubit.loadTransactions(groupId);
          return cubit;
        }),
        BlocProvider(create: (_) {
          final cubit = sl<ExpenseCubit>();
          if (groupId.isNotEmpty) cubit.loadExpenses(groupId);
          return cubit;
        }),
      ],
      child: _GroupFundView(groupId: groupId, isTab: isTab),
    );
  }
}

class _GroupFundView extends StatelessWidget {
  const _GroupFundView({required this.groupId, required this.isTab});

  final String groupId;
  final bool isTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: isTab
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Expenses',
                style: AppTextStyles.headlineMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, color: AppColors.ink),
                ),
              ],
            ),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (groupId.isNotEmpty && state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          int balance = 142000;
          String currency = 'USD';

          if (groupId.isNotEmpty && state is GroupDetailLoaded) {
            balance = state.group.fund?.balance ?? 0;
            currency = state.group.currency;
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTotalCard(context, currency, balance),
                    const SizedBox(height: 24),
                    _buildAiInsightCard(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ledger',
                          style: AppTextStyles.headlineMedium
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, expenseState) {
                    if (groupId.isNotEmpty && expenseState is ExpenseLoading) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    List<dynamic> txs = [];
                    if (groupId.isNotEmpty && expenseState is ExpenseLoaded) {
                      txs = expenseState.expenses;
                    } else if (groupId.isEmpty) {
                      txs = [
                        {
                          'type': 'EXPENSE',
                          'amount': 4500,
                          'note': 'Dinner at Luigi\'s',
                          'creatorName': 'Marcus'
                        },
                        {
                          'type': 'CONTRIBUTION',
                          'amount': 15000,
                          'note': 'Initial Fund',
                          'creatorName': 'Sarah'
                        },
                        {
                          'type': 'EXPENSE',
                          'amount': 1200,
                          'note': 'Taxi to Hotel',
                          'creatorName': 'Elena'
                        },
                      ];
                    }

                    if (txs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                              child: Text('No transactions yet.',
                                  style: AppTextStyles.bodyLarge)),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tx = txs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTransactionItem(context, tx, currency),
                          );
                        },
                        childCount: txs.length,
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 100)), // Bottom padding
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (groupId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Please select a specific group from the Groups tab to add an expense.')),
            );
            return;
          }
          NewExpenseBottomSheet.show(context, groupId);
        },
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: Text('New Expense',
            style: AppTextStyles.labelSmall
                .copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, String currency, int balance) {
    final amount = minorUnitsToDouble(balance);
    final formattedBalance =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2)
            .format(amount); // Mocking standard display

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GROUP TOTAL',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.primaryContainer, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'On Budget',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formattedBalance,
            style: AppTextStyles.displayMedium
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.ink,
                  ),
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  icon: const Icon(Icons.pie_chart_outline, size: 18),
                  label: const Text('Analytics'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return AiWidgetContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.insights, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending Insight',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're spending 15% less on food than similar trips. Great job keeping dining costs low!",
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, dynamic tx, String currency) {
    // tx is either Map (mock) or ExpenseEntity (real)
    final isMap = tx is Map;
    final isExpense = isMap
        ? tx['type'] == 'EXPENSE'
        : true; // Real expenses are always EXPENSE
    final isContribution = isMap ? tx['type'] == 'CONTRIBUTION' : false;

    IconData icon;
    Color iconBg;
    Color iconColor;
    String sign = '';

    if (isExpense) {
      icon = Icons.restaurant; // In a real app, map from tx.category
      iconBg = AppColors.errorContainer;
      iconColor = AppColors.error;
      sign = '-';
    } else if (isContribution) {
      icon = Icons.account_balance_wallet;
      iconBg = AppColors.primaryContainer;
      iconColor = AppColors.primary;
      sign = '+';
    } else {
      icon = Icons.swap_horiz;
      iconBg = AppColors.surfaceContainerHigh;
      iconColor = AppColors.onSurface;
    }

    final rawAmount = isMap ? tx['amount'] : tx.amount;
    final amount = minorUnitsToDouble(rawAmount as int);
    final formattedAmount =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);

    final note = isMap ? tx['note'] : tx.title;
    // For real data, we might need a user lookup or it's provided in the UI
    final creatorName = isMap ? tx['creatorName'] : 'Member';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (note as String?) ?? (isExpense ? 'Expense' : 'Contribution'),
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${creatorName ?? 'Someone'} • Today',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '$sign$formattedAmount',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: isExpense ? AppColors.ink : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
