import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/optimized_settlement_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../datasources/settlement_remote_datasource.dart';

@Injectable(as: SettlementRepository)
class SettlementRepositoryImpl implements SettlementRepository {
  const SettlementRepositoryImpl(this._remote);

  final SettlementRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<SettlementEntity>>> getGroupSettlements(
      String groupId) async {
    try {
      final models = await _remote.getGroupSettlements(groupId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OptimizedSettlementEntity>>>
      getOptimizedSettlements(String groupId) async {
    try {
      final models = await _remote.getOptimizedSettlements(groupId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SettlementEntity>> requestSettlement({
    required String groupId,
    required String toUserId,
    required int amount,
    required String currency,
    String? note,
  }) async {
    try {
      final model = await _remote.requestSettlement(
        groupId: groupId,
        toUserId: toUserId,
        amount: amount,
        currency: currency,
        note: note,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SettlementEntity>> completeSettlement(
      String settlementId) async {
    try {
      final model = await _remote.completeSettlement(settlementId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SettlementEntity>> cancelSettlement(
      String settlementId) async {
    try {
      final model = await _remote.cancelSettlement(settlementId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SettlementEntity>> uploadEvidence(
      String settlementId, File file) async {
    try {
      final model = await _remote.uploadEvidence(settlementId, file);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(DioErrorMapper.toFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
