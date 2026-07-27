import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_expense_by_id_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/get_group_balance_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import 'expense_state.dart';

@injectable
class ExpenseCubit extends BaseCubit<ExpenseState> {
  ExpenseCubit(
    this._getExpensesUseCase,
    this._createExpenseUseCase,
    this._deleteExpenseUseCase,
    this._getCategoriesUseCase,
    this._getExpenseByIdUseCase,
    this._updateExpenseUseCase,
    this._getGroupBalanceUseCase,
  ) : super(const ExpenseInitial());

  final GetExpensesUseCase _getExpensesUseCase;
  final CreateExpenseUseCase _createExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetExpenseByIdUseCase _getExpenseByIdUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final GetGroupBalanceUseCase _getGroupBalanceUseCase;

  int _currentPage = AppConstants.firstPage;
  String? _currentGroupId;
  String? _currentQuery;

  Future<void> loadCategories() async {
    safeEmit(const CategoriesLoading());
    final result = await _getCategoriesUseCase(const NoParams());
    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (categories) => safeEmit(CategoriesLoaded(categories: categories)),
    );
  }

  Future<void> loadExpenses(String groupId) async {
    _currentGroupId = groupId;
    _currentPage = AppConstants.firstPage;
    _currentQuery = null;
    safeEmit(const ExpenseLoading());

    final result = await _getExpensesUseCase(
      GetExpensesParams(groupId: groupId, page: _currentPage),
    );

    final balanceResult =
        await _getGroupBalanceUseCase(GetGroupBalanceParams(groupId: groupId));
    final balances = balanceResult.fold((l) => null, (r) => r);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (expenses) => safeEmit(
        ExpenseLoaded(
          expenses: expenses,
          hasReachedMax: expenses.length < AppConstants.defaultPageSize,
          balances: balances,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ExpenseLoaded ||
        current.isLoadingMore ||
        current.hasReachedMax) {
      return;
    }
    if (_currentGroupId == null) return;

    safeEmit(current.copyWith(isLoadingMore: true));
    _currentPage++;

    final result = await _getExpensesUseCase(
      GetExpensesParams(
        groupId: _currentGroupId!,
        page: _currentPage,
        query: _currentQuery,
      ),
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

  Future<void> applySearch(String query) async {
    if (_currentGroupId == null) return;

    _currentQuery = query.isEmpty ? null : query;
    _currentPage = AppConstants.firstPage;
    safeEmit(const ExpenseLoading());

    final result = await _getExpensesUseCase(
      GetExpensesParams(
        groupId: _currentGroupId!,
        page: _currentPage,
        query: _currentQuery,
      ),
    );

    // Keep the balance from previous state if available, or fetch it again
    final balanceResult = await _getGroupBalanceUseCase(
        GetGroupBalanceParams(groupId: _currentGroupId!));
    final balances = balanceResult.fold((l) => null, (r) => r);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (expenses) => safeEmit(
        ExpenseLoaded(
          expenses: expenses,
          hasReachedMax: expenses.length < AppConstants.defaultPageSize,
          balances: balances,
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

  Future<void> deleteExpense(
      {required String groupId, required String expenseId}) async {
    safeEmit(const ExpenseLoading());
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

  Future<void> loadExpenseDetail(
      {required String groupId, required String expenseId}) async {
    safeEmit(const ExpenseLoading());
    final result = await _getExpenseByIdUseCase(
      GetExpenseByIdParams(groupId: groupId, expenseId: expenseId),
    );

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (expense) => safeEmit(ExpenseDetailLoaded(expense: expense)),
    );
  }

  Future<void> updateExpense(UpdateExpenseParams params) async {
    safeEmit(const ExpenseUpdating());

    final result = await _updateExpenseUseCase(params);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(ExpenseFailureState(message: failure.message));
      },
      (expense) {
        safeEmit(ExpenseUpdated(expense: expense));
        if (_currentGroupId != null) loadExpenses(_currentGroupId!);
      },
    );
  }
}
