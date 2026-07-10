import 'package:equatable/equatable.dart';

class OptimizedSettlementEntity extends Equatable {
  const OptimizedSettlementEntity({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  final String fromUserId;
  final String toUserId;
  final int amount;

  @override
  List<Object?> get props => [fromUserId, toUserId, amount];
}
