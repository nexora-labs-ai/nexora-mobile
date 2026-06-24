import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_token_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginWithMezonUseCase implements UseCase<AuthTokenEntity, String> {
  const LoginWithMezonUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthTokenEntity>> call(String params) =>
      _repository.loginWithMezon(params);
}
