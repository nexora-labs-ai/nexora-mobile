import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../repositories/expense_repository.dart';

@injectable
class DeleteExpenseUseCase implements UseCase<void, DeleteExpenseParams> {
  const DeleteExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteExpenseParams params) {
    return _repository.deleteExpense(
      groupId: params.groupId,
      expenseId: params.expenseId,
    );
  }
}

class DeleteExpenseParams extends Equatable {
  const DeleteExpenseParams({required this.groupId, required this.expenseId});

  final String groupId;
  final String expenseId;

  @override
  List<Object?> get props => [groupId, expenseId];
}
