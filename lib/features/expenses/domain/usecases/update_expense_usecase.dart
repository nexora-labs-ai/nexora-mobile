import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class UpdateExpenseParams {
  const UpdateExpenseParams({
    required this.groupId,
    required this.expenseId,
    required this.fields,
  });

  final String groupId;
  final String expenseId;
  final Map<String, dynamic> fields;
}

@injectable
class UpdateExpenseUseCase
    implements UseCase<ExpenseEntity, UpdateExpenseParams> {
  const UpdateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  @override
  Future<Either<Failure, ExpenseEntity>> call(UpdateExpenseParams params) {
    return _repository.updateExpense(
      groupId: params.groupId,
      expenseId: params.expenseId,
      fields: params.fields,
    );
  }
}
