import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpenseByIdParams {
  const GetExpenseByIdParams({required this.groupId, required this.expenseId});
  final String groupId;
  final String expenseId;
}

@injectable
class GetExpenseByIdUseCase
    implements UseCase<ExpenseEntity, GetExpenseByIdParams> {
  const GetExpenseByIdUseCase(this._repository);

  final ExpenseRepository _repository;

  @override
  Future<Either<Failure, ExpenseEntity>> call(GetExpenseByIdParams params) {
    return _repository.getExpenseById(
      groupId: params.groupId,
      expenseId: params.expenseId,
    );
  }
}
