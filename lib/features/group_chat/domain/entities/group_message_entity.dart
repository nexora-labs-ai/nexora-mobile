import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_message_entity.freezed.dart';
part 'group_message_entity.g.dart';

@freezed
class GroupMessageEntity with _$GroupMessageEntity {
  const factory GroupMessageEntity({
    required String id,
    required String groupId,
    required String userId,
    required String content,
    required DateTime createdAt,
    UserSummaryEntity? user,
  }) = _GroupMessageEntity;

  factory GroupMessageEntity.fromJson(Map<String, dynamic> json) =>
      _$GroupMessageEntityFromJson(json);
}

@freezed
class UserSummaryEntity with _$UserSummaryEntity {
  const factory UserSummaryEntity({
    required String id,
    UserProfileSummaryEntity? profile,
  }) = _UserSummaryEntity;

  factory UserSummaryEntity.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryEntityFromJson(json);
}

@freezed
class UserProfileSummaryEntity with _$UserProfileSummaryEntity {
  const factory UserProfileSummaryEntity({
    String? displayName,
    String? avatarUrl,
  }) = _UserProfileSummaryEntity;

  factory UserProfileSummaryEntity.fromJson(Map<String, dynamic> json) =>
      _$UserProfileSummaryEntityFromJson(json);
}
