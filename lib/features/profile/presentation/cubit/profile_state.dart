import 'package:equatable/equatable.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  const ProfileSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
