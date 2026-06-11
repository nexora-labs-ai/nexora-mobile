import 'package:equatable/equatable.dart';

import '../../domain/entities/group_entity.dart';

sealed class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

final class GroupInitial extends GroupState {
  const GroupInitial();
}

final class GroupLoading extends GroupState {
  const GroupLoading();
}

final class GroupListLoaded extends GroupState {
  const GroupListLoaded({required this.groups});

  final List<GroupEntity> groups;

  @override
  List<Object?> get props => [groups];
}

final class GroupDetailLoaded extends GroupState {
  const GroupDetailLoaded({required this.group, required this.members});

  final GroupEntity group;
  final List<GroupMemberEntity> members;

  @override
  List<Object?> get props => [group, members];
}

final class GroupCreated extends GroupState {
  const GroupCreated({required this.group});

  final GroupEntity group;

  @override
  List<Object?> get props => [group];
}

final class GroupFailureState extends GroupState {
  const GroupFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
