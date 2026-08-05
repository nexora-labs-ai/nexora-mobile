import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/optimized_settlement_model.dart';
import '../models/settlement_model.dart';

abstract interface class SettlementRemoteDatasource {
  Future<List<SettlementModel>> getGroupSettlements(String groupId);
  Future<List<OptimizedSettlementModel>> getOptimizedSettlements(
      String groupId);
  Future<SettlementModel> requestSettlement({
    required String groupId,
    required String toUserId,
    required int amount,
    required String currency,
    String? note,
  });
  Future<SettlementModel> completeSettlement(String settlementId);
  Future<SettlementModel> cancelSettlement(String settlementId);
  Future<SettlementModel> uploadEvidence(String settlementId, File file);
  Future<void> remindSettlement(String groupId, String targetUserId);
}

@Injectable(as: SettlementRemoteDatasource)
class SettlementRemoteDatasourceImpl implements SettlementRemoteDatasource {
  SettlementRemoteDatasourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<SettlementModel>> getGroupSettlements(String groupId) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.settlements,
      queryParameters: {'groupId': groupId},
    );
    final items = response.data as List;
    return items
        .map((e) => SettlementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OptimizedSettlementModel>> getOptimizedSettlements(
      String groupId) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.optimizedSettlements,
      queryParameters: {'groupId': groupId},
    );
    final items = response.data as List;
    return items
        .map(
            (e) => OptimizedSettlementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SettlementModel> requestSettlement({
    required String groupId,
    required String toUserId,
    required int amount,
    required String currency,
    String? note,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.settlements,
      data: {
        'groupId': groupId,
        'toUserId': toUserId,
        'amount': amount / 100.0,
        'currency': currency,
        if (note != null) 'note': note,
      },
    );
    return SettlementModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SettlementModel> completeSettlement(String settlementId) async {
    final response = await _dioClient.dio
        .patch(ApiEndpoints.completeSettlement(settlementId));
    return SettlementModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SettlementModel> cancelSettlement(String settlementId) async {
    final response =
        await _dioClient.dio.patch(ApiEndpoints.cancelSettlement(settlementId));
    return SettlementModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SettlementModel> uploadEvidence(String settlementId, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final response = await _dioClient.dio.post(
      ApiEndpoints.uploadSettlementEvidence(settlementId),
      data: formData,
    );
    return SettlementModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> remindSettlement(String groupId, String targetUserId) async {
    await _dioClient.dio.post(
      ApiEndpoints.remindSettlement,
      data: {
        'groupId': groupId,
        'targetUserId': targetUserId,
      },
    );
  }
}
