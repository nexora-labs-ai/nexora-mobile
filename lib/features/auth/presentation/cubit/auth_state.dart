import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Immutable state for [AuthCubit].
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthFailureState extends AuthState {
  const AuthFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
