// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecommendationEntity _$RecommendationEntityFromJson(Map<String, dynamic> json) {
  return _RecommendationEntity.fromJson(json);
}

/// @nodoc
mixin _$RecommendationEntity {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  RecommendationContentEntity get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecommendationEntityCopyWith<RecommendationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationEntityCopyWith<$Res> {
  factory $RecommendationEntityCopyWith(RecommendationEntity value,
          $Res Function(RecommendationEntity) then) =
      _$RecommendationEntityCopyWithImpl<$Res, RecommendationEntity>;
  @useResult
  $Res call(
      {String id,
      String groupId,
      String createdBy,
      String type,
      String title,
      RecommendationContentEntity content,
      DateTime createdAt,
      Map<String, dynamic>? metadata,
      DateTime? expiresAt,
      int likeCount,
      bool isLiked});

  $RecommendationContentEntityCopyWith<$Res> get content;
}

/// @nodoc
class _$RecommendationEntityCopyWithImpl<$Res,
        $Val extends RecommendationEntity>
    implements $RecommendationEntityCopyWith<$Res> {
  _$RecommendationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? createdBy = null,
    Object? type = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? likeCount = null,
    Object? isLiked = null,
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
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as RecommendationContentEntity,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RecommendationContentEntityCopyWith<$Res> get content {
    return $RecommendationContentEntityCopyWith<$Res>(_value.content, (value) {
      return _then(_value.copyWith(content: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationEntityImplCopyWith<$Res>
    implements $RecommendationEntityCopyWith<$Res> {
  factory _$$RecommendationEntityImplCopyWith(_$RecommendationEntityImpl value,
          $Res Function(_$RecommendationEntityImpl) then) =
      __$$RecommendationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String groupId,
      String createdBy,
      String type,
      String title,
      RecommendationContentEntity content,
      DateTime createdAt,
      Map<String, dynamic>? metadata,
      DateTime? expiresAt,
      int likeCount,
      bool isLiked});

  @override
  $RecommendationContentEntityCopyWith<$Res> get content;
}

/// @nodoc
class __$$RecommendationEntityImplCopyWithImpl<$Res>
    extends _$RecommendationEntityCopyWithImpl<$Res, _$RecommendationEntityImpl>
    implements _$$RecommendationEntityImplCopyWith<$Res> {
  __$$RecommendationEntityImplCopyWithImpl(_$RecommendationEntityImpl _value,
      $Res Function(_$RecommendationEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? createdBy = null,
    Object? type = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? likeCount = null,
    Object? isLiked = null,
  }) {
    return _then(_$RecommendationEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as RecommendationContentEntity,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationEntityImpl implements _RecommendationEntity {
  const _$RecommendationEntityImpl(
      {required this.id,
      required this.groupId,
      required this.createdBy,
      required this.type,
      required this.title,
      required this.content,
      required this.createdAt,
      final Map<String, dynamic>? metadata,
      this.expiresAt,
      this.likeCount = 0,
      this.isLiked = false})
      : _metadata = metadata;

  factory _$RecommendationEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String createdBy;
  @override
  final String type;
  @override
  final String title;
  @override
  final RecommendationContentEntity content;
  @override
  final DateTime createdAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final bool isLiked;

  @override
  String toString() {
    return 'RecommendationEntity(id: $id, groupId: $groupId, createdBy: $createdBy, type: $type, title: $title, content: $content, createdAt: $createdAt, metadata: $metadata, expiresAt: $expiresAt, likeCount: $likeCount, isLiked: $isLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      groupId,
      createdBy,
      type,
      title,
      content,
      createdAt,
      const DeepCollectionEquality().hash(_metadata),
      expiresAt,
      likeCount,
      isLiked);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationEntityImplCopyWith<_$RecommendationEntityImpl>
      get copyWith =>
          __$$RecommendationEntityImplCopyWithImpl<_$RecommendationEntityImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationEntityImplToJson(
      this,
    );
  }
}

abstract class _RecommendationEntity implements RecommendationEntity {
  const factory _RecommendationEntity(
      {required final String id,
      required final String groupId,
      required final String createdBy,
      required final String type,
      required final String title,
      required final RecommendationContentEntity content,
      required final DateTime createdAt,
      final Map<String, dynamic>? metadata,
      final DateTime? expiresAt,
      final int likeCount,
      final bool isLiked}) = _$RecommendationEntityImpl;

  factory _RecommendationEntity.fromJson(Map<String, dynamic> json) =
      _$RecommendationEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get createdBy;
  @override
  String get type;
  @override
  String get title;
  @override
  RecommendationContentEntity get content;
  @override
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime? get expiresAt;
  @override
  int get likeCount;
  @override
  bool get isLiked;
  @override
  @JsonKey(ignore: true)
  _$$RecommendationEntityImplCopyWith<_$RecommendationEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RecommendationContentEntity _$RecommendationContentEntityFromJson(
    Map<String, dynamic> json) {
  return _RecommendationContentEntity.fromJson(json);
}

/// @nodoc
mixin _$RecommendationContentEntity {
  String? get address => throw _privateConstructorUsedError;
  String? get priceRange => throw _privateConstructorUsedError;
  num? get rating => throw _privateConstructorUsedError;
  String? get aiReason => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get googleMapsUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecommendationContentEntityCopyWith<RecommendationContentEntity>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationContentEntityCopyWith<$Res> {
  factory $RecommendationContentEntityCopyWith(
          RecommendationContentEntity value,
          $Res Function(RecommendationContentEntity) then) =
      _$RecommendationContentEntityCopyWithImpl<$Res,
          RecommendationContentEntity>;
  @useResult
  $Res call(
      {String? address,
      String? priceRange,
      num? rating,
      String? aiReason,
      String? imageUrl,
      String? description,
      String? googleMapsUrl});
}

/// @nodoc
class _$RecommendationContentEntityCopyWithImpl<$Res,
        $Val extends RecommendationContentEntity>
    implements $RecommendationContentEntityCopyWith<$Res> {
  _$RecommendationContentEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? priceRange = freezed,
    Object? rating = freezed,
    Object? aiReason = freezed,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? googleMapsUrl = freezed,
  }) {
    return _then(_value.copyWith(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as num?,
      aiReason: freezed == aiReason
          ? _value.aiReason
          : aiReason // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      googleMapsUrl: freezed == googleMapsUrl
          ? _value.googleMapsUrl
          : googleMapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendationContentEntityImplCopyWith<$Res>
    implements $RecommendationContentEntityCopyWith<$Res> {
  factory _$$RecommendationContentEntityImplCopyWith(
          _$RecommendationContentEntityImpl value,
          $Res Function(_$RecommendationContentEntityImpl) then) =
      __$$RecommendationContentEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? address,
      String? priceRange,
      num? rating,
      String? aiReason,
      String? imageUrl,
      String? description,
      String? googleMapsUrl});
}

/// @nodoc
class __$$RecommendationContentEntityImplCopyWithImpl<$Res>
    extends _$RecommendationContentEntityCopyWithImpl<$Res,
        _$RecommendationContentEntityImpl>
    implements _$$RecommendationContentEntityImplCopyWith<$Res> {
  __$$RecommendationContentEntityImplCopyWithImpl(
      _$RecommendationContentEntityImpl _value,
      $Res Function(_$RecommendationContentEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? priceRange = freezed,
    Object? rating = freezed,
    Object? aiReason = freezed,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? googleMapsUrl = freezed,
  }) {
    return _then(_$RecommendationContentEntityImpl(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as num?,
      aiReason: freezed == aiReason
          ? _value.aiReason
          : aiReason // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      googleMapsUrl: freezed == googleMapsUrl
          ? _value.googleMapsUrl
          : googleMapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationContentEntityImpl
    implements _RecommendationContentEntity {
  const _$RecommendationContentEntityImpl(
      {this.address,
      this.priceRange,
      this.rating,
      this.aiReason,
      this.imageUrl,
      this.description,
      this.googleMapsUrl});

  factory _$RecommendationContentEntityImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RecommendationContentEntityImplFromJson(json);

  @override
  final String? address;
  @override
  final String? priceRange;
  @override
  final num? rating;
  @override
  final String? aiReason;
  @override
  final String? imageUrl;
  @override
  final String? description;
  @override
  final String? googleMapsUrl;

  @override
  String toString() {
    return 'RecommendationContentEntity(address: $address, priceRange: $priceRange, rating: $rating, aiReason: $aiReason, imageUrl: $imageUrl, description: $description, googleMapsUrl: $googleMapsUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationContentEntityImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.aiReason, aiReason) ||
                other.aiReason == aiReason) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.googleMapsUrl, googleMapsUrl) ||
                other.googleMapsUrl == googleMapsUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, address, priceRange, rating,
      aiReason, imageUrl, description, googleMapsUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationContentEntityImplCopyWith<_$RecommendationContentEntityImpl>
      get copyWith => __$$RecommendationContentEntityImplCopyWithImpl<
          _$RecommendationContentEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationContentEntityImplToJson(
      this,
    );
  }
}

abstract class _RecommendationContentEntity
    implements RecommendationContentEntity {
  const factory _RecommendationContentEntity(
      {final String? address,
      final String? priceRange,
      final num? rating,
      final String? aiReason,
      final String? imageUrl,
      final String? description,
      final String? googleMapsUrl}) = _$RecommendationContentEntityImpl;

  factory _RecommendationContentEntity.fromJson(Map<String, dynamic> json) =
      _$RecommendationContentEntityImpl.fromJson;

  @override
  String? get address;
  @override
  String? get priceRange;
  @override
  num? get rating;
  @override
  String? get aiReason;
  @override
  String? get imageUrl;
  @override
  String? get description;
  @override
  String? get googleMapsUrl;
  @override
  @JsonKey(ignore: true)
  _$$RecommendationContentEntityImplCopyWith<_$RecommendationContentEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
