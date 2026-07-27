import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

@injectable
class GetExpensesUseCase
    implements UseCase<List<ExpenseEntity>, GetExpensesParams> {
  const GetExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(GetExpensesParams params) {
    return _repository.getExpenses(
      groupId: params.groupId,
      page: params.page,
      pageSize: params.pageSize,
      query: params.query,
    );
  }
}

class GetExpensesParams extends Equatable {
  const GetExpensesParams({
    required this.groupId,
    this.page = 1,
    this.pageSize = 20,
    this.query,
  });

  final String groupId;
  final int page;
  final int pageSize;
  final String? query;

  @override
  List<Object?> get props => [groupId, page, pageSize, query];
}
