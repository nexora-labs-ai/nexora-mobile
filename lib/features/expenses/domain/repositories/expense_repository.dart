import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../entities/expense_entity.dart';

abstract interface class ExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({
    required String groupId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, ExpenseEntity>> getExpenseById({
    required String groupId,
    required String expenseId,
  });

  Future<Either<Failure, ExpenseEntity>> createExpense({
    required String groupId,
    required String title,
    required double amount,
    required String currency,
    required String paidByUserId,
    required String category,
    required String fundingSource,
    required DateTime expenseDate,
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

  /// Returns expenses from local cache for offline support.
  Future<Either<Failure, List<ExpenseEntity>>> getCachedExpenses(String groupId);

  /// Persist expenses locally.
  Future<void> cacheExpenses(String groupId, List<ExpenseEntity> expenses);
}
