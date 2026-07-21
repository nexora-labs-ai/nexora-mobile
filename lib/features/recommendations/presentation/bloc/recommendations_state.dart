import 'package:equatable/equatable.dart';
import '../../domain/entities/recommendation_entity.dart';

abstract class RecommendationsState extends Equatable {
  const RecommendationsState();

  @override
  List<Object?> get props => [];
}

class RecommendationsInitial extends RecommendationsState {}

class RecommendationsLoading extends RecommendationsState {}

class RecommendationsLoaded extends RecommendationsState {
  const RecommendationsLoaded(this.recommendations, {this.isGenerating = false, this.errorMessage});
  final List<RecommendationEntity> recommendations;
  final bool isGenerating;
  final String? errorMessage;

  @override
  List<Object?> get props => [recommendations, isGenerating, errorMessage];
  
  RecommendationsLoaded copyWith({
    List<RecommendationEntity>? recommendations,
    bool? isGenerating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RecommendationsLoaded(
      recommendations ?? this.recommendations,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RecommendationsError extends RecommendationsState {
  const RecommendationsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
