import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

@injectable
class CreateGroupUseCase implements UseCase<GroupEntity, CreateGroupParams> {
  const CreateGroupUseCase(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, GroupEntity>> call(CreateGroupParams params) {
    return _repository.createGroup(
      name: params.name,
      currency: params.currency,
      description: params.description,
      startDate: params.startDate,
      endDate: params.endDate,
      budgetGoal: params.budgetGoal,
    );
  }
}

class CreateGroupParams extends Equatable {
  const CreateGroupParams({
    required this.name,
    required this.currency,
    this.description,
    this.startDate,
    this.endDate,
    this.budgetGoal,
  });

  final String name;
  final String currency;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budgetGoal;

  @override
  List<Object?> get props => [name, currency, description, startDate, endDate, budgetGoal];
}
