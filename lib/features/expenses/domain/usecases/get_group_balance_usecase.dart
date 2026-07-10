import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../entities/group_balance_entity.dart';
import '../repositories/expense_repository.dart';

@injectable
class GetGroupBalanceUseCase
    implements UseCase<List<GroupBalanceEntity>, GetGroupBalanceParams> {
  const GetGroupBalanceUseCase(this._repository);

  final ExpenseRepository _repository;

  @override
  Future<Either<Failure, List<GroupBalanceEntity>>> call(
          GetGroupBalanceParams params) =>
      _repository.getGroupBalance(params.groupId);
}

class GetGroupBalanceParams extends Equatable {
  const GetGroupBalanceParams({required this.groupId});

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}
