import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/recommendation_entity.dart';

abstract class RecommendationsRepository {
  Future<Either<Failure, List<RecommendationEntity>>> getGroupRecommendations(String groupId);
  Future<Either<Failure, int>> generateRecommendations(String groupId, String type);
  Future<Either<Failure, void>> likeRecommendation(String groupId, String recommendationId);
  Future<Either<Failure, void>> unlikeRecommendation(String groupId, String recommendationId);
  Future<Either<Failure, void>> deleteRecommendationsByBatch(String groupId, String batchId);
  
  Stream<List<RecommendationEntity>> get onRecommendationsGenerated;
  Stream<bool> get onRecommendationGenerating;
  Stream<Map<String, dynamic>> get onRecommendationLiked;
}
