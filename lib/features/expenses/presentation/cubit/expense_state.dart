import 'package:equatable/equatable.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/group_balance_entity.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

final class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

final class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

final class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({
    required this.expenses,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.balances,
  });

  final List<ExpenseEntity> expenses;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final List<GroupBalanceEntity>? balances;

  ExpenseLoaded copyWith({
    List<ExpenseEntity>? expenses,
    bool? isLoadingMore,
    bool? hasReachedMax,
    List<GroupBalanceEntity>? balances,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      balances: balances ?? this.balances,
    );
  }

  @override
  List<Object?> get props => [expenses, isLoadingMore, hasReachedMax, balances];
}

final class ExpenseCreating extends ExpenseState {
  const ExpenseCreating();
}

final class ExpenseCreated extends ExpenseState {
  const ExpenseCreated({required this.expense});

  final ExpenseEntity expense;

  @override
  List<Object?> get props => [expense];
}

final class ExpenseDeleted extends ExpenseState {
  const ExpenseDeleted({required this.expenseId});

  final String expenseId;

  @override
  List<Object?> get props => [expenseId];
}

final class ExpenseFailureState extends ExpenseState {
  const ExpenseFailureState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ExpenseDetailLoaded extends ExpenseState {
  const ExpenseDetailLoaded({required this.expense});

  final ExpenseEntity expense;

  @override
  List<Object?> get props => [expense];
}

final class ExpenseUpdating extends ExpenseState {
  const ExpenseUpdating();
}

final class ExpenseUpdated extends ExpenseState {
  const ExpenseUpdated({required this.expense});

  final ExpenseEntity expense;

  @override
  List<Object?> get props => [expense];
}
