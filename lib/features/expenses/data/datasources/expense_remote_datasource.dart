import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/expense_model.dart';
import '../models/group_balance_model.dart';

abstract interface class ExpenseRemoteDatasource {
  Future<List<ExpenseModel>> getExpenses(
      {required String groupId, int page = 1, int pageSize = 20});
  Future<ExpenseModel> getExpenseById(
      {required String groupId, required String expenseId});
  Future<ExpenseModel> createExpense(
      {required String groupId, required Map<String, dynamic> data});
  Future<ExpenseModel> updateExpense(
      {required String groupId,
      required String expenseId,
      required Map<String, dynamic> data});
  Future<void> deleteExpense(
      {required String groupId, required String expenseId});
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<GroupBalanceModel>> getGroupBalance(String groupId);
}

@Injectable(as: ExpenseRemoteDatasource)
class ExpenseRemoteDatasourceImpl implements ExpenseRemoteDatasource {
  ExpenseRemoteDatasourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<ExpenseModel>> getExpenses({
    required String groupId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.expenses,
      queryParameters: {'groupId': groupId, 'page': page, 'limit': pageSize},
    );
    final items = response.data['data'] as List;
    return items
        .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExpenseModel> getExpenseById(
      {required String groupId, required String expenseId}) async {
    final response =
        await _dioClient.dio.get(ApiEndpoints.expenseById(expenseId));
    return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ExpenseModel> createExpense(
      {required String groupId, required Map<String, dynamic> data}) async {
    final response =
        await _dioClient.dio.post(ApiEndpoints.expenses, data: data);
    return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ExpenseModel> updateExpense(
      {required String groupId,
      required String expenseId,
      required Map<String, dynamic> data}) async {
    final response = await _dioClient.dio
        .put(ApiEndpoints.expenseById(expenseId), data: data);
    return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExpense(
          {required String groupId, required String expenseId}) =>
      _dioClient.dio.delete(ApiEndpoints.expenseById(expenseId));

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dioClient.dio.get(ApiEndpoints.categories);
    final items = response.data;
    if (items is List) {
      return items.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<List<GroupBalanceModel>> getGroupBalance(String groupId) async {
    final response = await _dioClient.dio
        .get('${ApiEndpoints.expenses}/group/$groupId/balance');
    final items = response.data as List;
    return items
        .map((e) => GroupBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
