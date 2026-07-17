import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/recommendation_entity.dart';

abstract class RecommendationsRemoteDataSource {
  Future<List<RecommendationEntity>> getGroupRecommendations(String groupId);
  Future<int> generateRecommendations(String groupId, String type);
  Future<void> likeRecommendation(String groupId, String recommendationId);
  Future<void> unlikeRecommendation(String groupId, String recommendationId);
  Future<void> deleteRecommendationsByBatch(String groupId, String batchId);
}

@LazySingleton(as: RecommendationsRemoteDataSource)
class RecommendationsRemoteDataSourceImpl implements RecommendationsRemoteDataSource {
  RecommendationsRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<RecommendationEntity>> getGroupRecommendations(String groupId) async {
    final response = await _dioClient.dio.get('/groups/$groupId/recommendations');
    
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data.map((e) => RecommendationEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<int> generateRecommendations(String groupId, String type) async {
    await _dioClient.dio.post('/groups/$groupId/recommendations/generate', queryParameters: {
      'type': type,
    });
    return 0;
  }

  @override
  Future<void> likeRecommendation(String groupId, String recommendationId) async {
    await _dioClient.dio.post('/groups/$groupId/recommendations/$recommendationId/like');
  }

  @override
  Future<void> unlikeRecommendation(String groupId, String recommendationId) async {
    await _dioClient.dio.delete('/groups/$groupId/recommendations/$recommendationId/like');
  }

  @override
  Future<void> deleteRecommendationsByBatch(String groupId, String batchId) async {
    await _dioClient.dio.delete('/groups/$groupId/recommendations/batch/$batchId');
  }
}
