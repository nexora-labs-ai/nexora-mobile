import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_fund_cubit.dart';
import '../cubit/group_fund_state.dart';
import '../cubit/group_state.dart';

class GroupFundPage extends StatelessWidget {
  const GroupFundPage({required this.groupId, this.groupCubit, super.key});

  final String groupId;
  final GroupCubit? groupCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        if (groupCubit != null)
          BlocProvider.value(value: groupCubit!)
        else
          BlocProvider(
              create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId)),
        BlocProvider(
          create: (_) => sl<GroupFundCubit>()..loadTransactions(groupId),
        ),
      ],
      child: _GroupFundView(groupId: groupId),
    );
  }
}

class _GroupFundView extends StatelessWidget {
  const _GroupFundView({required this.groupId});

  final String groupId;

  void _showFundDialog(BuildContext context, bool isContribution) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<GroupFundCubit>(),
        child: _FundActionDialog(
          groupId: groupId,
          isContribution: isContribution,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupFundCubit, GroupFundState>(
      listener: (context, state) {
        if (state is GroupFundSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          context.read<GroupCubit>().loadGroupDetail(groupId);
        } else if (state is GroupFundFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group Fund'),
        ),
        body: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, state) {
            if (state is GroupLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GroupDetailLoaded) {
              final group = state.group;
              final balance = group.fund?.balance ?? 0.0;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Current Balance',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            () {
                              final hasDecimals =
                                  balance.truncateToDouble() != balance;
                              final decimalDigits = group.currency == 'VND'
                                  ? 0
                                  : (hasDecimals ? 2 : 0);
                              final formattedBalance =
                                  balance.toStringAsFixed(decimalDigits);
                              return '${group.currency} $formattedBalance';
                            }(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    AppButton(
                      label: 'Contribute',
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.white),
                      onPressed: () => _showFundDialog(context, true),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Withdraw',
                      icon: const Icon(Icons.remove_circle_outline),
                      isOutlined: true,
                      onPressed: () => _showFundDialog(context, false),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BlocBuilder<GroupFundCubit, GroupFundState>(
                        builder: (context, state) {
                          if (state is GroupFundLoading ||
                              state is GroupFundInitial) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is GroupFundTransactionsLoaded) {
                            final transactions = state.transactions;
                            if (transactions.isEmpty) {
                              return const Center(
                                child: Text('No transactions yet.'),
                              );
                            }

                            return ListView.separated(
                              itemCount: transactions.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final isContribute = tx.type == 'CONTRIBUTION';
                                final iconColor = isContribute
                                    ? AppColors.success
                                    : AppColors.error;
                                final sign = isContribute ? '+' : '-';

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        iconColor.withValues(alpha: 0.1),
                                    child: Icon(
                                      isContribute
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: iconColor,
                                    ),
                                  ),
                                  title: Text(
                                    isContribute
                                        ? 'Contribution'
                                        : 'Withdrawal',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${tx.creatorName ?? 'Unknown'} • ${tx.createdAt.toLocal().toString().split('.')[0]}\n${tx.note ?? ''}',
                                  ),
                                  isThreeLine:
                                      tx.note != null && tx.note!.isNotEmpty,
                                  trailing: Text(
                                    () {
                                      final hasDecimals =
                                          tx.amount.truncateToDouble() !=
                                              tx.amount;
                                      final decimalDigits =
                                          group.currency == 'VND'
                                              ? 0
                                              : (hasDecimals ? 2 : 0);
                                      final formattedAmount = tx.amount
                                          .toStringAsFixed(decimalDigits);
                                      return '$sign${group.currency} $formattedAmount';
                                    }(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: iconColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                );
                              },
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _FundActionDialog extends StatefulWidget {
  const _FundActionDialog({
    required this.groupId,
    required this.isContribution,
  });

  final String groupId;
  final bool isContribution;

  @override
  State<_FundActionDialog> createState() => _FundActionDialogState();
}

class _FundActionDialogState extends State<_FundActionDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final cubit = context.read<GroupFundCubit>();
    if (widget.isContribution) {
      cubit.contributeFund(
        groupId: widget.groupId,
        amount: amount,
        note: _noteController.text,
      );
    } else {
      cubit.withdrawFund(
        groupId: widget.groupId,
        amount: amount,
        note: _noteController.text,
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isContribution ? 'Contribute Fund' : 'Withdraw Fund';
    final buttonLabel = widget.isContribution ? 'Contribute' : 'Withdraw';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Amount',
            controller: _amountController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Note (Optional)',
            controller: _noteController,
            prefixIcon: const Icon(Icons.note_alt_outlined),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: buttonLabel,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
