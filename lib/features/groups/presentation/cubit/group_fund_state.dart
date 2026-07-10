import 'package:equatable/equatable.dart';
import '../../domain/entities/group_fund_entity.dart';

sealed class GroupFundState extends Equatable {
  const GroupFundState();

  @override
  List<Object?> get props => [];
}

class GroupFundInitial extends GroupFundState {
  const GroupFundInitial();
}

class GroupFundLoading extends GroupFundState {
  const GroupFundLoading();
}

class GroupFundSuccess extends GroupFundState {
  const GroupFundSuccess(this.fund, this.message);

  final GroupFundEntity fund;
  final String message;

  @override
  List<Object?> get props => [fund, message];
}

class GroupFundFailure extends GroupFundState {
  const GroupFundFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class GroupFundTransactionsLoaded extends GroupFundState {
  const GroupFundTransactionsLoaded(this.transactions);

  final List<FundTransactionEntity> transactions;

  @override
  List<Object?> get props => [transactions];
}
