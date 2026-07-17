import 'package:equatable/equatable.dart';
import '../../domain/entities/recommendation_entity.dart';

abstract class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecommendations extends RecommendationsEvent {
  const LoadRecommendations(this.groupId);
  final String groupId;

  @override
  List<Object?> get props => [groupId];
}

class GenerateRecommendations extends RecommendationsEvent {
  const GenerateRecommendations(this.groupId, this.type);
  final String groupId;
  final String type;

  @override
  List<Object?> get props => [groupId, type];
}

class ToggleLikeRecommendation extends RecommendationsEvent {
  final String groupId;
  final String recommendationId;
  const ToggleLikeRecommendation(this.groupId, this.recommendationId);
  @override
  List<Object?> get props => [groupId, recommendationId];
}

class DeleteRecommendationsByBatch extends RecommendationsEvent {
  final String groupId;
  final String batchId;
  const DeleteRecommendationsByBatch(this.groupId, this.batchId);
  @override
  List<Object?> get props => [groupId, batchId];
}

class RecommendationsGeneratedReceived extends RecommendationsEvent {
  const RecommendationsGeneratedReceived(this.recommendations);
  final List<RecommendationEntity> recommendations;

  @override
  List<Object?> get props => [recommendations];
}

class RecommendationLikeUpdated extends RecommendationsEvent {
  const RecommendationLikeUpdated(this.recommendationId, this.userId, this.action);
  final String recommendationId;
  final String userId;
  final String action;

  @override
  List<Object?> get props => [recommendationId, userId, action];
}

class RecommendationGeneratingReceived extends RecommendationsEvent {
  const RecommendationGeneratingReceived(this.isGenerating);
  final bool isGenerating;

  @override
  List<Object?> get props => [isGenerating];
}

class ClearRecommendationError extends RecommendationsEvent {}
