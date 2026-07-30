import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import 'category_icon_widget.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    required this.expense,
    this.category,
    this.currentUserId,
    this.paidByUserName,
    super.key,
    this.onTap,
    this.onDelete,
  });

  final ExpenseEntity expense;
  final CategoryEntity? category;
  final String? currentUserId;
  final String? paidByUserName;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserPaid =
        currentUserId != null && expense.paidByUserId == currentUserId;

    // Determine the sign and amount to show
    String sign = '';
    int displayAmount = 0;
    String statusText = '';

    if (currentUserId == null) {
      displayAmount = expense.amount;
    } else if (isCurrentUserPaid) {
      displayAmount = expense.amount - expense.amountOwedBy(currentUserId!);
      if (displayAmount == 0) {
        sign = '';
        statusText = 'No Balance';
      } else {
        sign = '+';
        statusText = 'You Lent';
      }
    } else {
      displayAmount = expense.amountOwedBy(currentUserId!);
      if (displayAmount == 0) {
        sign = '';
        statusText = 'Not Involved';
      } else {
        sign = '-';
        statusText = 'You Borrowed';
      }
    }

    Color shareBgColor;
    Color shareTextColor;
    String shareLabel = '';

    if (currentUserId == null ||
        statusText == 'Not Involved' ||
        statusText == 'No Balance') {
      shareBgColor = Colors.transparent;
      shareTextColor = AppColors.onSurfaceVariant;
      shareLabel = statusText;
    } else if (sign == '+') {
      shareBgColor = const Color(0xFFE8F5E9); // Light green
      shareTextColor = AppColors.primary;
      shareLabel = 'You Lent';
    } else {
      shareBgColor = const Color(0xFFF9EBEA); // Light red
      shareTextColor = AppColors.error;
      shareLabel = 'You Borrowed';
    }

    String formattedDate =
        DateFormat('MMM dd, yyyy').format(expense.expenseDate);
    String paidByText =
        isCurrentUserPaid ? 'You' : (paidByUserName ?? 'Someone');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF1F3F4),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (category != null)
                          CategoryIconWidget(
                              iconName: category!.icon,
                              colorHex: category!.color)
                        else
                          const CategoryIconWidget(iconName: '', colorHex: ''),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      expense.title,
                                      style: AppTextStyles.titleMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (onDelete != null)
                                        GestureDetector(
                                          onTap: onDelete,
                                          child: const Padding(
                                            padding:
                                                EdgeInsets.only(right: 6.0),
                                            child: Icon(Icons.delete_outline,
                                                size: 18,
                                                color: AppColors.error),
                                          ),
                                        ),
                                      Text(
                                        _formatAmount(
                                            expense.amount, expense.currency),
                                        style:
                                            AppTextStyles.titleMedium.copyWith(
                                          color: AppColors.ink,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Paid by $paidByText',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (displayAmount > 0 && currentUserId != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            shareLabel,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: shareBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  sign == '+'
                                      ? Icons.arrow_outward
                                      : Icons.arrow_downward,
                                  size: 14,
                                  color: shareTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$sign${_formatAmount(displayAmount, expense.currency)}',
                                  style: TextStyle(
                                    color: shareTextColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int minorAmount, String currency) {
    final amount = minorUnitsToDouble(minorAmount);
    final hasDecimals = amount.truncateToDouble() != amount;
    final decimalDigits = currency == 'VND' ? 0 : (hasDecimals ? 2 : 0);
    final formatter = NumberFormat.currency(
        symbol: _currencySymbol(currency), decimalDigits: decimalDigits);
    return formatter.format(amount);
  }

  String _currencySymbol(String currency) => switch (currency) {
        'USD' => '\$',
        'EUR' => '€',
        'SGD' => 'S\$',
        _ => '₫',
      };
}
