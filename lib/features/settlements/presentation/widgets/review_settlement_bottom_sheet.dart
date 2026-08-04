import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../domain/entities/settlement_entity.dart';
import '../bloc/settlement_bloc.dart';

class ReviewSettlementBottomSheet extends StatefulWidget {
  final List<SettlementEntity> settlements;
  final String memberName;
  final String? avatarUrl;
  final bool isDebtorView;

  const ReviewSettlementBottomSheet({
    super.key,
    required this.settlements,
    required this.memberName,
    this.avatarUrl,
    this.isDebtorView = false,
  });

  @override
  State<ReviewSettlementBottomSheet> createState() =>
      _ReviewSettlementBottomSheetState();
}

class _ReviewSettlementBottomSheetState
    extends State<ReviewSettlementBottomSheet> {
  late Set<String> _expandedIds;
  late List<SettlementEntity> _localSettlements;

  @override
  void initState() {
    super.initState();
    _localSettlements = List.from(widget.settlements);
    _expandedIds = {};
    if (_localSettlements.isNotEmpty) {
      _expandedIds.add(_localSettlements.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localSettlements.isEmpty) return const SizedBox();

    final initials = widget.memberName.length >= 2
        ? widget.memberName.substring(0, 2).toUpperCase()
        : (widget.memberName.isNotEmpty
            ? widget.memberName[0].toUpperCase()
            : '?');

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            Row(
              children: [
                const SizedBox(
                    width:
                        48), // To balance the close button and keep text centered
                Expanded(
                  child: Text(
                    widget.isDebtorView ? 'Payment Details' : 'Review Payment',
                    style: AppTextStyles.headlineSmall
                        .copyWith(fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ..._localSettlements.map((settlement) {
              final currencySymbol =
                  NumberFormat.simpleCurrency(name: settlement.currency)
                      .currencySymbol;
              final amountFormatted = formatCurrency(settlement.amount / 100.0,
                  symbol: currencySymbol);
              final isExpanded = _expandedIds.contains(settlement.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child: Column(
                  children: [
                    // Header Section (Tappable to expand/collapse)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedIds.remove(settlement.id);
                          } else {
                            _expandedIds.add(settlement.id);
                          }
                        });
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: widget.isDebtorView
                                ? const Color(0xFFE8F5E9)
                                : AppColors.primary,
                            backgroundImage: widget.avatarUrl != null
                                ? NetworkImage(widget.avatarUrl!)
                                : null,
                            child: widget.avatarUrl == null
                                ? Text(initials,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: widget.isDebtorView
                                            ? AppColors.ink
                                            : Colors.white))
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isDebtorView
                                ? 'Your payment to'
                                : 'Payment from',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.memberName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppColors.ink),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            amountFormatted,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM dd, yyyy • h:mm a')
                                      .format(settlement.createdAt.toLocal()),
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                    ),

                    // Expandable Details
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Column(
                        children: [
                          if (settlement.note != null &&
                              settlement.note!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.notes,
                                          size: 16,
                                          color: Colors.grey.shade500),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Note',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    settlement.note!,
                                    style: const TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 14,
                                        height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (settlement.evidenceUrl != null &&
                              settlement.evidenceUrl!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                settlement.evidenceUrl!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 160,
                                  width: double.infinity,
                                  color: AppColors.surfaceContainerLow,
                                  child: const Center(
                                    child: Icon(Icons.broken_image,
                                        color: AppColors.outline),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (widget.isDebtorView) ...[
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  context
                                      .read<SettlementBloc>()
                                      .add(CancelSettlement(settlement.id));
                                  setState(() {
                                    _localSettlements.removeWhere(
                                        (s) => s.id == settlement.id);
                                  });
                                  if (_localSettlements.isEmpty) {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: BorderSide(
                                      color: AppColors.error
                                          .withValues(alpha: 0.3),
                                      width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  backgroundColor:
                                      AppColors.error.withValues(alpha: 0.05),
                                ),
                                child: const Text('Cancel Payment',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              height: 48,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        context.read<SettlementBloc>().add(
                                            CancelSettlement(settlement.id));
                                        setState(() {
                                          _localSettlements.removeWhere(
                                              (s) => s.id == settlement.id);
                                        });
                                        if (_localSettlements.isEmpty) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: BorderSide(
                                            color: AppColors.error
                                                .withValues(alpha: 0.3),
                                            width: 1.5),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        backgroundColor: AppColors.error
                                            .withValues(alpha: 0.05),
                                      ),
                                      child: const Text('Decline',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.read<SettlementBloc>().add(
                                            CompleteSettlement(settlement.id));
                                        setState(() {
                                          _localSettlements.removeWhere(
                                              (s) => s.id == settlement.id);
                                        });
                                        if (_localSettlements.isEmpty) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                      ),
                                      child: const Text('Accept',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
