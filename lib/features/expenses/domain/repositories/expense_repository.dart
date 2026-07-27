import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';
import '../entities/expense_entity.dart';
import '../entities/group_balance_entity.dart';

abstract interface class ExpenseRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({
    required String groupId,
    int page = 1,
    int pageSize = 20,
    String? query,
  });

  Future<Either<Failure, ExpenseEntity>> getExpenseById({
    required String groupId,
    required String expenseId,
  });

  Future<Either<Failure, ExpenseEntity>> createExpense({
    required String groupId,
    required String title,
    required int amount,
    required String currency,
    required String paidByUserId,
    required String categoryId,
    required String fundingSource,
    required DateTime expenseDate,
    required String splitType,
    required List<Map<String, dynamic>> splits,
    String? description,
    String? receiptUrl,
  });

  Future<Either<Failure, ExpenseEntity>> updateExpense({
    required String groupId,
    required String expenseId,
    required Map<String, dynamic> fields,
  });

  Future<Either<Failure, void>> deleteExpense({
    required String groupId,
    required String expenseId,
  });

  Future<Either<Failure, List<GroupBalanceEntity>>> getGroupBalance(
      String groupId);

  /// Returns expenses from local cache for offline support.
  Future<Either<Failure, List<ExpenseEntity>>> getCachedExpenses(
      String groupId);

  /// Persist expenses locally.
  Future<void> cacheExpenses(String groupId, List<ExpenseEntity> expenses);
}
