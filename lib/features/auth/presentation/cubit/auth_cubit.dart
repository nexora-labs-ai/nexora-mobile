import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

/// Manages authentication lifecycle.
///
/// Allowed dependencies: [LoginUseCase], [RegisterUseCase], [LogoutUseCase].
/// Forbidden: Dio, repositories, datasources.
@injectable
class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
  ) : super(const AuthInitial());

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> login({required String email, required String password}) async {
    safeEmit(const AuthLoading());

    final result = await _loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(AuthFailureState(message: failure.message));
      },
      (_) => _fetchCurrentUser(),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    safeEmit(const AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(email: email, password: password, displayName: displayName),
    );

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(AuthFailureState(message: failure.message));
      },
      (user) => safeEmit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> logout() async {
    safeEmit(const AuthLoading());

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

  // Called after login succeeds – fetches full user profile
  void _fetchCurrentUser() {
    // TODO: inject GetCurrentUserUseCase and fetch
    // For now emit a placeholder – real impl fetches profile after token save
    safeEmit(const AuthUnauthenticated()); // replaced after GetCurrentUserUseCase added
  }
}
