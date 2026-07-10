// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_message_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GroupMessageEntity _$GroupMessageEntityFromJson(Map<String, dynamic> json) {
  return _GroupMessageEntity.fromJson(json);
}

/// @nodoc
mixin _$GroupMessageEntity {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  UserSummaryEntity? get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupMessageEntityCopyWith<GroupMessageEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMessageEntityCopyWith<$Res> {
  factory $GroupMessageEntityCopyWith(
          GroupMessageEntity value, $Res Function(GroupMessageEntity) then) =
      _$GroupMessageEntityCopyWithImpl<$Res, GroupMessageEntity>;
  @useResult
  $Res call(
      {String id,
      String groupId,
      String userId,
      String content,
      DateTime createdAt,
      UserSummaryEntity? user});

  $UserSummaryEntityCopyWith<$Res>? get user;
}

/// @nodoc
class _$GroupMessageEntityCopyWithImpl<$Res, $Val extends GroupMessageEntity>
    implements $GroupMessageEntityCopyWith<$Res> {
  _$GroupMessageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummaryEntity?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserSummaryEntityCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserSummaryEntityCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GroupMessageEntityImplCopyWith<$Res>
    implements $GroupMessageEntityCopyWith<$Res> {
  factory _$$GroupMessageEntityImplCopyWith(_$GroupMessageEntityImpl value,
          $Res Function(_$GroupMessageEntityImpl) then) =
      __$$GroupMessageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String groupId,
      String userId,
      String content,
      DateTime createdAt,
      UserSummaryEntity? user});

  @override
  $UserSummaryEntityCopyWith<$Res>? get user;
}

