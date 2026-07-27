import 'dart:io';

import 'package:injectable/injectable.dart';
import '../../../../core/base/base_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileState> {
  ProfileCubit(
    this._updateProfileUseCase,
    this._uploadAvatarUseCase,
    this._authCubit,
  ) : super(const ProfileInitial());

  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final AuthCubit _authCubit;

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? phone,
    String? avatarUrl,
  }) async {
    safeEmit(const ProfileLoading());

    final params = UpdateProfileParams(
      displayName: displayName,
      username: username,
      bio: bio,
      phone: phone,
      avatarUrl: avatarUrl,
    );

    final result = await _updateProfileUseCase(params);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ProfileFailure(failure.message));
      },
      (user) {
        // Update the global auth state so everywhere gets the new user info immediately
        _authCubit.updateUserProfile(user);
        safeEmit(const ProfileSuccess('Profile updated successfully'));
      },
    );
  }

  Future<void> uploadAvatar(File file) async {
    safeEmit(const ProfileLoading());

    final result = await _uploadAvatarUseCase(file);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ProfileFailure(failure.message));
      },
      (user) {
        // Update the global auth state
        _authCubit.updateUserProfile(user);
        safeEmit(const ProfileSuccess('Avatar uploaded successfully'));
      },
    );
  }
}
