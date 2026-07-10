// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optimized_settlement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptimizedSettlementModel _$OptimizedSettlementModelFromJson(
        Map<String, dynamic> json) =>
    OptimizedSettlementModel(
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      amount: toMinorUnitsFromJson(json['amount']),
    );

Map<String, dynamic> _$OptimizedSettlementModelToJson(
        OptimizedSettlementModel instance) =>
    <String, dynamic>{
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'amount': instance.amount,
    };
