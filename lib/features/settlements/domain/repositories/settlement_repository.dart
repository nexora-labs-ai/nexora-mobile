import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/optimized_settlement_entity.dart';
import '../entities/settlement_entity.dart';

abstract interface class SettlementRepository {
  Future<Either<Failure, List<SettlementEntity>>> getGroupSettlements(
      String groupId);

  Future<Either<Failure, List<OptimizedSettlementEntity>>>
      getOptimizedSettlements(String groupId);

  Future<Either<Failure, SettlementEntity>> requestSettlement({
    required String groupId,
    required String toUserId,
    required int amount,
    required String currency,
    String? note,
  });

  Future<Either<Failure, SettlementEntity>> completeSettlement(
      String settlementId);

  Future<Either<Failure, SettlementEntity>> cancelSettlement(
      String settlementId);

  Future<Either<Failure, SettlementEntity>> uploadEvidence(
      String settlementId, File file);

  Future<Either<Failure, void>> remindSettlement(
      String groupId, String targetUserId);
}
