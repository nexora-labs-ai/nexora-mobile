import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/currency_utils.dart';

part 'group_balance_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GroupBalanceModel {
  const GroupBalanceModel({
    required this.userId,
    required this.balance,
  });

  factory GroupBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$GroupBalanceModelFromJson(json);

  @JsonKey(name: 'userId')
  final String userId;
  @JsonKey(fromJson: toMinorUnitsFromJson)
  final int balance;

  Map<String, dynamic> toJson() => _$GroupBalanceModelToJson(this);
}
