import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../../domain/entities/expense_entity.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    required this.expense,
    super.key,
    this.onTap,
    this.onDelete,
  });

  final ExpenseEntity expense;
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
              _CategoryIcon(category: expense.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      child: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
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

  String _formatAmount(double amount, String currency) {
    final formatter = NumberFormat.currency(symbol: _currencySymbol(currency), decimalDigits: 0);
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
  const _CategoryIcon({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icon, color: _color, size: 22),
    );
  }

  IconData get _icon => switch (category) {
        ExpenseCategory.food => Icons.restaurant_outlined,
        ExpenseCategory.transport => Icons.directions_car_outlined,
        ExpenseCategory.accommodation => Icons.hotel_outlined,
        ExpenseCategory.entertainment => Icons.local_activity_outlined,
        ExpenseCategory.shopping => Icons.shopping_bag_outlined,
        ExpenseCategory.health => Icons.medical_services_outlined,
        ExpenseCategory.other => Icons.receipt_long_outlined,
      };

  Color get _color => switch (category) {
        ExpenseCategory.food => AppColors.warning,
        ExpenseCategory.transport => AppColors.info,
        ExpenseCategory.accommodation => AppColors.accent,
        ExpenseCategory.entertainment => AppColors.secondary,
        ExpenseCategory.shopping => AppColors.primary,
        ExpenseCategory.health => AppColors.success,
        ExpenseCategory.other => AppColors.textSecondary,
      };
}