/// @nodoc
class __$$GroupMessageEntityImplCopyWithImpl<$Res>
    extends _$GroupMessageEntityCopyWithImpl<$Res, _$GroupMessageEntityImpl>
    implements _$$GroupMessageEntityImplCopyWith<$Res> {
  __$$GroupMessageEntityImplCopyWithImpl(_$GroupMessageEntityImpl _value,
      $Res Function(_$GroupMessageEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(_$GroupMessageEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummaryEntity?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupMessageEntityImpl implements _GroupMessageEntity {
  const _$GroupMessageEntityImpl(
      {required this.id,
      required this.groupId,
      required this.userId,
      required this.content,
      required this.createdAt,
      this.user});

  factory _$GroupMessageEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMessageEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String userId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final UserSummaryEntity? user;

  @override
  String toString() {
    return 'GroupMessageEntity(id: $id, groupId: $groupId, userId: $userId, content: $content, createdAt: $createdAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMessageEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, groupId, userId, content, createdAt, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMessageEntityImplCopyWith<_$GroupMessageEntityImpl> get copyWith =>
      __$$GroupMessageEntityImplCopyWithImpl<_$GroupMessageEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMessageEntityImplToJson(
      this,
    );
  }
}

abstract class _GroupMessageEntity implements GroupMessageEntity {
  const factory _GroupMessageEntity(
      {required final String id,
      required final String groupId,
      required final String userId,
      required final String content,
      required final DateTime createdAt,
      final UserSummaryEntity? user}) = _$GroupMessageEntityImpl;

  factory _GroupMessageEntity.fromJson(Map<String, dynamic> json) =
      _$GroupMessageEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get userId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  UserSummaryEntity? get user;
  @override
  @JsonKey(ignore: true)
  _$$GroupMessageEntityImplCopyWith<_$GroupMessageEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSummaryEntity _$UserSummaryEntityFromJson(Map<String, dynamic> json) {
  return _UserSummaryEntity.fromJson(json);
}

/// @nodoc
mixin _$UserSummaryEntity {
  String get id => throw _privateConstructorUsedError;
  UserProfileSummaryEntity? get profile => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserSummaryEntityCopyWith<UserSummaryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSummaryEntityCopyWith<$Res> {
  factory $UserSummaryEntityCopyWith(
          UserSummaryEntity value, $Res Function(UserSummaryEntity) then) =
      _$UserSummaryEntityCopyWithImpl<$Res, UserSummaryEntity>;
  @useResult
  $Res call({String id, UserProfileSummaryEntity? profile});

  $UserProfileSummaryEntityCopyWith<$Res>? get profile;
}

/// @nodoc
class _$UserSummaryEntityCopyWithImpl<$Res, $Val extends UserSummaryEntity>
    implements $UserSummaryEntityCopyWith<$Res> {
  _$UserSummaryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profile = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfileSummaryEntity?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserProfileSummaryEntityCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $UserProfileSummaryEntityCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserSummaryEntityImplCopyWith<$Res>
    implements $UserSummaryEntityCopyWith<$Res> {
  factory _$$UserSummaryEntityImplCopyWith(_$UserSummaryEntityImpl value,
          $Res Function(_$UserSummaryEntityImpl) then) =
      __$$UserSummaryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, UserProfileSummaryEntity? profile});

  @override
  $UserProfileSummaryEntityCopyWith<$Res>? get profile;
}

/// @nodoc
class __$$UserSummaryEntityImplCopyWithImpl<$Res>
    extends _$UserSummaryEntityCopyWithImpl<$Res, _$UserSummaryEntityImpl>
    implements _$$UserSummaryEntityImplCopyWith<$Res> {
  __$$UserSummaryEntityImplCopyWithImpl(_$UserSummaryEntityImpl _value,
      $Res Function(_$UserSummaryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profile = freezed,
  }) {
    return _then(_$UserSummaryEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfileSummaryEntity?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSummaryEntityImpl implements _UserSummaryEntity {
  const _$UserSummaryEntityImpl({required this.id, this.profile});

  factory _$UserSummaryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSummaryEntityImplFromJson(json);

  @override
  final String id;
  @override
  final UserProfileSummaryEntity? profile;

  @override
  String toString() {
    return 'UserSummaryEntity(id: $id, profile: $profile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSummaryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profile, profile) || other.profile == profile));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, profile);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSummaryEntityImplCopyWith<_$UserSummaryEntityImpl> get copyWith =>
      __$$UserSummaryEntityImplCopyWithImpl<_$UserSummaryEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSummaryEntityImplToJson(
      this,
    );
  }
}

abstract class _UserSummaryEntity implements UserSummaryEntity {
  const factory _UserSummaryEntity(
      {required final String id,
      final UserProfileSummaryEntity? profile}) = _$UserSummaryEntityImpl;

  factory _UserSummaryEntity.fromJson(Map<String, dynamic> json) =
      _$UserSummaryEntityImpl.fromJson;

  @override
  String get id;
  @override
  UserProfileSummaryEntity? get profile;
  @override
  @JsonKey(ignore: true)
  _$$UserSummaryEntityImplCopyWith<_$UserSummaryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfileSummaryEntity _$UserProfileSummaryEntityFromJson(
    Map<String, dynamic> json) {
  return _UserProfileSummaryEntity.fromJson(json);
}

/// @nodoc
mixin _$UserProfileSummaryEntity {
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileSummaryEntityCopyWith<UserProfileSummaryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileSummaryEntityCopyWith<$Res> {
  factory $UserProfileSummaryEntityCopyWith(UserProfileSummaryEntity value,
          $Res Function(UserProfileSummaryEntity) then) =
      _$UserProfileSummaryEntityCopyWithImpl<$Res, UserProfileSummaryEntity>;
  @useResult
  $Res call({String? displayName, String? avatarUrl});
}

/// @nodoc
class _$UserProfileSummaryEntityCopyWithImpl<$Res,
        $Val extends UserProfileSummaryEntity>
    implements $UserProfileSummaryEntityCopyWith<$Res> {
  _$UserProfileSummaryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileSummaryEntityImplCopyWith<$Res>
    implements $UserProfileSummaryEntityCopyWith<$Res> {
  factory _$$UserProfileSummaryEntityImplCopyWith(
          _$UserProfileSummaryEntityImpl value,
          $Res Function(_$UserProfileSummaryEntityImpl) then) =
      __$$UserProfileSummaryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? displayName, String? avatarUrl});
}

/// @nodoc
class __$$UserProfileSummaryEntityImplCopyWithImpl<$Res>
    extends _$UserProfileSummaryEntityCopyWithImpl<$Res,
        _$UserProfileSummaryEntityImpl>
    implements _$$UserProfileSummaryEntityImplCopyWith<$Res> {
  __$$UserProfileSummaryEntityImplCopyWithImpl(
      _$UserProfileSummaryEntityImpl _value,
      $Res Function(_$UserProfileSummaryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$UserProfileSummaryEntityImpl(
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileSummaryEntityImpl implements _UserProfileSummaryEntity {
  const _$UserProfileSummaryEntityImpl({this.displayName, this.avatarUrl});

  factory _$UserProfileSummaryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileSummaryEntityImplFromJson(json);

  @override
  final String? displayName;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'UserProfileSummaryEntity(displayName: $displayName, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileSummaryEntityImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, displayName, avatarUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileSummaryEntityImplCopyWith<_$UserProfileSummaryEntityImpl>
      get copyWith => __$$UserProfileSummaryEntityImplCopyWithImpl<
          _$UserProfileSummaryEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileSummaryEntityImplToJson(
      this,
    );
  }
}

abstract class _UserProfileSummaryEntity implements UserProfileSummaryEntity {
  const factory _UserProfileSummaryEntity(
      {final String? displayName,
      final String? avatarUrl}) = _$UserProfileSummaryEntityImpl;

  factory _UserProfileSummaryEntity.fromJson(Map<String, dynamic> json) =
      _$UserProfileSummaryEntityImpl.fromJson;

  @override
  String? get displayName;
  @override
  String? get avatarUrl;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileSummaryEntityImplCopyWith<_$UserProfileSummaryEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
