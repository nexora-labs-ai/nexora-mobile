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

    // Determine the color, sign and amount to show
    Color amountColor;
    String sign = '';
    int displayAmount = 0;
    String statusText = '';

    if (currentUserId == null) {
      amountColor = AppColors.onSurface;
      displayAmount = expense.amount;
    } else if (isCurrentUserPaid) {
      displayAmount = expense.amount - expense.amountOwedBy(currentUserId!);
      if (displayAmount == 0) {
        amountColor = AppColors.onSurfaceVariant;
        sign = '';
        statusText = 'NO BALANCE';
      } else {
        amountColor = Colors.green.shade700;
        sign = '+';
        statusText = 'YOU ARE OWED';
      }
    } else {
      displayAmount = expense.amountOwedBy(currentUserId!);
      if (displayAmount == 0) {
        amountColor = AppColors.onSurfaceVariant;
        sign = '';
        statusText = 'NOT INVOLVED';
      } else {
        amountColor = Colors.red.shade700;
        sign = '-';
        statusText = 'YOU OWE';
      }
    }

    String formattedDate = DateFormat('MMM dd').format(expense.expenseDate);
    String paidByText =
        isCurrentUserPaid ? 'You' : (paidByUserName ?? 'Someone');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sign == '+') Container(width: 4, color: amountColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Row(
                        children: [
                          if (category != null)
                            CategoryIconWidget(
                                iconName: category!.icon,
                                colorHex: category!.color)
                          else
                            const CategoryIconWidget(
                                iconName: '', colorHex: ''),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(expense.title,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Text(
                                  'PAID BY ${paidByText.toUpperCase()} ${_formatAmount(expense.amount, expense.currency)} • ${formattedDate.toUpperCase()}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$sign${_formatAmount(displayAmount, expense.currency)}',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: amountColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (statusText.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  statusText,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                    color: amountColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                              if (onDelete != null) ...[
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: onDelete,
                                  child: const Icon(Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
