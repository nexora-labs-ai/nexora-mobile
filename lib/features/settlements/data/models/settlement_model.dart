import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../domain/entities/settlement_entity.dart';

part 'settlement_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SettlementModel {
  const SettlementModel({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.fromUser,
    this.toUser,
    this.evidenceUrl,
    this.note,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementModelFromJson(json);

  final String id;
  final String groupId;
  final String fromUserId;
  final String toUserId;
  @JsonKey(fromJson: toMinorUnitsFromJson)
  final int amount;
  final String currency;
  final SettlementStatus status;
  final DateTime createdAt;
  final Map<String, dynamic>? fromUser;
  final Map<String, dynamic>? toUser;
  final String? evidenceUrl;
  final String? note;

  Map<String, dynamic> toJson() => _$SettlementModelToJson(this);

  SettlementEntity toEntity() {
    return SettlementEntity(
      id: id,
      groupId: groupId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
      currency: currency,
      status: status,
      createdAt: createdAt,
      fromUserName: fromUser?['profile']?['displayName'] as String? ?? fromUser?['email'] as String?,
      fromUserAvatarUrl: fromUser?['profile']?['avatarUrl'] as String?,
      toUserName: toUser?['profile']?['displayName'] as String? ?? toUser?['email'] as String?,
      toUserAvatarUrl: toUser?['profile']?['avatarUrl'] as String?,
      evidenceUrl: evidenceUrl,
      note: note,
    );
  }
}
