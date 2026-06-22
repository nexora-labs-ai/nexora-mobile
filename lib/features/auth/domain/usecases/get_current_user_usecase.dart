import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCurrentUserUseCase implements UseCase<UserEntity, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
