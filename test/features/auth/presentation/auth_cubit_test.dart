import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexora_mobile/core/base/base_usecase.dart';
import 'package:nexora_mobile/core/errors/failure.dart';
import 'package:nexora_mobile/features/auth/domain/entities/auth_token_entity.dart';
import 'package:nexora_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:nexora_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:nexora_mobile/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:nexora_mobile/features/auth/domain/usecases/login_with_mezon_usecase.dart';
import 'package:nexora_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nexora_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:nexora_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nexora_mobile/features/auth/presentation/cubit/auth_state.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLoginWithGoogleUseCase extends Mock
    implements LoginWithGoogleUseCase {}

class MockLoginWithMezonUseCase extends Mock implements LoginWithMezonUseCase {}

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _mockToken = AuthTokenEntity(
  accessToken: 'access_token_abc',
  refreshToken: 'refresh_token_xyz',
  expiresAt: DateTime.now().add(const Duration(hours: 1)),
);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockLoginWithGoogleUseCase loginWithGoogleUseCase;
  late MockLoginWithMezonUseCase loginWithMezonUseCase;

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    loginWithGoogleUseCase = MockLoginWithGoogleUseCase();
    loginWithMezonUseCase = MockLoginWithMezonUseCase();

    registerFallbackValue(
        const LoginParams(email: 'test@test.com', password: '1234'));
    registerFallbackValue(const NoParams());
  });

  group('AuthCubit', () {
    AuthCubit build() => AuthCubit(
          loginUseCase,
          loginWithMezonUseCase,
          registerUseCase,
          logoutUseCase,
          getCurrentUserUseCase,
          loginWithGoogleUseCase,
        );

    group('login()', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on success '
        '(until GetCurrentUserUseCase is wired)',
        build: build,
        setUp: () {
          when(() => loginUseCase(any()))
              .thenAnswer((_) async => Right(_mockToken));
        },
        act: (cubit) => cubit.login(email: 'a@b.com', password: 'Pass123!'),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(), // TODO: replace when profile fetch is added
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailureState] on network failure',
        build: build,
        setUp: () {
          when(() => loginUseCase(any())).thenAnswer(
              (_) async => const Left(NetworkFailure(message: 'No internet')));
        },
        act: (cubit) => cubit.login(email: 'a@b.com', password: 'Pass123!'),
        expect: () => [
          const AuthLoading(),
          const AuthFailureState(message: 'No internet'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailureState] on unauthorized failure',
        build: build,
        setUp: () {
          when(() => loginUseCase(any()))
              .thenAnswer((_) async => const Left(UnauthorizedFailure()));
        },
        act: (cubit) => cubit.login(email: 'wrong@test.com', password: 'wrong'),
        expect: () => [
          const AuthLoading(),
          const AuthFailureState(message: 'Unauthorized. Please log in again.'),
        ],
      );
    });

    group('logout()', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on success',
        build: build,
        setUp: () {
          when(() => logoutUseCase(any()))
              .thenAnswer((_) async => const Right(null));
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });
  });
}
