import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/app_enums.dart';

/// Core business concept: a recorded group expense.
///
/// Immutable. Contains business validation. No JSON, no Flutter.
class ExpenseEntity extends Equatable {
  const ExpenseEntity({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.fundingSource,
    required this.categoryId,
    required this.expenseDate,
    required this.splits,
    required this.splitType,
    required this.createdAt,
    this.description,
    this.receiptUrl,
  });

  final String id;
  final String groupId;
  final String paidByUserId;
  final String title;
  final int amount;
  final String currency;
  final FundingSource fundingSource;
  final String categoryId; // Maps to categoryId UUID or string representation
  final DateTime expenseDate;
  final List<ExpenseSplitEntity> splits;
  final ExpenseSplitType splitType;
  final DateTime createdAt;
  final String? description;
  final String? receiptUrl;

  // ─── Business behaviors ───────────────────────────────────────────────────
  int get totalSplitAmount => splits.fold(0, (sum, s) => sum + s.amountOwed);
  bool get isSplitBalanced => (totalSplitAmount - amount).abs() < 0.01;

  int amountOwedBy(String userId) {
    final split = splits.where((s) => s.userId == userId).firstOrNull;
    return split?.amountOwed ?? 0;
  }

  bool isSettledFor(String userId) {
    return splits.where((s) => s.userId == userId).every((s) => s.isSettled);
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        paidByUserId,
        title,
        amount,
        currency,
        fundingSource,
        categoryId,
        expenseDate,
        splits,
        splitType,
        createdAt,
        description,
        receiptUrl,
      ];
}

class ExpenseSplitEntity extends Equatable {
  const ExpenseSplitEntity({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.amountOwed,
    required this.isSettled,
    this.shares,
  });

  final String id;
  final String expenseId;
  final String userId;
  final int amountOwed;
  final bool isSettled;

  final int? shares; // Optional: used when splitType == shares

  @override
  List<Object?> get props => [id, userId, amountOwed, isSettled, shares];
}
