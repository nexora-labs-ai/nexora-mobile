// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettlementModel _$SettlementModelFromJson(Map<String, dynamic> json) =>
    SettlementModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      amount: toMinorUnitsFromJson(json['amount']),
      currency: json['currency'] as String,
      status: $enumDecode(_$SettlementStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      fromUser: json['fromUser'] as Map<String, dynamic>?,
      toUser: json['toUser'] as Map<String, dynamic>?,
      evidenceUrl: json['evidenceUrl'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$SettlementModelToJson(SettlementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$SettlementStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'fromUser': instance.fromUser,
      'toUser': instance.toUser,
      'evidenceUrl': instance.evidenceUrl,
      'note': instance.note,
    };

const _$SettlementStatusEnumMap = {
  SettlementStatus.pending: 'PENDING',
  SettlementStatus.completed: 'COMPLETED',
  SettlementStatus.cancelled: 'CANCELLED',
};
