// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecommendationEntityImpl _$$RecommendationEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationEntityImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      createdBy: json['createdBy'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: RecommendationContentEntity.fromJson(
          json['content'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );

Map<String, dynamic> _$$RecommendationEntityImplToJson(
        _$RecommendationEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'createdBy': instance.createdBy,
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'likeCount': instance.likeCount,
      'isLiked': instance.isLiked,
    };

_$RecommendationContentEntityImpl _$$RecommendationContentEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationContentEntityImpl(
      address: json['address'] as String?,
      priceRange: json['priceRange'] as String?,
      rating: json['rating'] as num?,
      aiReason: json['aiReason'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      googleMapsUrl: json['googleMapsUrl'] as String?,
    );

Map<String, dynamic> _$$RecommendationContentEntityImplToJson(
        _$RecommendationContentEntityImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'priceRange': instance.priceRange,
      'rating': instance.rating,
      'aiReason': instance.aiReason,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'googleMapsUrl': instance.googleMapsUrl,
    };
