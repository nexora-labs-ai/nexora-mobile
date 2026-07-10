import '../../../../../shared/enums/app_enums.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';

abstract final class ExpenseMapper {
  static ExpenseEntity toEntity(ExpenseModel model) {
    return ExpenseEntity(
      id: model.id,
      groupId: model.groupId,
      paidByUserId: model.paidByUserId,
      title: model.title,
      amount: model.amount,
      currency: model.currency,
      fundingSource: _mapFundingSource(model.fundingSource),
      categoryId: model.categoryId,
      category: model.category != null
          ? CategoryEntity(
              id: model.category!.id,
              name: model.category!.name,
              icon: model.category!.icon,
              color: model.category!.color,
              isDefault: model.category!.isDefault,
            )
          : null,
      expenseDate: DateTime.parse(model.expenseDate),
      splits: model.splits.map(_toSplitEntity).toList(),
      createdAt: DateTime.parse(model.createdAt),
      splitType: _mapSplitType(model.splitType),
      description: model.description,
      receiptUrl: model.receiptUrl,
    );
  }

  static ExpenseSplitEntity _toSplitEntity(ExpenseSplitModel model) {
    return ExpenseSplitEntity(
      id: model.id,
      expenseId: model.expenseId,
      userId: model.userId,
      amountOwed: model.amountOwed,
      isSettled: model.isSettled,
      shares: model.shares,
    );
  }

  static FundingSource _mapFundingSource(String raw) =>
      switch (raw.toUpperCase()) {
        'GROUP_FUND' => FundingSource.groupFund,
        _ => FundingSource.personal,
      };

  static ExpenseSplitType _mapSplitType(String raw) =>
      switch (raw.toUpperCase()) {
        'SHARES' => ExpenseSplitType.shares,
        _ => ExpenseSplitType.exact,
      };
}
