import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    required this.expense,
    this.category,
    super.key,
    this.onTap,
    this.onDelete,
  });

  final ExpenseEntity expense;
  final CategoryEntity? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (category != null)
                _CategoryIcon(
                    iconName: category!.icon, colorHex: category!.color)
              else
                const _CategoryIcon(iconName: '', colorHex: ''),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(expense.expenseDate),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(expense.amount, expense.currency),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.debit,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ],
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

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconName, required this.colorHex});

  final String iconName;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    // Parse color hex if possible, fallback to primary color
    Color parseColor(String hex) {
      if (hex.isEmpty) return AppColors.primary;
      try {
        final buffer = StringBuffer();
        if (hex.length == 6 || hex.length == 7) buffer.write('ff');
        buffer.write(hex.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (e) {
        return AppColors.primary;
      }
    }

    final color = parseColor(colorHex);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          iconName.isNotEmpty ? iconName : '❓',
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
