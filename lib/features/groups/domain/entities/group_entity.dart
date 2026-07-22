import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/app_enums.dart';
import 'group_fund_entity.dart';

class GroupEntity extends Equatable {
  const GroupEntity({
    required this.id,
    required this.name,
    required this.currency,
    required this.createdBy,
    required this.createdAt,
    required this.memberCount,
    this.description,
    this.avatarUrl,
    this.isActive = true,
    this.fund,
    this.startDate,
    this.endDate,
    this.budgetGoal,
    this.totalSpent,
  });

  final String id;
  final String name;
  final String currency;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final String? description;
  final String? avatarUrl;
  final bool isActive;
  final GroupFundEntity? fund;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budgetGoal;
  final double? totalSpent;

  @override
  List<Object?> get props => [id, name, currency, memberCount, isActive, fund, startDate, endDate, budgetGoal, totalSpent];
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
