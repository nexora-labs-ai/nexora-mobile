import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/group_balance_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../datasources/expense_remote_datasource.dart';
import '../mappers/expense_mapper.dart';

/// Cache-first + remote fallback strategy:
///
/// 1. Return cached data immediately (offline-first)
/// 2. Fetch from remote in background and update cache
/// 3. On write operations, update remote then invalidate cache
@Injectable(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._remote, this._local);

  final ExpenseRemoteDatasource _remote;
  final ExpenseLocalDatasource _local;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({
    required String groupId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final models = await _remote.getExpenses(
        groupId: groupId,
        page: page,
        pageSize: pageSize,
      );

      // Update cache after successful fetch
      if (page == 1) {
        await _local.cacheExpenses(groupId, models);
      }

      return Right(models.map(ExpenseMapper.toEntity).toList());
    } on DioException catch (e) {
      // Network failure – fall back to cache
      final cached = await _local.getCachedExpenses(groupId);
      if (cached.isNotEmpty) {
        return Right(cached.map(ExpenseMapper.toEntity).toList());
      }
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> getExpenseById({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      final model =
          await _remote.getExpenseById(groupId: groupId, expenseId: expenseId);
      return Right(ExpenseMapper.toEntity(model));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> createExpense({
    required String groupId,
    required String title,
    required double amount,
    required String currency,
    required String paidByUserId,
    required String categoryId,
    required String fundingSource,
    required DateTime expenseDate,
    required String splitType,
    required List<Map<String, dynamic>> splits,
    String? description,
    String? receiptUrl,
  }) async {
    try {
      final model = await _remote.createExpense(
        groupId: groupId,
        data: {
          'groupId': groupId,
          'title': title,
          'amount': amount,
          'currency': currency,
          'splitType': splitType,
          'categoryId': categoryId,
          'fundingSource': fundingSource,
          'date': expenseDate.toIso8601String(),
          'splits': splits,
          if (description != null) 'description': description,
          if (receiptUrl != null) 'receipt_url': receiptUrl,
        },
      );

      // Invalidate cache so next fetch is fresh
      await _local.clearCache(groupId);

      return Right(ExpenseMapper.toEntity(model));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> updateExpense({
    required String groupId,
    required String expenseId,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final model = await _remote.updateExpense(
        groupId: groupId,
        expenseId: expenseId,
        data: fields,
      );
      await _local.clearCache(groupId);
      return Right(ExpenseMapper.toEntity(model));
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      await _remote.deleteExpense(groupId: groupId, expenseId: expenseId);
      await _local.clearCache(groupId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupBalanceEntity>>> getGroupBalance(
      String groupId) async {
    try {
      final models = await _remote.getGroupBalance(groupId);
      final entities = models
          .map((m) => GroupBalanceEntity(userId: m.userId, balance: m.balance))
          .toList();
      return Right(entities);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getCachedExpenses(
      String groupId) async {
    try {
      final cached = await _local.getCachedExpenses(groupId);
      return Right(cached.map(ExpenseMapper.toEntity).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<void> cacheExpenses(
      String groupId, List<ExpenseEntity> expenses) async {
    // Intentionally no-op here – called internally by getExpenses
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final data = await _remote.getCategories();
      final categories = data
          .map((e) => CategoryEntity(
                id: e['id'] as String,
                name: e['name'] as String,
                icon: e['icon'] as String,
                color: e['color'] as String,
                isDefault: e['isDefault'] as bool? ??
                    e['is_default'] as bool? ??
                    false,
              ))
          .toList();
      return Right(categories);
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
