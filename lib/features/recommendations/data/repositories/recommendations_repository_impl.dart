import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/socket/event_dispatcher.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../datasources/recommendations_remote_datasource.dart';

@LazySingleton(as: RecommendationsRepository)
class RecommendationsRepositoryImpl implements RecommendationsRepository {
  RecommendationsRepositoryImpl(this._remoteDataSource, this._eventDispatcher);

  final RecommendationsRemoteDataSource _remoteDataSource;
  final EventDispatcher _eventDispatcher;

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getGroupRecommendations(String groupId) async {
    try {
      final data = await _remoteDataSource.getGroupRecommendations(groupId);
      return Right(data);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? 'Failed to get recommendations',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> generateRecommendations(String groupId, String type) async {
    try {
      final count = await _remoteDataSource.generateRecommendations(groupId, type);
      return Right(count);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? 'Failed to generate recommendations',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likeRecommendation(String groupId, String recommendationId) async {
    try {
      await _remoteDataSource.likeRecommendation(groupId, recommendationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? 'Failed to like recommendation',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeRecommendation(String groupId, String recommendationId) async {
    try {
      await _remoteDataSource.unlikeRecommendation(groupId, recommendationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? 'Failed to unlike recommendation',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecommendationsByBatch(String groupId, String batchId) async {
    try {
      await _remoteDataSource.deleteRecommendationsByBatch(groupId, batchId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? 'Failed to delete recommendations',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<RecommendationEntity>> get onRecommendationsGenerated =>
      _eventDispatcher.on<List<dynamic>>('recommendations-generated').map(
            (data) => data.map((e) => RecommendationEntity.fromJson(e as Map<String, dynamic>)).toList(),
          );

  @override
  Stream<bool> get onRecommendationGenerating =>
      _eventDispatcher.on<Map<String, dynamic>>('recommendation-generating').map(
            (data) => data['isGenerating'] as bool? ?? false,
          );

  @override
  Stream<Map<String, dynamic>> get onRecommendationLiked =>
      _eventDispatcher.on<Map<String, dynamic>>('recommendation-liked');
}
