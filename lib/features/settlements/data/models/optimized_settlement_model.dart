import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/optimized_settlement_entity.dart';

part 'optimized_settlement_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OptimizedSettlementModel {
  const OptimizedSettlementModel({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  factory OptimizedSettlementModel.fromJson(Map<String, dynamic> json) =>
      _$OptimizedSettlementModelFromJson(json);

  final String fromUserId;
  final String toUserId;
  @JsonKey(fromJson: toMinorUnitsFromJson)
  final int amount;

  Map<String, dynamic> toJson() => _$OptimizedSettlementModelToJson(this);

  OptimizedSettlementEntity toEntity() {
    return OptimizedSettlementEntity(
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
    );
  }
}
