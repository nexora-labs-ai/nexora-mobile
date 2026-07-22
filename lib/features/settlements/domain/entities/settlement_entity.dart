import 'package:equatable/equatable.dart';

import '../../../../shared/enums/app_enums.dart';

class SettlementEntity extends Equatable {
  const SettlementEntity({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.fromUserName,
    this.fromUserAvatarUrl,
    this.toUserName,
    this.toUserAvatarUrl,
    this.evidenceUrl,
    this.note,
  });

  final String id;
  final String groupId;
  final String fromUserId;
  final String toUserId;
  final int amount;
  final String currency;
  final SettlementStatus status;
  final DateTime createdAt;
  final String? fromUserName;
  final String? fromUserAvatarUrl;
  final String? toUserName;
  final String? toUserAvatarUrl;
  final String? evidenceUrl;
  final String? note;

  @override
  List<Object?> get props => [
        id,
        groupId,
        fromUserId,
        toUserId,
        amount,
        currency,
        status,
        createdAt,
        fromUserName,
        fromUserAvatarUrl,
        toUserName,
        toUserAvatarUrl,
        evidenceUrl,
        note,
      ];
}
