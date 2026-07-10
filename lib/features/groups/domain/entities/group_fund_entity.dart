import 'package:equatable/equatable.dart';

class GroupFundEntity extends Equatable {
  const GroupFundEntity({
    required this.id,
    required this.groupId,
    required this.balance,
  });

  final String id;
  final String groupId;
  final int balance;

  @override
  List<Object?> get props => [id, groupId, balance];
}

class FundTransactionEntity extends Equatable {
  const FundTransactionEntity({
    required this.id,
    required this.fundId,
    required this.createdBy,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.expenseId,
    this.note,
    this.creatorName,
  });

  final String id;
  final String fundId;
  final String createdBy;
  final String? expenseId;
  final String type; // CONTRIBUTION, EXPENSE, REFUND
  final int amount;
  final String? note;
  final String? creatorName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, type, amount, createdAt];
}
