import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../domain/usecases/create_expense_usecase.dart';
import '../../../domain/usecases/delete_expense_usecase.dart';
import '../../../domain/usecases/get_expenses_usecase.dart';
import 'expense_state.dart';

@injectable
class ExpenseCubit extends BaseCubit<ExpenseState> {
  ExpenseCubit(
    this._getExpensesUseCase,
    this._createExpenseUseCase,
    this._deleteExpenseUseCase,
  ) : super(const ExpenseInitial());

  final GetExpensesUseCase _getExpensesUseCase;
  final CreateExpenseUseCase _createExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;

  int _currentPage = AppConstants.firstPage;
  String? _currentGroupId;

  Future<void> loadExpenses(String groupId) async {
    _currentGroupId = groupId;
    _currentPage = AppConstants.firstPage;
    safeEmit(const ExpenseLoading());

    final result = await _getExpensesUseCase(
      GetExpensesParams(groupId: groupId, page: _currentPage),
    );

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (expenses) => safeEmit(
        ExpenseLoaded(
          expenses: expenses,
          hasReachedMax: expenses.length < AppConstants.defaultPageSize,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ExpenseLoaded || current.isLoadingMore || current.hasReachedMax) return;
    if (_currentGroupId == null) return;

    safeEmit(current.copyWith(isLoadingMore: true));
    _currentPage++;

    final result = await _getExpensesUseCase(
      GetExpensesParams(groupId: _currentGroupId!, page: _currentPage),
    );

    result.fold(
      (failure) {
        logFailure(failure);
        _currentPage--;
        safeEmit(current.copyWith(isLoadingMore: false));
      },
      (newExpenses) => safeEmit(
        current.copyWith(
          expenses: [...current.expenses, ...newExpenses],
          isLoadingMore: false,
          hasReachedMax: newExpenses.length < AppConstants.defaultPageSize,
        ),
      ),
    );
  }

  Future<void> createExpense(CreateExpenseParams params) async {
    safeEmit(const ExpenseCreating());

    final result = await _createExpenseUseCase(params);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (expense) {
        safeEmit(ExpenseCreated(expense: expense));
        // Refresh list
        if (_currentGroupId != null) loadExpenses(_currentGroupId!);
      },
    );
  }

  Future<void> deleteExpense({required String groupId, required String expenseId}) async {
    final result = await _deleteExpenseUseCase(
      DeleteExpenseParams(groupId: groupId, expenseId: expenseId),
    );

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (_) {
        safeEmit(ExpenseDeleted(expenseId: expenseId));
        loadExpenses(groupId);
      },
    );
  }
}
