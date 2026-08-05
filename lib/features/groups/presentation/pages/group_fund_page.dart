import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/group_fund_entity.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_fund_cubit.dart';
import '../cubit/group_fund_state.dart';
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
                'Group Fund',
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

          int? targetAmount;

          if (groupId.isNotEmpty && state is GroupDetailLoaded) {
            balance = state.group.fund?.balance ?? 0;
            targetAmount = state.group.budgetGoal != null
                ? (state.group.budgetGoal! * 100).toInt()
                : state.group.fund?.targetAmount;
            currency = state.group.currency;
          }

          return BlocBuilder<GroupFundCubit, GroupFundState>(
            builder: (context, fundState) {
              List<FundTransactionEntity> txs = [];
              if (groupId.isNotEmpty &&
                  fundState is GroupFundTransactionsLoaded) {
                txs = fundState.transactions;
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(24.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildTotalCard(context, groupId, currency, balance,
                            targetAmount, txs),
                        const SizedBox(height: 32),
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
                    sliver: Builder(
                      builder: (context) {
                        if (groupId.isNotEmpty &&
                            fundState is GroupFundLoading) {
                          return const SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          );
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
                                child: _buildTransactionItem(
                                    context, tx, currency),
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
          );
        },
      ),
      floatingActionButton: null,
    );
  }

  void _showEditTargetDialog(
      BuildContext context, String groupId, double currentTarget) {
    final controller = TextEditingController(
        text: currentTarget > 0 ? currentTarget.toString() : '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Target Amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Target Amount (\$)',
              hintText: 'e.g. 500',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim());
                if (amount != null && amount > 0) {
                  context.read<GroupCubit>().updateGroup(groupId, {
                    'budgetGoal': amount,
                  });
                  Navigator.pop(context);
                } else if (amount == 0 || controller.text.trim().isEmpty) {
                  context.read<GroupCubit>().updateGroup(groupId, {
                    'budgetGoal': null,
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9CCC65),
                foregroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalCard(
    BuildContext context,
    String groupId,
    String currency,
    int balance,
    int? targetAmount,
    List<FundTransactionEntity> txs,
  ) {
    final amount = minorUnitsToDouble(balance);
    final targetDouble =
        targetAmount != null ? minorUnitsToDouble(targetAmount) : 0.0;
    final targetFormatted =
        targetDouble > 0 ? formatCurrency(targetDouble) : 'Not set';
    final formattedBalance = formatCurrency(amount);

    final spentAmountMinor = txs
        .where((tx) => tx.type == 'EXPENSE')
        .fold<int>(0, (sum, tx) => sum + tx.amount);
    final spentDouble = minorUnitsToDouble(spentAmountMinor);
    final spentFormatted = formatCurrency(spentDouble);

    final progress =
        targetDouble > 0 ? (spentDouble / targetDouble).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progress * 100).toInt();

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL FUND BALANCE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedBalance,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Color(0xFF1E4620), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: $spentFormatted',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  if (targetDouble > 0)
                    Text(
                      'Target: $targetFormatted',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: const Color(0xFF1E4620),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (targetDouble <= 0)
                    Text(
                      'Target: Not set',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        _showEditTargetDialog(context, groupId, targetDouble),
                    child: const Icon(Icons.edit,
                        size: 14, color: Color(0xFF1E4620)),
                  ),
                ],
              ),
            ],
          ),
          if (targetDouble > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE5E9DF),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF386B1E)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$progressPercent% of budget used.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _showActionDialog(context, groupId, isRefund: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF386B1E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Contribute'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _showActionDialog(context, groupId, isRefund: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.outline),
                  ),
                  child: const Text('Refund'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, FundTransactionEntity tx, String currency) {
    final isExpense = tx.type == 'EXPENSE';
    final isContribution = tx.type == 'CONTRIBUTION';
    final isRefund = tx.type == 'REFUND';

    IconData icon;
    Color iconBg;
    Color iconColor;
    String sign = '';

    if (isExpense) {
      icon = Icons.restaurant;
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
      sign = '-';
    }

    final amount = minorUnitsToDouble(tx.amount);
    final formattedAmount = formatCurrency(amount);

    final note = tx.note;
    final creatorName = tx.creatorName ?? 'Member';
    final dateStr = DateFormat('MMM d, y').format(tx.createdAt);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isExpense
                                  ? 'Expense'
                                  : (isRefund ? 'Refund' : 'Contribution'),
                              style: AppTextStyles.headlineSmall
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$creatorName • $dateStr',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount', style: AppTextStyles.titleMedium),
                        Text(
                          '$sign$formattedAmount',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isExpense
                                ? AppColors.ink
                                : (isRefund
                                    ? AppColors.onSurface
                                    : AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (note != null && note.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Note', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            note,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (tx.evidenceUrl != null) ...[
                    const SizedBox(height: 24),
                    Text('Evidence',
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    tx.evidenceUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 32),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          tx.evidenceUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 48, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Close',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  (note != null && note.isNotEmpty)
                      ? note
                      : (isExpense
                          ? 'Expense'
                          : (isRefund ? 'Refund' : 'Contribution')),
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$creatorName • $dateStr',
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
              color: isExpense
                  ? AppColors.ink
                  : (isRefund ? AppColors.onSurface : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, String groupId,
      {required bool isRefund}) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String? pickedImageUrl;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (stCtx, setState) {
          final keyboardSpace = MediaQuery.of(ctx).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.only(
              bottom: keyboardSpace + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isRefund
                              ? AppColors.errorContainer
                              : const Color(0xFFE5E9DF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isRefund
                              ? Icons.outbox_rounded
                              : Icons.move_to_inbox_rounded,
                          color: isRefund
                              ? AppColors.error
                              : const Color(0xFF1E4620),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isRefund ? 'Refund to User' : 'Contribute to Fund',
                        style: AppTextStyles.headlineMedium
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (\$)',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (Optional)',
                      hintText: 'What is this for?',
                      prefixIcon: const Icon(Icons.notes),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Evidence',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (pickedImageUrl != null)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    pickedImageUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 32),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                          image: DecorationImage(
                            image: NetworkImage(pickedImageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(color: Colors.black, blurRadius: 4)
                                    ]),
                                onPressed: () =>
                                    setState(() => pickedImageUrl = null),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: isUploading
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (file != null) {
                                setState(() => isUploading = true);
                                try {
                                  final dio = sl<DioClient>().dio;
                                  final formData = FormData.fromMap({
                                    'file':
                                        await MultipartFile.fromFile(file.path),
                                  });
                                  final response = await dio.post(
                                      ApiEndpoints.uploadReceipt,
                                      data: formData);
                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    if (stCtx.mounted) {
                                      setState(() {
                                        pickedImageUrl = response
                                            .data['receiptUrl'] as String;
                                        isUploading = false;
                                      });
                                    }
                                  }
                                } catch (e) {
                                  if (stCtx.mounted) {
                                    ScaffoldMessenger.of(stCtx).showSnackBar(
                                      SnackBar(
                                          content: Text('Upload failed: $e')),
                                    );
                                    setState(() => isUploading = false);
                                  }
                                }
                              }
                            },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: isUploading
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: [
                                    Icon(Icons.cloud_upload_outlined,
                                        color: Colors.grey[600], size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to upload receipt or evidence',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final amountStr = amountController.text.trim();
                        if (amountStr.isEmpty) return;
                        final amountDouble = double.tryParse(amountStr);
                        if (amountDouble == null || amountDouble <= 0) return;

                        final amountMinor = (amountDouble * 100).toInt();

                        if (isRefund) {
                          context.read<GroupFundCubit>().withdrawFund(
                                groupId: groupId,
                                amount: amountMinor,
                                note: noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                                evidenceUrl: pickedImageUrl,
                              );
                        } else {
                          context.read<GroupFundCubit>().contributeFund(
                                groupId: groupId,
                                amount: amountMinor,
                                note: noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                                evidenceUrl: pickedImageUrl,
                              );
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isRefund ? 'Confirm Refund' : 'Confirm Contribution',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
