import 'package:equatable/equatable.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({required this.notifications});
  final List<dynamic> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationsFailure extends NotificationsState {
  const NotificationsFailure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
