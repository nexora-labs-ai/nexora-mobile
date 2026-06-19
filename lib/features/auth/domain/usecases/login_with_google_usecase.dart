import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_token_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginWithGoogleUseCase implements UseCase<AuthTokenEntity, LoginWithGoogleParams> {
  const LoginWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthTokenEntity>> call(LoginWithGoogleParams params) {
    return _repository.loginWithGoogle(params.idToken);
  }
}

class LoginWithGoogleParams extends Equatable {
  const LoginWithGoogleParams({required this.idToken});

  final String idToken;

  @override
  List<Object?> get props => [idToken];
}
