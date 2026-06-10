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
      eventType: params.eventType,
      currency: params.currency,
      description: params.description,
      targetBudget: params.targetBudget,
      eventDateStart: params.eventDateStart,
      eventDateEnd: params.eventDateEnd,
    );
  }
}

class CreateGroupParams extends Equatable {
  const CreateGroupParams({
    required this.name,
    required this.eventType,
    required this.currency,
    this.description,
    this.targetBudget,
    this.eventDateStart,
    this.eventDateEnd,
  });

  final String name;
  final String eventType;
  final String currency;
  final String? description;
  final double? targetBudget;
  final DateTime? eventDateStart;
  final DateTime? eventDateEnd;

  @override
  List<Object?> get props => [name, eventType, currency];
}
