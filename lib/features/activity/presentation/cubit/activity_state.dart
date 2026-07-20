import 'package:equatable/equatable.dart';
import '../../domain/entities/activity_entity.dart';

sealed class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

final class ActivityInitial extends ActivityState {
  const ActivityInitial();
}

final class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

final class ActivityLoaded extends ActivityState {
  const ActivityLoaded({
    required this.activities,
    required this.hasReachedMax,
  });

  final List<ActivityEntity> activities;
  final bool hasReachedMax;

  ActivityLoaded copyWith({
    List<ActivityEntity>? activities,
    bool? hasReachedMax,
  }) {
    return ActivityLoaded(
      activities: activities ?? this.activities,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [activities, hasReachedMax];
}

final class ActivityFailure extends ActivityState {
  const ActivityFailure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
