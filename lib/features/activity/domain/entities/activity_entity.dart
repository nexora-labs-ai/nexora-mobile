import 'package:equatable/equatable.dart';

enum ActivityType {
  expenseCreated,
  expenseUpdated,
  expenseDeleted,
  settlementCompleted,
  memberJoined,
  memberLeft,
  tripCreated,
  itineraryUpdated,
  aiRecommendationGenerated,
  budgetWarning,
  votingStarted,
  votingClosed,
  unknown,
}

class ActivityEntity extends Equatable {
  const ActivityEntity({
    required this.id,
    required this.groupId,
    required this.groupAvatar,
    required this.groupName,
    required this.userId,
    required this.userAvatar,
    required this.userName,
    required this.type,
    required this.createdAt,
    this.amount,
    this.statusBadge,
  });

  final String id;
  final String groupId;
  final String? groupAvatar;
  final String groupName;
  final String userId;
  final String? userAvatar;
  final String userName;
  final ActivityType type;
  final DateTime createdAt;
  final double? amount;
  final String? statusBadge;

  @override
  List<Object?> get props => [
        id,
        groupId,
        groupAvatar,
        groupName,
        userId,
        userAvatar,
        userName,
        type,
        createdAt,
        amount,
        statusBadge,
      ];
}
