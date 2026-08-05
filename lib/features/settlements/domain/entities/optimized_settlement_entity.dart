import 'package:equatable/equatable.dart';

class OptimizedSettlementEntity extends Equatable {
  const OptimizedSettlementEntity({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.pendingAmount,
    required this.remainingAmount,
  });

  final String fromUserId;
  final String toUserId;
  final int amount;
  final int pendingAmount;
  final int remainingAmount;

  @override
  List<Object?> get props =>
      [fromUserId, toUserId, amount, pendingAmount, remainingAmount];
}
