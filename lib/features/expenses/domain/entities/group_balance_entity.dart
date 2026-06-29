import 'package:equatable/equatable.dart';

class GroupBalanceEntity extends Equatable {
  const GroupBalanceEntity({
    required this.userId,
    required this.balance,
  });

  final String userId;
  final double balance;

  @override
  List<Object?> get props => [userId, balance];
}
