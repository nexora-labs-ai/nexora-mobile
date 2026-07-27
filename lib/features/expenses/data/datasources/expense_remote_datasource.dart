import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/expense_model.dart';
import '../models/group_balance_model.dart';

abstract interface class ExpenseRemoteDatasource {
  Future<List<ExpenseModel>> getExpenses(
      {required String groupId,
      int page = 1,
      int pageSize = 20,
      String? query});
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
    String? query,
  }) async {
    final queryParameters = <String, dynamic>{
      'groupId': groupId,
      'page': page,
      'limit': pageSize,
    };
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    final response = await _dioClient.dio.get(
      ApiEndpoints.expenses,
      queryParameters: queryParameters,
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
    // We must force refresh the cache here because it might have persistently cached an empty list
    // before the database was seeded.
    final cacheOptions = CacheOptions(
      store: MemCacheStore(), // Dummy store just to build extra
      policy: CachePolicy.refreshForceCache,
    );

    final response = await _dioClient.dio.get(
      ApiEndpoints.categories,
      options: Options(extra: cacheOptions.toExtra()),
    );
    var items = response.data;

    AppLogger.debug(
        'getCategories raw response: type=${items.runtimeType}, value=$items');

    if (items is Map<String, dynamic> && items.containsKey('data')) {
      items = items['data'];
    }

    if (items is List) {
      return items.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  Future<List<GroupBalanceModel>> getGroupBalance(String groupId) async {
    final response =
        await _dioClient.dio.get(ApiEndpoints.expenseBalance(groupId));
    final items = response.data as List;
    return items
        .map((e) => GroupBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
