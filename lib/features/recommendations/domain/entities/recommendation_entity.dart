import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_entity.freezed.dart';
part 'recommendation_entity.g.dart';

@freezed
class RecommendationEntity with _$RecommendationEntity {
  const factory RecommendationEntity({
    required String id,
    required String groupId,
    required String createdBy,
    required String type,
    required String title,
    required RecommendationContentEntity content,
    required DateTime createdAt,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    @Default(0) int likeCount,
    @Default(false) bool isLiked,
  }) = _RecommendationEntity;

  factory RecommendationEntity.fromJson(Map<String, dynamic> json) =>
      _$RecommendationEntityFromJson(json);
}

@freezed
class RecommendationContentEntity with _$RecommendationContentEntity {
  const factory RecommendationContentEntity({
    String? address,
    String? priceRange,
    num? rating,
    String? aiReason,
    String? imageUrl,
    String? description,
    String? googleMapsUrl,
  }) = _RecommendationContentEntity;

  factory RecommendationContentEntity.fromJson(Map<String, dynamic> json) =>
      _$RecommendationContentEntityFromJson(json);
}
