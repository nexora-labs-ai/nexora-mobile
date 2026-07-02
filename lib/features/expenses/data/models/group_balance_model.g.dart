// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_balance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupBalanceModel _$GroupBalanceModelFromJson(Map<String, dynamic> json) =>
    GroupBalanceModel(
      userId: json['userId'] as String,
      balance: toMinorUnitsFromJson(json['balance']),
    );

Map<String, dynamic> _$GroupBalanceModelToJson(GroupBalanceModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'balance': instance.balance,
    };
