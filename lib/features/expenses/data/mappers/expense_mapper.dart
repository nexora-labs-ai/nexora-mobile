import '../../domain/entities/expense_entity.dart';
import '../../../../../shared/enums/app_enums.dart';
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
      category: _mapCategory(model.category),
      expenseDate: DateTime.parse(model.expenseDate),
      splits: model.splits.map(_toSplitEntity).toList(),
      createdAt: DateTime.parse(model.createdAt),
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
    );
  }

  static FundingSource _mapFundingSource(String raw) => switch (raw.toUpperCase()) {
        'GROUP_FUND' => FundingSource.groupFund,
        _ => FundingSource.personal,
      };

  static ExpenseCategory _mapCategory(String raw) => switch (raw.toUpperCase()) {
        'FOOD' => ExpenseCategory.food,
        'TRANSPORT' => ExpenseCategory.transport,
        'ACCOMMODATION' => ExpenseCategory.accommodation,
        'ENTERTAINMENT' => ExpenseCategory.entertainment,
        'SHOPPING' => ExpenseCategory.shopping,
        'HEALTH' => ExpenseCategory.health,
        _ => ExpenseCategory.other,
      };
}
