import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/environment/app_env.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/login_with_mezon_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

/// Manages authentication lifecycle.
///
/// Allowed dependencies: [LoginUseCase], [RegisterUseCase], [LogoutUseCase], [GetCurrentUserUseCase], [LoginWithGoogleUseCase].
/// Forbidden: Dio, repositories, datasources.
@lazySingleton
class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit(
    this._loginUseCase,
    this._loginWithMezonUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._loginWithGoogleUseCase,
  ) : super(const AuthInitial());

  final LoginUseCase _loginUseCase;
  final LoginWithMezonUseCase _loginWithMezonUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  bool _isGoogleSignInInitialized = false;

  Future<void> login({required String email, required String password}) async {
    safeEmit(const AuthLoading());

    final result =
        await _loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(AuthFailureState(message: failure.message));
      },
      (_) => fetchCurrentUser(),
    );
  }

  Future<void> loginWithMezon(String code) async {
    safeEmit(const AuthLoading());

    final result = await _loginWithMezonUseCase(code);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(AuthFailureState(message: failure.message));
      },
      (_) => fetchCurrentUser(),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    safeEmit(const AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(
          email: email, password: password, displayName: displayName),
    );

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(AuthFailureState(message: failure.message));
      },
      (_) => fetchCurrentUser(),
    );
  }

  Future<void> loginWithGoogle() async {
    try {
      safeEmit(const AuthLoading());

      if (!_isGoogleSignInInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: AppEnv.instance.webClientId,
        );
        _isGoogleSignInInitialized = true;
      }

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(scopeHint: ['email', 'profile']);

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        safeEmit(const AuthFailureState(
            message: 'Failed to retrieve Google ID token.'));
        return;
      }

      final result = await _loginWithGoogleUseCase(
          LoginWithGoogleParams(idToken: idToken));

      result.fold(
        (failure) {
          logFailure(failure);
          safeEmit(AuthFailureState(message: failure.message));
        },
        (_) => fetchCurrentUser(),
      );
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
        safeEmit(const AuthUnauthenticated());
        return;
      }
      safeEmit(AuthFailureState(message: e.message ?? e.toString()));
    } catch (e) {
      if (e.toString().contains('canceled')) {
        safeEmit(const AuthUnauthenticated());
        return;
      }
      safeEmit(AuthFailureState(message: e.toString()));
    }
  }

  Future<void> logout() async {
    safeEmit(const AuthLoading());

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google sign out errors
    }

    final result = await _logoutUseCase(const NoParams());

    result.fold(
      (failure) {
        logFailure(failure);
        // Still unauthenticate locally even if server call fails
        safeEmit(const AuthUnauthenticated());
      },
      (_) => safeEmit(const AuthUnauthenticated()),
    );
  }

  Future<void> checkAuth() async {
    final token = await SecureStorage().getAccessToken();
    if (token != null) {
      await fetchCurrentUser();
    } else {
      safeEmit(const AuthUnauthenticated());
    }
  }

  // Called after login succeeds or on app start – fetches full user profile
  Future<void> fetchCurrentUser() async {
    final result = await _getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(AuthFailureState(message: failure.message));
      },
      (user) => safeEmit(AuthAuthenticated(user: user)),
    );
  }
}
