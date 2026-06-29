import 'package:json_annotation/json_annotation.dart';

part 'group_balance_model.g.dart';

double _stringToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}

@JsonSerializable()
class GroupBalanceModel {
  const GroupBalanceModel({
    required this.userId,
    required this.balance,
  });

  factory GroupBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$GroupBalanceModelFromJson(json);

  final String userId;
  @JsonKey(fromJson: _stringToDouble)
  final double balance;

  Map<String, dynamic> toJson() => _$GroupBalanceModelToJson(this);
}
