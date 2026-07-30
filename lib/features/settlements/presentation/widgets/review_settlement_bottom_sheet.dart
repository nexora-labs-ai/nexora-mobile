import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../domain/entities/settlement_entity.dart';
import '../bloc/settlement_bloc.dart';

class ReviewSettlementBottomSheet extends StatelessWidget {
  final SettlementEntity settlement;
  final String memberName;
  final bool isDebtorView;

  const ReviewSettlementBottomSheet({
    super.key,
    required this.settlement,
    required this.memberName,
    this.isDebtorView = false,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatted = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(settlement.amount / 100);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isDebtorView ? 'Payment Details' : 'Review Payment',
                  style: AppTextStyles.headlineSmall
                      .copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  memberName,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  amountFormatted,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sent on ${DateFormat('MMM dd, yyyy h:mm a').format(settlement.createdAt.toLocal())}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ),
          if (settlement.note != null && settlement.note!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settlement.note!,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
          ],
          if (settlement.evidenceUrl != null &&
              settlement.evidenceUrl!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Evidence',
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                settlement.evidenceUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.surfaceContainerLow,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppColors.outline),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (!isDebtorView)
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Decline',
                    onPressed: () {
                      context
                          .read<SettlementBloc>()
                          .add(CancelSettlement(settlement.id));
                      Navigator.pop(context);
                    },
                    color: AppColors.error,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    label: 'Accept',
                    onPressed: () {
                      context
                          .read<SettlementBloc>()
                          .add(CompleteSettlement(settlement.id));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
