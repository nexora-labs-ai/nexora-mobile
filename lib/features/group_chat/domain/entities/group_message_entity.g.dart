// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_message_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupMessageEntityImpl _$$GroupMessageEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$GroupMessageEntityImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] == null
          ? null
          : UserSummaryEntity.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GroupMessageEntityImplToJson(
        _$GroupMessageEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };

_$UserSummaryEntityImpl _$$UserSummaryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSummaryEntityImpl(
      id: json['id'] as String,
      profile: json['profile'] == null
          ? null
          : UserProfileSummaryEntity.fromJson(
              json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserSummaryEntityImplToJson(
        _$UserSummaryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile': instance.profile,
    };

_$UserProfileSummaryEntityImpl _$$UserProfileSummaryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProfileSummaryEntityImpl(
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$UserProfileSummaryEntityImplToJson(
        _$UserProfileSummaryEntityImpl instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
    };
