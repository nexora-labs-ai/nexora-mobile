import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/group_repository.dart';
import 'group_fund_state.dart';
// to refresh group detail

@injectable
class GroupFundCubit extends Cubit<GroupFundState> {
  GroupFundCubit(this._repository) : super(const GroupFundInitial());

  final GroupRepository _repository;

  Future<void> contributeFund({
    required String groupId,
    required int amount,
    String? note,
  }) async {
    emit(const GroupFundLoading());
    final result = await _repository.contributeFund(
      groupId: groupId,
      amount: amount,
      note: note,
    );

    result.fold(
      (failure) => emit(GroupFundFailure(failure.message)),
      (fund) {
        emit(GroupFundSuccess(fund, 'Contribution successful'));
        loadTransactions(groupId); // Refresh transactions after contribution
      },
    );
  }

  Future<void> withdrawFund({
    required String groupId,
    required int amount,
    String? note,
  }) async {
    emit(const GroupFundLoading());
    final result = await _repository.withdrawFund(
      groupId: groupId,
      amount: amount,
      note: note,
    );

    result.fold(
      (failure) => emit(GroupFundFailure(failure.message)),
      (fund) {
        emit(GroupFundSuccess(fund, 'Withdrawal successful'));
        loadTransactions(groupId); // Refresh transactions after withdrawal
      },
    );
  }

  Future<void> loadTransactions(String groupId) async {
    emit(const GroupFundLoading());
    final result = await _repository.getFundTransactions(groupId);
    result.fold(
      (failure) => emit(GroupFundFailure(failure.message)),
      (transactions) => emit(GroupFundTransactionsLoaded(transactions)),
    );
  }
}
