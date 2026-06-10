import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

@injectable
class CreateExpenseUseCase implements UseCase<ExpenseEntity, CreateExpenseParams> {
  const CreateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  @override
  Future<Either<Failure, ExpenseEntity>> call(CreateExpenseParams params) {
    return _repository.createExpense(
      groupId: params.groupId,
      title: params.title,
      amount: params.amount,
      currency: params.currency,
      paidByUserId: params.paidByUserId,
      category: params.category,
      fundingSource: params.fundingSource,
      expenseDate: params.expenseDate,
      splits: params.splits,
      description: params.description,
      receiptUrl: params.receiptUrl,
    );
  }
}

class CreateExpenseParams extends Equatable {
  const CreateExpenseParams({
    required this.groupId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.paidByUserId,
    required this.category,
    required this.fundingSource,
    required this.expenseDate,
    required this.splits,
    this.description,
    this.receiptUrl,
  });

  final String groupId;
  final String title;
  final double amount;
  final String currency;
  final String paidByUserId;
  final String category;
  final String fundingSource;
  final DateTime expenseDate;
  final List<Map<String, dynamic>> splits;
  final String? description;
  final String? receiptUrl;

  @override
  List<Object?> get props => [groupId, title, amount, paidByUserId];
}
