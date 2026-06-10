import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/app_enums.dart';

class GroupEntity extends Equatable {
  const GroupEntity({
    required this.id,
    required this.name,
    required this.eventType,
    required this.currency,
    required this.createdBy,
    required this.createdAt,
    required this.memberCount,
    this.description,
    this.coverImageUrl,
    this.eventDateStart,
    this.eventDateEnd,
    this.targetBudget,
    this.fundBalance = 0,
  });

  final String id;
  final String name;
  final GroupEventType eventType;
  final String currency;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final String? description;
  final String? coverImageUrl;
  final DateTime? eventDateStart;
  final DateTime? eventDateEnd;
  final double? targetBudget;
  final double fundBalance;

  bool get hasTargetBudget => targetBudget != null && targetBudget! > 0;

  double get budgetUsedPercent {
    if (!hasTargetBudget) return 0;
    return (fundBalance / targetBudget!).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [id, name, eventType, currency, memberCount];
}

class GroupMemberEntity extends Equatable {
  const GroupMemberEntity({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String groupId;
  final String userId;
  final GroupRole role;
  final DateTime joinedAt;
  final String displayName;
  final String? avatarUrl;

  bool get isOwner => role == GroupRole.owner;

  @override
  List<Object?> get props => [id, userId, role];
}
