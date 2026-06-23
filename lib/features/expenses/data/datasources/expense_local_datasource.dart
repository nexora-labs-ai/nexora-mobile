import 'package:injectable/injectable.dart';

import '../../../../core/storage/hive_storage.dart';
import '../models/expense_model.dart';

abstract interface class ExpenseLocalDatasource {
  Future<List<ExpenseModel>> getCachedExpenses(String groupId);
  Future<void> cacheExpenses(String groupId, List<ExpenseModel> expenses);
  Future<void> clearCache(String groupId);
}

@Injectable(as: ExpenseLocalDatasource)
class ExpenseLocalDatasourceImpl implements ExpenseLocalDatasource {
  ExpenseLocalDatasourceImpl(this._hiveStorage);

  final HiveStorage _hiveStorage;

  String _cacheKey(String groupId) => 'expenses_$groupId';

  @override
  Future<List<ExpenseModel>> getCachedExpenses(String groupId) async {
    final cached = _hiveStorage.getCachedJson(_cacheKey(groupId));
    if (cached == null) return [];

    final items = cached['items'] as List?;
    if (items == null) return [];

    return items
        .map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> cacheExpenses(String groupId, List<ExpenseModel> expenses) {
    return _hiveStorage.cacheJson(
      _cacheKey(groupId),
      {'items': expenses.map((e) => e.toJson()).toList()},
    );
  }

  @override
  Future<void> clearCache(String groupId) {
    return _hiveStorage.invalidateCache(_cacheKey(groupId));
  }
}
