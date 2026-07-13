import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(params.toMap());
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    this.displayName,
    this.username,
    this.bio,
    this.phone,
    this.avatarUrl,
  });

  final String? displayName;
  final String? username;
  final String? bio;
  final String? phone;
  final String? avatarUrl;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (displayName != null) map['displayName'] = displayName;
    if (username != null) map['username'] = username;
    if (bio != null) map['bio'] = bio;
    if (phone != null) map['phone'] = phone;
    if (avatarUrl != null) map['avatarUrl'] = avatarUrl;
    return map;
  }

  @override
  List<Object?> get props => [displayName, username, bio, phone, avatarUrl];
}
